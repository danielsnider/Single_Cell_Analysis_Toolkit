function fun(app)
  try
    % Let user pick data
    [FileName,PathName,FilterIndex] = uigetfile('*.mat','Pick a dataset (.mat)');
    if ~FileName
       return
    end

    % Display log
    app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    pause(0.1); % enough time for the log text area to appear on screen

    % Load data
    app.log_processing_message(app, ['Loading data from ' FileName]);
    vars_struct = load([PathName FileName]);  

    if ~isfield(vars_struct,'ResultTable')
      msg = sprintf('Sorry, the Matlab data file that you chose did not contain the expected variable ''ResultTable''. Please re-open the variable in Matlab, rename the variable to the name ''ResultTable'', save it again to a file, and then loading the data will work.');
      uialert(app.UIFigure,msg,'Data Not Loaded', 'Icon','warn');
      delete(app.StartupLogTextArea);
      return
    end
    
    app.ResultTable = vars_struct.ResultTable;

    app.log_processing_message(app, 'Fininshed.');

    % Update list of measurements in the display tab
    draw_display_measure_selection(app);

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);

    % Make buttons visible
    app.Button_ViewMeasurements.Visible = 'on';
    app.Button_ExportMeasurements.Visible = 'on';

    % Delete log
    delete(app.StartupLogTextArea);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end
