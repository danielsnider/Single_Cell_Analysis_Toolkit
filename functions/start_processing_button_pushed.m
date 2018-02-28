function fun(app)
  if length(app.measure)==0
    uialert(app.UIFigure,'You must have at least one measurement configured.','No Measurements', 'Icon','warn');
    return % perhaps this is not needed, check if NewResultQueueCallback can handle no measurements
  end

  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
  pause(0.1); % enough time for the log text area to appear on screen

  % Make buttons visible
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';

  app.ResultTable = [];

  %% EXECUTE MAIN PROCESSING
  start_processing(app);
  
  % Make buttons visible
  app.Button_ViewMeasurements.Visible = 'on';
  app.Button_ExportMeasurements.Visible = 'on';

  % Update Filter Tab
  app.NumberBeforeFiltering.Value = height(app.ResultTable);
  app.NumberAfterFiltering.Value = height(app.ResultTable);
  app.ResultTable_filtered = table();

  
  % Delete log
  delete(app.StartupLogTextArea);
end