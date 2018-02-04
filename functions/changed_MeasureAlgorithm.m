function result = fun(app, meas_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;

  % Delete existing UI components before creating new ones on top
  if isfield(app.measure{meas_num},'fields')
    for idx=1:length(app.measure{meas_num}.fields)
      delete(app.measure{meas_num}.fields{idx});
      delete(app.measure{meas_num}.labels{idx});
    end
    app.measure{meas_num}.fields = {};
    app.measure{meas_num}.labels = {};
  end
  if isfield(app.measure{meas_num},'MeasureDropDown')
    for idx=1:length(app.measure{meas_num}.MeasureDropDown)
      delete(app.measure{meas_num}.MeasureDropDown{idx});
      delete(app.measure{meas_num}.MeasureLabel{idx});
    end
    app.measure{meas_num}.MeasureDropDown = {};
    app.measure{meas_num}.MeasureLabel = {};
  end
  if isfield(app.measure{meas_num},'ChannelDropDown')
    for idx=1:length(app.measure{meas_num}.ChannelDropDown)
      delete(app.measure{meas_num}.ChannelDropDown{idx});
      delete(app.measure{meas_num}.ChannelLabel{idx});
    end
    app.measure{meas_num}.ChannelDropDown = {};
    app.measure{meas_num}.ChannelLabel = {};
  end

  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 293;
  for idx=1:length(params)
    param = params(idx);

    % Location of GUI component
    v_offset = v_offset - 33;

    param_pos = [620 v_offset 125 22];
    label_pos = [400 v_offset-5 200 22];

    % Parameter Input Box
    if ismember(param.type,{'numeric','text','dropdown'})
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'fields')
        app.measure{meas_num}.fields = {};
      end
      field_num = length(app.measure{meas_num}.fields) + 1;
      % Create UI components
      if strcmp(param.type,'numeric')
        app.measure{meas_num}.fields{field_num} = uispinner(app.measure{meas_num}.tab);
        if isfield(param,'limits')
          app.measure{meas_num}.fields{field_num}.Limits = param.limits;
        end
      elseif strcmp(param.type,'text')
        app.measure{meas_num}.fields{field_num} = uieditfield(app.measure{meas_num}.tab);
      elseif strcmp(param.type,'dropdown')
        app.measure{meas_num}.fields{field_num} = uidropdown(app.measure{meas_num}.tab);
        app.measure{meas_num}.fields{field_num}.Items = param.options;
        if ~ismember(param.default, param.options) % Correct unavailable user set default value
            param.default = param.options{1};
        end
      end
      app.measure{meas_num}.fields{field_num}.Position = param_pos;
      app.measure{meas_num}.fields{field_num}.Value = param.default;
      app.measure{meas_num}.labels{field_num} = uilabel(app.measure{meas_num}.tab);
      app.measure{meas_num}.labels{field_num}.HorizontalAlignment = 'right';
      app.measure{meas_num}.labels{field_num}.Position = label_pos;
      app.measure{meas_num}.labels{field_num}.Text = param.name;

    % Create segment selection dropdown box
    elseif strcmp(param.type,'segment_dropdown')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'SegmentDropDown')
        app.measure{meas_num}.SegmentDropDown = {};
      end
      drop_num = length(app.measure{meas_num}.SegmentDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.measure{meas_num}.tab, ...
        'Position', param_pos);
        'Items', app.segment_names, ...
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.SegmentDropDown{drop_num} = dropdown;
      app.measure{meas_num}.SegmentLabel{drop_num} = label;

    % Create input channel selection dropdown box
    elseif strcmp(param.type,'image_channel_dropdown')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'ChannelDropDown')
        app.measure{meas_num}.ChannelDropDown = {};
      end
      chan_num = length(app.measure{meas_num}.ChannelDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.measure{meas_num}.tab, ...
        'Items', app.input_data.channel_names, ...
        'Position', param_pos);
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.ChannelDropDown{chan_num} = dropdown;
      app.measure{meas_num}.ChannelLabel{chan_num} = label;
    else
      msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
      errordlg(msg);
      error(msg);
    end

  end

end
