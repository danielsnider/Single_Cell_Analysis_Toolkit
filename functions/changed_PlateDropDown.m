function fun(app)
  try
    % Display log
    app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    pause(0.1); % enough time for the log text area to appear on screen
    
    prev_fig = get(groot,'CurrentFigure'); % Save current figure


    app.display.channel_override = 0;
    draw_display(app);
    start_processing_of_one_image(app);
    update_figure(app);
    app.log_processing_message(app, 'Finished.');

    if ~isempty(prev_fig)
      figure(prev_fig); % Set back current figure to focus
    end

    % Delete log
    delete(app.StartupLogTextArea);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end