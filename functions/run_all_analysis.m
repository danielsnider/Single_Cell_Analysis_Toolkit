function run_all_analysis(app);
  % Display log
  app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [126,651,650,105]);
  pause(0.1); % enough time for the log text area to appear on screen

  for an_num=1:length(app.analyze)
    do_analyze(app, an_num);
  end

  % Delete log
  delete(app.StartupLogTextArea);
end