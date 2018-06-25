function fun(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,NewResultCallback,ProcessingLogQueue,UiAlertQueue)
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end
  
  msg = sprintf('Processing image %d of %d',current_img_number,NumberOfImages);
  if is_parallel_processing
    send(ProcessingLogQueue,msg);
  else
    app.log_processing_message(app, msg);
    if isvalid(app.progressdlg)
      close(app.progressdlg)
    end
    app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message', msg, 'Cancelable', 'on');
    assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way
  end
  image_file = imgs_to_process(current_img_number);
  plate_num = image_file.plate_num;
  plate = app.plates(plate_num);

  if ~is_parallel_processing
    if app.progressdlg.CancelRequested
        return
    end
    app.progressdlg.Message = sprintf('%s\n%s',msg,'Loading image...');
    app.progressdlg.Value = (0.1 / NumberOfImages) + ((current_img_number-1) / NumberOfImages);
  end
  imgs = [];
  for chan_num=[image_file.channel_nums]
    %% Do Preprocessing
    imgs(chan_num).data = do_preprocessing(app, plate_num, chan_num, image_file);
    if ~is_parallel_processing
      app.image(chan_num).data = imgs(chan_num).data; % make available to display tab
    end
  end

  %% Perform Segmentation
  if ~is_parallel_processing
    if app.progressdlg.CancelRequested
        return
    end
    app.progressdlg.Message = sprintf('%s\n%s',msg,'Segmenting image...');
    app.progressdlg.Value = (0.33 / NumberOfImages) + ((current_img_number-1) / NumberOfImages);
  end
  % Loop over each configured segment and execute the segmentation algorithm
  seg_result = {};
  for seg_num=1:length(app.segment)
    algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;
    seg_result{seg_num} = do_segmentation(app, seg_num, algo_name, imgs);
  end

  %% Primary Segment Handling
  % Update subcomponent segment-ids to match the id of the primary segment that they are and must be contained in
  primary_seg_num = app.PrimarySegmentDropDown.Value;
  if ~isempty(primary_seg_num) && primary_seg_num > 0 % if primary segment is None/0, skip
    primary_seg_data = seg_result{primary_seg_num}.matrix;
    % Label differently depending on 2 or 3D
    if ndims(primary_seg_data) == 3
      new_bwlabel = @bwlabeln;
    elseif ndims(primary_seg_data) == 2
      new_bwlabel = @bwlabel;
    end
    primary_seg_data = new_bwlabel(primary_seg_data); % Make sure the data is labelled properly
    seg_result{primary_seg_num}.matrix = primary_seg_data;
    % Loop over non-primary segment results and properly set the pixel values to be what is found in the region of the primary id
    for seg_num=1:length(app.segment)
      if seg_num==primary_seg_num % skip primary segment, only operate on subcomponents
        continue
      end
      sub_seg_data = seg_result{seg_num}.matrix; 
      if app.RemoveSecondarySegments_CheckBox.Value
        % Remove all segments found outside of the primary segment.
        new_sub_seg_data = primary_seg_data;
        new_sub_seg_data(~logical(sub_seg_data))=0; % only keep sub-segments that are contained within the primary segment. set the values in the sub-segments to be equal to their primary segment
      else
        % Do not remove all segments found outside of the primary segment.
        new_sub_seg_data = sub_seg_data;
      end
      seg_result{seg_num}.matrix = new_sub_seg_data;
    end
    % Remove primary segments found outside of a chosen secondary segment.
    if app.RemovePrimarySegments_CheckBox.Value
      secondary_seg_data = seg_result{app.RemovePrimarySegmentsOutside.Value}.matrix;
      primary_seg_data(secondary_seg_data==0)=0; % do remove of primary segments found outside of a chosen secondary segment
      primary_seg_data = new_bwlabel(primary_seg_data);
      seg_result{primary_seg_num}.matrix = primary_seg_data;
    end
  end

  %% Perform Measurements
  if ~is_parallel_processing
    if app.progressdlg.CancelRequested
        return
    end
    app.progressdlg.Message = sprintf('%s\n%s',msg,'Measuring image...');
    app.progressdlg.Value = (0.75 / NumberOfImages) + ((current_img_number-1) / NumberOfImages);
  end
  iterTable = table();
  if ~isempty(primary_seg_num)
    % Loop over each configured measurement and execute the measurement code
    for meas_num=1:length(app.measure)
      algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;
      MeasureTable = do_measurement(app, plate, meas_num, algo_name, seg_result, imgs);
      % Remove duplicate columns, keep the column that got there first
      new_col_names = MeasureTable.Properties.VariableNames(~ismember(MeasureTable.Properties.VariableNames,iterTable.Properties.VariableNames));
      MeasureTable = MeasureTable(:,new_col_names);
      if istable(MeasureTable)
        % Check if less segments were found in this segment than the primary one and if so fill in the missing data with NaN for numeric, empty cells, and structs with NaNs
        if exist('primary_seg_data','var') && max(primary_seg_data(:)) > height(MeasureTable)
          desired_height = max(primary_seg_data(:)); % desired height is the number of primary segments
          MeasureTable = append_missing_rows_for_table(MeasureTable, desired_height);
        end
        if ~isempty(iterTable) && height(iterTable) ~= height(MeasureTable)
          msg = sprintf('Two of your configured measurements returned different number of results. For example one plugin measured 4 cells and another measured 100 peroxisomes. We are unable to combine this into the same table. This is usually fixed by using primary segment settings which can force measuring 4 cells OR 100 peroxisomes.');
          title_ = 'User Error - Measurement Result Length Mismatch';
          throw_application_error(app,msg,title_);
        end

        % Append new measurements
        iterTable=[iterTable MeasureTable];
      end
    end

    if isempty(iterTable)
      return
    end

    %% Add X and Y coordinates for each primary label
    if exist('primary_seg_data','var')
        stats = regionprops(primary_seg_data,'centroid');
        centroids = cat(1, stats.Centroid);
        if isempty(centroids)
          return % nothing was found so return
        end
        if size(centroids,1) ~= height(iterTable)
          msg = sprintf('Your primary segment has a different number of segments than were measured by one of your configured measurements. For example one plugin measured 900 peroxisomes but there were only 3 cell primary segments. We are unable to combine this into the same table. Double check your measurement settings and primary segment settings which can force measuring 3 cells OR 900 peroxisomes.');
          title_ = 'User Error - Primary Segment and Measurement Result Length Mismatch';
          throw_application_error(app,msg,title_);
        end

        % Add X and Y coordinates for each primary label
        iterTable.x_coord = round(centroids(:,1));
        iterTable.y_coord = round(centroids(:,2));
        if ndims(primary_seg_data) == 3
          iterTable.z_coord = round(centroids(:,3));
        end
    end

    % Add UUID for each row
    iterTable(:,'ID') = uuid_array(height(iterTable))';

    % Add Plate Metadata
    for col_name=fields(plate.metadata)'
      col_value = plate.metadata.(col_name{:});
      if strcmp(col_name,'Name')
        col_name = 'PlateName'; % change this name to be less ambigious
      end
      iterTable(:,col_name) = {col_value}; % Add metada
    end

    % Add Image Metadata
    for col_name=fields(image_file)'
      col_value = image_file.(col_name{:});
      skip_names = {'channel_nums','chans','plate_num','zslices'};
      if ismember(col_name,skip_names)
        continue % skip some info
      end
      if strcmp(col_name,'name')
        col_name = 'ImageName'; % change this name to be less ambigious
      end
      iterTable(:,col_name) = {col_value}; % Add metada
    end
    
    % Add Well Condition Metadata
    if strcmp(plate.metadata.ImageFileFormat, 'OperettaSplitTiffs')
      iterTable(:,'WellConditions') = plate.wells(image_file.row,image_file.column);
      cell_struct = plate.wells_meta(image_file.row,image_file.column);
      if ~isempty(cell_struct) && ~isempty(cell_struct{:})
        field_names=fieldnames(cell_struct{1,1});  
        for field = 1:size(field_names)
    %     disp(field)       
          iterTable.(char(field_names(field))) = cell(size(iterTable,1),1);       
          iterTable(iterTable.row==image_file.row&iterTable.column==image_file.column,char(field_names(field))) = repmat(cellstr(cell_struct{1,1}.(char(field_names(field)))),[size(iterTable(iterTable.row==image_file.row&iterTable.column==image_file.column,char(field_names(field))),1) 1]);
        end 
      end
    end    
  end
  
  % Save Snapshots to disk. Will refactor at some point
  if ~strcmp(app.measure_snapshot_selection,'No') & app.processing_running
    if strcmp(app.measure_snapshot_selection,'Yes (All)') | (strcmp(app.measure_snapshot_selection,'Yes (1/50)') & mod(current_img_number,50)==0) | (strcmp(app.measure_snapshot_selection,'Yes (1/10)') & mod(current_img_number,10)==0)
      date_str = datestr(now,'yyyymmddTHHMMSS');
      if ~is_parallel_processing
        if app.progressdlg.CancelRequested
            return
        end
        app.progressdlg.Message = sprintf('%s\n%s',msg,'Saving snapshot...');
        app.progressdlg.Value = (0.85 / NumberOfImages) + ((current_img_number-1) / NumberOfImages);
      end
      update_figure(app, imgs, seg_result, iterTable, plate);
      if is_parallel_processing
        h = figure(110+labindex); % create new figure based on parallel worker (ie. labindex)
      else
        h = figure(111); % set focus to display figure
      end
      save_dir = [app.mainDir '\Saved_Snapshots'];
      if ~strcmp(app.SavetoEditField.Value, 'choose a path')
        save_dir = [app.SavetoEditField.Value '\Saved_Snapshots'];
      end
      mkdir(save_dir) % do every time because it's idempotent and won't fail
      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
        filename = sprintf('%s/montage_%s_plate%d_row%d_column%d_field%d_timepoint%d.png', save_dir, date_str, plate_num, imgs_to_process(current_img_number).row, imgs_to_process(current_img_number).column, imgs_to_process(current_img_number).field, imgs_to_process(current_img_number).timepoint);
      else
        filename = sprintf('%s/montage_%s_plate%d_%s.png', save_dir, date_str, plate_num, imgs_to_process(current_img_number).experiment);
      end
      msg = sprintf('Saving Snapshot for image %d to file %s',current_img_number, filename);
      if is_parallel_processing
        send(ProcessingLogQueue,msg);
      else
        app.log_processing_message(app, msg);
      end
      mag = num2str(app.AtMagnificationSpinner.Value);
      export_fig(filename, ['-m' mag]); % save figure as image
    end
  end
  
  if ~is_parallel_processing
    app.progressdlg.Message = sprintf('%s\n%s',msg,'Finished.');
    app.progressdlg.Value = (1 / NumberOfImages) + ((current_img_number-1) / NumberOfImages);
  end
  
  if is_parallel_processing
    send(NewResultCallback,iterTable);
  else
    NewResultCallback(iterTable);
  end
end
