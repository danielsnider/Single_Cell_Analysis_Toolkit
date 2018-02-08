function fun(app)


  % Delete input data plates
  if isfield(app, 'input_data')
    if isfield(app.input_data, 'tabgp')
      delete(app.input_data.tabgp);
    end
  end

  delete_display_segments(app);
  delete_display_channels(app);

  delete_segments(app, [1:length(app.segment)]);
  delete_measures(app, [1:length(app.measure)]);


  app.input_data = {};
  app.plates = {};
  app.segment = {};
  app.segment_tabgp = [];
  app.display = {};
  app.display.segment = {};
  app.display.channel = {};
  app.display.channel_override = 0;
  app.measure = {};
  app.measure_tabgp = [];
  app.measure_overlay_color = [0 1 0];

  app.processing_running = false;


  app.ProcessingLogTextArea.Value = {''};

  app.log_processing_message = @log_processing_message;
  app.log_startup_message = @log_startup_message;


  app.ChooseplatemapEditField.Value = '';
end