function iterTable = do_measurement(app, plate, meas_num, algo_name, seg_result, imgs)
  try
    algo_params = {};

    % Create list of algorithm parameter values to be passed to the plugin
    if isfield(app.measure{meas_num},'fields')
      for idx=1:length(app.measure{meas_num}.fields)
        param_idx = app.measure{meas_num}.fields{idx}.UserData.param_idx;
        algo_params(param_idx) = {app.measure{meas_num}.fields{idx}.Value};
      end
    end

    % Collect numbers of segments to measure
    param_types = { ... % known names of UI components
      'SegmentDropDown', ...
      'SegmentListbox' ...
    };
    for param_type=param_types
      if isfield(app.measure{meas_num},param_type)
        for param_num=1:length(app.measure{meas_num}.(param_type{:}))
          param_idx = app.measure{meas_num}.(param_type{:}){param_num}.UserData.param_idx;
          segments_to_measure = app.measure{meas_num}.(param_type{:}){param_num}.Value;

          % Create struct of input segments to be passed to the plugin. Where the key is the name of the segment and value is the image content.
          segment_data = {};
          for seg_num=segments_to_measure
            seg_name = app.segment{seg_num}.Name.Value;
            if strcmp(seg_name,'')
              seg_name = sprintf('Segment %i', seg_num);
            end
            seg_data = seg_result{seg_num};
            segment_data.(genvarname(seg_name)) = seg_data;
          end
          algo_params(param_idx) = {segment_data};
        end
      end
    end

    % Collect names of channels to measure
    param_types = { ... % known names of UI components
      'ChannelDropDown', ...
      'ChannelListbox' ...
    };
    for param_type=param_types
      if isfield(app.measure{meas_num},param_type)
        for param_num=1:length(app.measure{meas_num}.(param_type{:}))
          param_idx = app.measure{meas_num}.(param_type{:}){param_num}.UserData.param_idx;
          channels_to_measure = app.measure{meas_num}.(param_type{:}){param_num}.Value;

          % Keep only the channels which exist in the plate
          if ~isempty(channels_to_measure)
            channels_to_measure = intersect(channels_to_measure,plate.chan_names);
          end

          % Create struct of input channels to be passed to the plugin. Where the key is the name of the channel and value is the image content.
          img_data = {};
          for idx=1:length(channels_to_measure)
            chan_name = channels_to_measure{idx};
            chan_num = find(strcmp(plate.chan_names,chan_name));
            chan_data = imgs(chan_num).data;
            img_data.(genvarname(chan_name)) = chan_data;
          end
          if ~isempty(img_data)
            algo_params(param_idx) = {img_data};
          end
        end
      end
    end

    if isvalid(app.StartupLogTextArea)
      measure_name = app.measure{meas_num}.tab.Title;
      msg = sprintf('%s ''%s.m''', measure_name, algo_name);
      if app.CheckBox_Parallel.Value && app.processing_running
        send(app.ProcessingLogQueue, msg);
      else
        app.log_processing_message(app, msg);
      end
    end
  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

  plugin_name = app.measure{meas_num}.tab.Title;

  try
    % Call algorithm
    iterTable = feval(algo_name, plugin_name, meas_num, algo_params{:});

  % Catch Plugin Error
  catch ME
    handle_plugin_error(app,ME,'measure',meas_num);
  end

  if isvalid(app.StartupLogTextArea)
    new_measurements = strjoin(iterTable.Properties.VariableNames,', ');
    msg = sprintf('%s ''%s.m'' produced columns: %s', measure_name, algo_name, new_measurements);
    if app.CheckBox_Parallel.Value && app.processing_running
      send(app.ProcessingLogQueue, msg);
    else
      app.log_processing_message(app, msg);
    end
  end

end