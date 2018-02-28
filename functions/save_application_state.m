function fun(app)
  try
    % Display log
    app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    app.log_processing_message(app, 'Please wait!');
    app.log_processing_message(app, 'Saving application state...');

    pause(0.1); % enough time for the log text area to appear on screen

    saved_app = app;
    uisave('saved_app');

    app.log_processing_message(app, 'Application state saved');
    app.log_processing_message(app, 'Finished.');

    % Delete log
    delete(app.StartupLogTextArea);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end