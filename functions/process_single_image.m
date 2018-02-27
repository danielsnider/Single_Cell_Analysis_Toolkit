function fun(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,NewResultCallback,ProcessingLogQueue,UiAlertQueue)
  
  msg = sprintf('Processing image %d of %d',current_img_number,NumberOfImages);
  if is_parallel_processing
    disp(msg)
%     send(ProcessingLogQueue,msg);
  else
    app.log_processing_message(app, msg);
  end
  image_file = imgs_to_process(current_img_number);
  plate_num = image_file.plate_num;
  plate=app.plates(plate_num);

  % Load all image channels
  imgs = [];
  for chan_num=[image_file.channel_nums]
    % Load Image
     % imgs(chan_num).data= imread(image_file.chans(chan_num).path);
    imgs(chan_num).data = do_preprocessing(app,plate_num,chan_num,image_file.chans(chan_num).path);
    if ~is_parallel_processing
      app.image(chan_num).data = imgs(chan_num).data; % make available to display tab
    end
  end


  %% Perform Segmentation
  % Loop over each configured segment and execute the segmentation algorithm
  seg_result = {};
  for seg_num=1:length(app.segment)
    algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;
    % msg = sprintf('Running segmentation algorithm ''%s.'' on image %d...\n', algo_name, current_img_number);
    % if is_parallel_processing
    %   send(ProcessingLogQueue,msg);
    % else
    %   app.log_processing_message(app, msg);
    %   if isvalid(app.StartupLogTextArea)
    %     app.log_processing_message(app, msg);
    %   end
    % end
    seg_result{seg_num} = do_segmentation(app, seg_num, algo_name, imgs);
  end

  %% Primary Segment Handling
  % Update subcomponent segment-ids to match the id of the primary segment that they are and must be contained in
  primary_seg_num = app.PrimarySegmentDropDown.Value;
  if ~isempty(primary_seg_num)
    primary_seg_data = seg_result{primary_seg_num};
    primary_seg_data = bwlabel(primary_seg_data); % Make sure the data is labelled properly
    seg_result{primary_seg_num} = primary_seg_data;
    NumberOfCells = max(primary_seg_data(:));
    % Loop over non-primary segment results and properly set the pixel values to be what is found in the region of the primary id
    for seg_num=1:length(app.segment)
      if seg_num==primary_seg_num % skip primary segment, only operate on subcomponents
        continue
      end
      sub_seg_data = seg_result{seg_num}; 
      new_sub_seg_data = zeros(size(sub_seg_data)); % create a blank slate
      logical_sub_segment = imreconstruct(logical(primary_seg_data), logical(sub_seg_data)); % only keep sub-segments that are contained within the primary segment
      new_sub_seg_data(find(logical_sub_segment))=primary_seg_data(find(logical_sub_segment)); % set the values in the sub-segments to be equal to their primary segment
      seg_result{seg_num} = new_sub_seg_data;
    end
  end

  %% Perform Measurements
  iterTable = table();
  if ~isempty(primary_seg_num)
    % Loop over each configured measurement and execute the measurement code
    for meas_num=1:length(app.measure)
      algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;
      % msg = sprintf('Running measurement algorithm ''%s.'' on image %d...\n', algo_name, current_img_number);
      % if is_parallel_processing
      %   send(ProcessingLogQueue,msg);
      % else
      %   app.log_processing_message(app, msg);
      %   if isvalid(app.StartupLogTextArea)
      %     app.log_processing_message(app, msg);
      %   end
      % end
      MeasureTable = do_measurement(app, plate, meas_num, algo_name, seg_result, imgs);
      % Remove duplicate columns, keep the column that got there first
      new_col_names = MeasureTable.Properties.VariableNames(~ismember(MeasureTable.Properties.VariableNames,iterTable.Properties.VariableNames));
      MeasureTable = MeasureTable(:,new_col_names);
      % Store new measurements
      if isempty(iterTable)
        iterTable=MeasureTable;
      else
        iterTable=[iterTable MeasureTable];
      end
    end

    if isempty(iterTable)
      return
    end

    %% Add X and Y coordinates for each primary label
    stats = regionprops(primary_seg_data,'centroid');
    centroids = cat(1, stats.Centroid);
    if isempty(centroids)
      return % nothing was found so return
    end
    % Check if less segments were found in this segment than the primary one and if so fill in the missing data with NaN for numeric, empty cells, and structs with NaNs
    if size(centroids,1) > height(iterTable)
      desired_height = length(centroids);
      iterTable = append_missing_rows_for_table(iterTable, desired_height);
    end
    % Add X and Y coordinates for each primary label
    iterTable.x_coord = floor(centroids(:,1));
    iterTable.y_coord = floor(centroids(:,2));

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
      skip_names = {'channel_nums','chans','plate_num'};
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
  if is_parallel_processing
    send(NewResultCallback,iterTable);
  else
    NewResultCallback(iterTable);
  end
end
