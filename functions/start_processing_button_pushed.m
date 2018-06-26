function fun(app, prompt_user)
  if length(app.measure)==0
    uialert(app.UIFigure,'You must have at least one measurement configured.','No Measurements', 'Icon','warn');
    return % perhaps this is not needed, check if NewResultQueueCallback can handle no measurements
  end

  if ~exist('prompt_user')
    prompt_user = true; % default is to ask user questions. We don't want to ask when analyzing immediately
  end

  if check_plugins_for_parallel_proc_support(app);
    return % return if problem
  end

  % Make buttons visible
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';

  busy_state_change(app,'busy');

  app.ResultTable = [];

  %% EXECUTE MAIN PROCESSING
  % Before execution, prompt user if they want to take snapshots of their measurement overlaid images
  if prompt_user
    msg = 'Do you want to save a snapshot of each image to the "Saved_Snapshots" folder? Snapshots are saved with the display tab settings and can display segmentation results.';
    title = 'Save Snapshots';
    app.measure_snapshot_selection = uiconfirm(app.UIFigure,msg,title,...
        'Options',{'Yes (All)','Yes (1/10)','Yes (1/50)','No'},...
        'DefaultOption',4,'CancelOption',4);
  end
  
  start_processing(app);

  %% Save Results To Disk
  if ~isempty(app.ResultTable)
      % ~strcmp(app.SavetoEditField.Value,'choose a path') &  ~strcmp(app.SavetoEditField.Value,'') & 
      tStart = tic; % Start Timer
      ResultTable_To_Save = app.ResultTable;
      save_measurements(app, 'save_both_file_types', 'no_prompt_save_location');
      tEnd = toc(tStart); % Stop Timer
      fprintf('Saving ResultTable took: %d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
  elseif isempty(app.SavetoEditField.Value)
      app.SavetoEditField.Value = 'choose a path';
  end

  if ~isempty(app.ResultTable)
    % Make buttons visible
    app.Button_ViewMeasurements.Visible = 'on';
    app.Button_ExportMeasurements.Visible = 'on';

    % Update Filter Tab
    app.NumberBeforeFiltering.Value = height(app.ResultTable);
    app.NumberAfterFiltering.Value = height(app.ResultTable);
    app.ResultTable_filtered = table();
  end

  busy_state_change(app,'not busy');
  uialert(app.UIFigure,'Processing complete.','Success', 'Icon','success');
  
  % Delete log
%   delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};
end