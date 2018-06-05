function fun(app, proc_num, chan_num, image_file)
  % Display log
%   app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
  if ~isstruct(app.StartupLogTextArea)
    app.StartupLogTextArea = txt_update;
  end
  pause(0.1); % enough time for the log text area to appear on screen

  prev_fig = get(groot,'CurrentFigure'); % Save current figure
  
  plate_num = app.PlateDropDown.Value;

  % Handle optional parameters
  if nargin==2
    chan_num = get_chan_num_for_proc_num(app, proc_num);
    image_file = get_current_multi_channel_image(app);
  end

  % Do preprocesing
  app.image(chan_num).data = do_preprocessing(app, plate_num, chan_num, image_file);
  update_figure(app);

  if ~isempty(prev_fig)
    figure(prev_fig); % Set back current figure to focus
  end

  % Delete log
%   delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};
end