function fun(app)
  if length(app.measure)==0
    uialert(app.UIFigure,'You must have at least one measurement configured.','No Measurements', 'Icon','warn');
    return % perhaps this is not needed, check if NewResultQueueCallback can handle no measurements
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