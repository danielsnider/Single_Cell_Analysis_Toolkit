function fun(app, NewResultCallback)
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  function ProcessingLogQueueCallback(msg)
    app.log_processing_message(app, msg);
  end

  function UiAlertQueueCallback(msg)
    uialert(app.UIFigure,msg.body,msg.title,'Icon',msg.type);
  end

  function NewResultQueueCallback(iterTable)
    % Resolve missing table columns, they must all be present in both tables before combining
    [iterTable app.ResultTable] = append_missing_columns_table_pair(iterTable, app.ResultTable);
    
    % Concatenate Results
    app.ResultTable = [iterTable; app.ResultTable];
    
    % For Display
    app.ResultTable_for_display = app.ResultTable;

    %% Update Progress Bar
    finished_count = finished_count + 1;
    progress = finished_count/NumberOfImages;
    app.ProgressSlider.Value = progress;

  end

  try
    %% Setup
    app.ProgressSlider.Value = 0; % reset progress bar to 0
    finished_count  = 0; % for progess bar
    app.ProcessingLogTextArea.Value = '';
    app.processing_running = true;

    % Get image names to process
    if app.CheckBox_TestRun.Value
      % Limit to only one image if requested by check box

      % Currently selected plate number
      plate_num = app.PlateDropDown.Value;

      %% Load Images
      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
        %% Build path to current image from dropdown selections
        image_dir = app.plates(plate_num).metadata.ImageDir;
        plate_file_num = app.plates(plate_num).plate_num; % The plate number in the filename of images
        row = app.RowDropDown.Value;
        column = app.ColumnDropDown.Value;
        field = app.FieldDropDown.Value;
        timepoint = app.TimepointDropDown.Value;

        multi_channel_img = {};
        multi_channel_img.channel_nums = app.plates(plate_num).channels;
        multi_channel_img.plate_num = plate_num;
        multi_channel_img.chans = [];
        multi_channel_img.row = row;
        multi_channel_img.column = column;
        multi_channel_img.field = field;
        multi_channel_img.timepoint = timepoint;
        for chan_num=[app.plates(plate_num).channels]
          image_name = sprintf(...
            'r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
            row,column,field,plate_file_num,chan_num,timepoint);
          image_path = sprintf(...
            '%s/%s', image_dir,image_name);
          if ~exist(image_path) % If the file doesn't exist, reset the dropdown box values and return to avoid updating the figure
            draw_display(app);
            return
          end

          multi_channel_img.ImageName = image_name;
          multi_channel_img.chans(chan_num).folder = image_dir;
          multi_channel_img.chans(chan_num).name = image_name;
          multi_channel_img.chans(chan_num).path = image_path;
        end
      elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
        for chan_num=[app.plates(plate_num).channels]
          img_num = app.ExperimentDropDown.Value;
          multi_channel_img = app.ExperimentDropDown.UserData(img_num);
        end
      end
      imgs_to_process = [multi_channel_img];
      % imgs_to_process = imgs_to_process(1);

    else
      % Get image names that weren't filtered from all plates
      imgs_to_process = get_images_to_process(app);
    end

    NumberOfImages = length(imgs_to_process);

    %% Loop over images and process each one
    if app.CheckBox_Parallel.Value
      app.log_processing_message(app, 'Starting parallel processing pool.');
      ProcessingLogQueue = parallel.pool.DataQueue;
%       disp(ProcessingLogQueue)
      app.ProcessingLogQueue = ProcessingLogQueue;
      afterEach(ProcessingLogQueue, @ProcessingLogQueueCallback);
      UiAlertQueue = parallel.pool.DataQueue;
      afterEach(UiAlertQueue, @UiAlertQueueCallback);
      NewResultQueue = parallel.pool.DataQueue;
      afterEach(NewResultQueue, @NewResultQueueCallback);
      is_parallel_processing = true;

      %% PARALLEL LOOP
      parfor current_img_number = 1:NumberOfImages
        process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,NewResultQueue,ProcessingLogQueue,UiAlertQueue)
      end
    else
      is_parallel_processing = false;
      if nargin==1
        % Default behaviour is to use result handler function defined in this file
        callback_fnc = @NewResultQueueCallback;
      end
      if nargin==2
        % Override default result handler function with the passed in function
        callback_fnc = NewResultCallback;
      end
      for current_img_number = 1:NumberOfImages
        process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,callback_fnc);
      end
    end

    app.log_processing_message(app, 'Finished.');
    app.ProgressSlider.Value = 1; % set progress bar to 100%

    % Update list of measurements in the display tab
    draw_display_measure_selection(app);

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);

    app.processing_running = false;

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end