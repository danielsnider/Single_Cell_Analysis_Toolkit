function fun(app)


  % Delete input data plates
  if isfield(app, 'input_data')
    if isfield(app.input_data, 'tabgp')
      delete(app.input_data.tabgp);
    end
  end

  delete_display_segments(app);
  delete_display_channels(app);

  % delete_segments(app, [1:length(app.segment)]);
  % delete_measures(app, [1:length(app.measure)]);
  if any(ismember(fields(app),'preprocess_tabgp'))
    delete(app.preprocess_tabgp);
    app.preprocess_tabgp = [];
    app.preprocess = [];
  end
  if any(ismember(fields(app),'segment_tabgp'))
    delete(app.segment_tabgp);
    app.segment_tabgp = [];
    app.segment = [];
  end
  if any(ismember(fields(app),'measure_tabgp'))
    delete(app.measure_tabgp);
    app.measure_tabgp = [];
    app.measure = [];
  end
  if any(ismember(fields(app),'analyze_tabgp'))
    delete(app.analyze_tabgp);
    app.analyze_tabgp = [];
    app.analyze = [];
  end


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
  app.analyze = {};
  app.analyze_tabgp = [];

  app.Button_RunAllAnalysis.Visible = 'off';
  app.Button_ViewMeasurements.Visible = 'off';
  app.Button_ExportMeasurements.Visible = 'off';
  app.ProcessingLogTextArea.Value = {''};

  app.log_processing_message = @log_processing_message;
  app.log_startup_message = @log_startup_message;


  app.ChooseplatemapEditField.Value = '';
end