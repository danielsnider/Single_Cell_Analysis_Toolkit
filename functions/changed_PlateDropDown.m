function fun(app)
  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
  pause(0.1); % enough time for the log text area to appear on screen
  
  app.display.channel_override = 0;
  draw_display(app);
  start_processing_of_one_image(app);
  update_figure(app);

  % Delete log
  delete(app.StartupLogTextArea);
end