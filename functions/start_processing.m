function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  finished_count  = 0; % for progess bar
  app.ResultTable = [];
  images_to_process = [];
  app.ProcessingLogTextArea.Value = '';
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';

  % Get image names that weren't filtered from all plates
  imgs_to_process = [];
  for plate_num=1:length(app.plates)
    plate=app.plates(plate_num);
    num_channels = length(plate.channels);

    if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
      for img_num=1:num_channels:length(app.plates(plate_num).img_files_subset)
        multi_channel_img = {};
        multi_channel_img.channel_nums = plate.channels;
        multi_channel_img.plate_num = plate_num;
        multi_channel_img.chans = [];
        image_file = app.plates(plate_num).img_files_subset(img_num);
        multi_channel_img.row = image_file.row{:};
        multi_channel_img.column = image_file.column{:};
        multi_channel_img.field = image_file.field{:};
        multi_channel_img.timepoint = image_file.timepoint{:};
        multi_channel_img.ImageName = image_file.name;
        for chan_num=[plate.channels]
          image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
          if ~strcmp(plate.metadata.ImageFileFormat, 'OperettaSplitTiffs')
            msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "OperettaSplitTiffs". Aborting.',plate.metadata.ImageFileFormat);
            uialert(app.UIFigure,msg,'Unkown image naming scheme', 'Icon','error');
            error(msg);
          end
          image_filename(16) = num2str(chan_num); % change the channel number
          multi_channel_img.chans(chan_num).folder = image_file.folder;
          multi_channel_img.chans(chan_num).name = image_filename;
          multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_filename];
        end
        imgs_to_process = [imgs_to_process; multi_channel_img];
      end
    elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      imgs_to_process = [imgs_to_process; app.plates(plate_num).img_files_subset];
    end
  end

  % Limit to only one image if requested by check box
  if app.CheckBox_TestRun.Value
    imgs_to_process=imgs_to_process(1);
  end

  NumberOfImages = length(imgs_to_process);

  function ProcessingLogQueueCallback(msg)
    app.log_processing_message(app, msg);
  end
  function UiAlertQueueCallback(msg)
    uialert(app.UIFigure,msg.body,msg.title,'Icon',msg.type);
  end
  function NewResultQueueCallback(iterTable)
      % Resolve missing table columns, they must all be present in both tables before combining
      if ~isempty(app.ResultTable)
          iterTablecolmissing = setdiff(app.ResultTable.Properties.VariableNames, iterTable.Properties.VariableNames);
          ResultTablecolmissing = setdiff(iterTable.Properties.VariableNames, app.ResultTable.Properties.VariableNames);
          iterTable = [iterTable array2table(nan(height(iterTable), numel(iterTablecolmissing)), 'VariableNames', iterTablecolmissing)]; % add missing columns
          app.ResultTable = [app.ResultTable array2table(nan(height(app.ResultTable), numel(ResultTablecolmissing)), 'VariableNames', ResultTablecolmissing)]; % add missing columns
      end

      % Save result
      app.ResultTable = [iterTable; app.ResultTable];

      %% Update Progress Bar
      finished_count = finished_count + 1;
      progress = finished_count/NumberOfImages;
      app.ProgressSlider.Value = progress;
    end

  %% Loop over images and process each one
  if app.CheckBox_Parallel.Value
    app.log_processing_message(app, 'Starting parallel processing pool.');
    ProcessingLogQueue = parallel.pool.DataQueue;
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
    for current_img_number = 1:NumberOfImages
      process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,@NewResultQueueCallback);
    end
  end

  app.log_processing_message(app, 'Finished.');
  app.ProgressSlider.Value = 1; % set progress bar to 100%

  % Make buttons visible
  app.Button_ViewMeasurements.Visible = 'on';
  app.Button_ExportMeasurements.Visible = 'on';
  

  % Update list of measurements in the display tab
  draw_display_measure_selection(app);

end