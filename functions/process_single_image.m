function fun(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,NewResultCallback,ProcessingLogQueue,UiAlertQueue)
    msg = sprintf('Processing image %d of %d.',current_img_number,NumberOfImages);
    if is_parallel_processing
      send(ProcessingLogQueue,msg);
    else
      app.log_processing_message(app, msg);
    end
    image_file = imgs_to_process(current_img_number);
    plate_num = image_file.plate_num;
    plate=app.plates(plate_num);

    % % Only OperettaSplitTiffs Image Naming Scheme is Supported
    % if ~strcmp(plate.metadata.ImageFileFormat, 'OperettaSplitTiffs')
    %   body = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "OperettaSplitTiffs".',plate.metadata.ImageFileFormat);
    %   msg={};
    %   msg.body = body;
    %   msg.title = 'Unkown image naming scheme';
    %   msg.type = 'error';
    %   send(UiAlertQueue,msg);
    %   error(msg);
    % end

    % Load all image channels
    imgs = [];
    for chan_num=[image_file.channel_nums]
      % Load Image
       % imgs(chan_num).data= imread(image_file.chans(chan_num).path);
      imgs(chan_num).data = do_preprocessing(app,plate_num,chan_num,image_file.chans(chan_num).path);
    end


    %% Perform Segmentation
    % Loop over each configured segment and execute the segmentation algorithm
    seg_result = {};
    for seg_num=1:length(app.segment)
      algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;
      msg = sprintf('Running segmentation algorithm "%s" on image %d...\n', algo_name, current_img_number);
      if is_parallel_processing
        send(ProcessingLogQueue,msg);
      else
        app.log_processing_message(app, msg);
      end
      seg_result{seg_num} = do_segmentation(app, seg_num, algo_name, imgs);
    end

    %% Primary Segment Handling
    % Update subcomponent segment-ids to match the id of the primary segment that they are and must be contained in
    primary_seg_num = app.PrimarySegmentDropDown.Value;
    primary_seg_data = seg_result{primary_seg_num};
    primary_seg_data = bwlabel(primary_seg_data); % Make sure the data is labelled properly
    seg_result{primary_seg_num} = primary_seg_data;
    NumberOfCells = max(primary_seg_data(:));
    % Loop over non-primary segment results and properly set the pixel values to be what is found in the region of the primary id
    if NumberOfCells > 0
      for seg_num=1:length(app.segment)
        if seg_num==primary_seg_num % skip primary segment, only operate on subcomponents
          continue
        end
        sub_seg_data = seg_result{seg_num};
        new_sub_seg_data = zeros(size(sub_seg_data));
        % Loop over each segment in the primary segment and update the subcomponent value
        for primary_seg_id=1:NumberOfCells
          % Set the subcomponent single segment value to be equal to the primary segment where the primary segment and subcomponent overlay.
          new_sub_seg_data(primary_seg_data==primary_seg_id) = primary_seg_id;
          new_sub_seg_data(sub_seg_data==0)=0;
        end
        seg_result{seg_num} = new_sub_seg_data;
      end
    end

    %% Perform Measurements
    iterTable = table();
    if NumberOfCells > 0
      % Loop over each configured measurement and execute the measurement code
      for meas_num=1:length(app.measure)
        algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;
        msg = sprintf('Running measurement algorithm "%s" on image %d...\n', algo_name, current_img_number);
        if is_parallel_processing
          send(ProcessingLogQueue,msg);
        else
          app.log_processing_message(app, msg);
        end
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

      % Add X and Y coordinates for each primary label
      stats = regionprops(primary_seg_data,'centroid');
      centroids = cat(1, stats.Centroid);
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




    end
    % send(D2,current_img_number/2);
    % iterTable = table();
    % ResultTable = [iterTable; ResultTable];
    if is_parallel_processing
      send(NewResultCallback,iterTable);
    else
      NewResultCallback(iterTable);
    end
  end