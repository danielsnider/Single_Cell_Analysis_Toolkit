function fun(app)
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
    if length(app.measure)==0
      uialert(app.UIFigure,'You must have at least one measurement configured.','No Measurements', 'Icon','warn');
      return
    end

    %% Setup
    app.ProgressSlider.Value = 0; % reset progress bar to 0
    finished_count  = 0; % for progess bar
    app.ResultTable = [];
    images_to_process = [];
    app.ProcessingLogTextArea.Value = '';
    app.Button_ViewMeasurements.Visible = 'off';
    app.Button_ExportMeasurements.Visible = 'off';
    app.processing_running = true;

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

    app.processing_running = false;

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end