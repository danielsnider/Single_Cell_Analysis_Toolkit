function fun(app)
  %% Setup
  app.ProgressSlider.Value = 0; % reset progress bar to 0
  finished_count  = 0; % for progess bar
  app.ResultTable = [];
  images_to_process = [];
  app.ProcessingLogTextArea.Value = '';
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';

  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
  pause(0.1); % enough time for the log text area to appear on screen

  % Get image names that weren't filtered from all plates
  imgs_to_process = get_images_to_process(app);

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

  % Update list of measurements in the analyze tab
  changed_MeasurementNames(app);

  % Delete log
  delete(app.StartupLogTextArea);
end