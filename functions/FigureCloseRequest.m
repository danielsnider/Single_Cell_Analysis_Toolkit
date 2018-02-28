function fun(app)
  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
  app.log_processing_message(app, 'Please wait!');
  app.log_processing_message(app, 'Saving application state...');

  pause(0.1); % enough time for the log text area to appear on screen

  saved_app = app;
  save('saved_app_last_closed.mat','saved_app');

  app.log_processing_message(app, 'Application state saved');
  app.log_processing_message(app, 'Finished.');

  % Delete log
  delete(app.StartupLogTextArea);
end