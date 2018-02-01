function result = fun(app, seg_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;

  % Delete existing UI components before creating new ones on top
  if isfield(app.segment{seg_num},'fields')
    for idx=1:length(app.segment{seg_num}.fields)
      delete(app.segment{seg_num}.fields{idx});
      delete(app.segment{seg_num}.labels{idx});
    end
  end
  if isfield(app.segment{seg_num},'SegmentDropDown')
    for idx=1:length(app.segment{seg_num}.SegmentDropDown)
      delete(app.segment{seg_num}.SegmentDropDown{idx});
      delete(app.segment{seg_num}.SegmentLabel{idx});
    end
  end
  if isfield(app.segment{seg_num},'ChannelDropDown')
    for idx=1:length(app.segment{seg_num}.ChannelDropDown)
      delete(app.segment{seg_num}.ChannelDropDown{idx});
      delete(app.segment{seg_num}.ChannelLabel{idx});
    end
  end

  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 300;
  for idx=1:length(params)
    param = params(idx);

    % Location of GUI component
    v_offset = v_offset - 25;

    param_pos = [600 v_offset 125 22];
    label_pos = [400 v_offset-5 200 22];

    % Callback for when parameter value is changed by the user
    app.segment{seg_num}.Callback = @(app, event) do_segmentation(seg_num, app, algo_name);

    % Parameter Input Box
    if strcmp(param.type,'numeric')
      % Set an index number for this component
      if ~isfield(app.segment{seg_num},'fields')
        app.segment{seg_num}.fields = {};
      end
      field_num = length(app.segment{seg_num}.fields) + 1;
      % Create UI components
      app.segment{seg_num}.fields{field_num} = uispinner(app.segment{seg_num}.tab);
      app.segment{seg_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, app.segment{seg_num}.Callback, true);
      app.segment{seg_num}.fields{field_num}.Position = param_pos;
      app.segment{seg_num}.fields{field_num}.Value = param.default;
      app.segment{seg_num}.labels{field_num} = uilabel(app.segment{seg_num}.tab);
      app.segment{seg_num}.labels{field_num}.HorizontalAlignment = 'right';
      app.segment{seg_num}.labels{field_num}.Position = label_pos;
      app.segment{seg_num}.labels{field_num}.Text = param.name;

    % Create segment selection dropdown box
    elseif strcmp(param.type,'segment_dropdown')
      % Build Segment Names
      segment_names = {};
      for n=1:length(app.segment)
        segment_names{n} = app.segment{n}.Name.Value;
        if strcmp(segment_names{n},'')
          segment_names{n} = sprintf('Segment %i', n);
        end
      end
      % Set an index number for this component
      if ~isfield(app.segment{seg_num},'SegmentDropDown')
        app.segment{seg_num}.SegmentDropDown = {};
      end
      drop_num = length(app.segment{seg_num}.SegmentDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.segment{seg_num}.tab, ...
        'Position', param_pos);
        % 'Items', segment_names, ...
        % 'ItemsData', 1:length(app.segment), ...
      label = uilabel(app.segment{seg_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.segment{seg_num}.SegmentDropDown{drop_num} = dropdown;
      app.segment{seg_num}.SegmentLabel{drop_num} = label;

    % Create input channel selection dropdown box
    elseif strcmp(param.type,'image_channel_dropdown')
      % Set an index number for this component
      if ~isfield(app.segment{seg_num},'ChannelDropDown')
        app.segment{seg_num}.ChannelDropDown = {};
      end
      chan_num = length(app.segment{seg_num}.ChannelDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.segment{seg_num}.tab, ...
        'Items', app.input_data.unique_channels, ...
        'Position', param_pos);
        % 'ItemsData', 1:length(app.segment), ...
      label = uilabel(app.segment{seg_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.segment{seg_num}.ChannelDropDown{chan_num} = dropdown;
      app.segment{seg_num}.ChannelLabel{chan_num} = label;
    else
      error(sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name))
    end

  end

  % app.segment{seg_num}.Callback(app, 'Update') % trigger once
end
