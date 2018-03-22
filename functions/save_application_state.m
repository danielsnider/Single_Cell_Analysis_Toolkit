function fun(app)
  try
    % Display log
%     app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
app.StartupLogTextArea = txt_update;
    app.log_processing_message(app, 'Please wait!');
    app.log_processing_message(app, 'Saving application state...');

    pause(0.1); % enough time for the log text area to appear on screen
    
    % Save Application State
%     saved_app = app;
%     Check_Object_Memory_Size(saved_app,'saved_app','None'); 

    app.log_processing_message(app, 'Application state saved');
    app.log_processing_message(app, 'Finished.');

    % Delete log
%     delete(app.StartupLogTextArea);
% 	app.StartupLogTextArea.tx.String = {};

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end