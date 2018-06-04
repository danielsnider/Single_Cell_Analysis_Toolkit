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
    app.log_processing_message(app, 'Start processing...');
    pause(0.1);

    % Get image names to process
    if app.CheckBox_TestRun.Value
      % Limit to only one image if requested by check box
      imgs_to_process = [get_current_multi_channel_image(app)];
    else
      % Get image names that weren't filtered from all plates
      imgs_to_process = get_images_to_process(app);
    end

    NumberOfImages = length(imgs_to_process);
    
    %% Loop over images and process each one
    timerOn = false; % Default leave timer off
    if app.CheckBox_Parallel.Value
      tStart = tic; % Start Timer
      timerOn = true; % Track Timer as turned on
      app.log_processing_message(app, 'Starting parallel processing pool.');
      app.log_processing_message(app, 'Please see the Matlab console for further progess messages.');
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
        % if isempty(imgs_to_process(current_img_number).chans)
        %   % The data for the current image is not in memory so load whole series. this is needed because we only load one series at a time into memory
        %   series_name = imgs_to_process(current_img_number).experiment;
        %   series_id = find(strcmp(app.ExperimentDropDown.Items,series_name));
        %   app.ExperimentDropDown.Value = series_id;
        %   plate_num = app.PlateDropDown.Value;
        %   parse_input_structure_XYZCT_Bio_Formats(app,plate_num);
        %   changed_FilterInput(app, plate_num);
        %   % Get image names to process
        %   if app.CheckBox_TestRun.Value
        %     % Limit to only one image if requested by check box
        %     imgs_to_process = [get_current_multi_channel_image(app)];
        %   else
        %     % Get image names that weren't filtered from all plates
        %     imgs_to_process = get_images_to_process(app);
        %   end
        % end

        process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,callback_fnc);
        if app.progressdlg.CancelRequested
            close(app.progressdlg);
            return
        end
      end 
    end

    close(app.progressdlg);
    app.log_processing_message(app, 'Finished.');
    app.ProgressSlider.Value = 1; % set progress bar to 100%
    % delete(gcp('nocreate')); %Shuts down parrallel pool
    
    % Stop Timer
    if timerOn == true
        tEnd = toc(tStart); % Stop Timer
        fprintf('Segmentation took: %d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
    end
    
    % User Automated ResultTable Saving
    % Work on path validation
    if ~strcmp(app.SavetoEditField.Value,'choose a path') &  ~strcmp(app.SavetoEditField.Value,'') & ~isempty(app.ResultTable)
        tStart = tic; % Start Timer
        ResultTable_To_Save = app.ResultTable;
        Check_Object_Memory_Size(ResultTable_To_Save,'ResultTable',app.SavetoEditField.Value);   
        tEnd = toc(tStart); % Stop Timer
        fprintf('Saving ResultTable took: %d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
    elseif isempty(app.SavetoEditField.Value)
        app.SavetoEditField.Value = 'choose a path';
    end
    
%     % Stop Timer
%     if timerOn == true
%         tEnd = toc(tStart); % Stop Timer
%         fprintf('Segmentation took: %d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
%     end
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