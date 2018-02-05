function result = fun(app, seg_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;

  % Delete existing UI components before creating new ones on top
  component_names = { ...
    'fields', ...
    'labels', ...
    'SegmentDropDown', ...
    'SegmentLabel', ...
    'ChannelDropDown', ...
    'ChannelLabel', ...
  };
  for cid=1:length(component_names)
    comp_name = component_names{cid};
    if isfield(app.segment{seg_num},comp_name)
      for idx=1:length(app.segment{seg_num}.(comp_name))
        delete(app.segment{seg_num}.(comp_name){idx});
      end
      app.segment{seg_num}.(comp_name) = {};
    end
  end


  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 393;
  for idx=1:length(params)
    param = params(idx);

    % Location of GUI component
    v_offset = v_offset - 33;

    param_pos = [620 v_offset 125 22];
    label_pos = [400 v_offset-5 200 22];

    % Callback for when parameter value is changed by the user
    app.segment{seg_num}.do_segmentation = @(app, event) do_segmentation(app, seg_num, algo_name);

    % Correct unavailable user set default value
    if ismember(param.type,{'dropdown','listbox'})
      if ~ismember(param.default, param.options) 
          param.default = param.options{1};
      end
    end
    % Parameter Input Box
    if ismember(param.type,{'numeric','text','dropdown'})
      % Set an index number for this component
      if ~isfield(app.segment{seg_num},'fields')
        app.segment{seg_num}.fields = {};
      end
      field_num = length(app.segment{seg_num}.fields) + 1;
      % Create UI components
      if strcmp(param.type,'numeric')
        app.segment{seg_num}.fields{field_num} = uispinner(app.segment{seg_num}.tab);
        if isfield(param,'limits') & size(param.limits)==[1 2]
          app.segment{seg_num}.fields{field_num}.Limits = param.limits;
        end
      elseif strcmp(param.type,'text')
        app.segment{seg_num}.fields{field_num} = uieditfield(app.segment{seg_num}.tab);
      elseif strcmp(param.type,'dropdown')
        app.segment{seg_num}.fields{field_num} = uidropdown(app.segment{seg_num}.tab);
        app.segment{seg_num}.fields{field_num}.Items = param.options;
      end
      app.segment{seg_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, app.segment{seg_num}.do_segmentation, true);
      app.segment{seg_num}.fields{field_num}.Position = param_pos;
      app.segment{seg_num}.fields{field_num}.Value = param.default;
      app.segment{seg_num}.labels{field_num} = uilabel(app.segment{seg_num}.tab);
      app.segment{seg_num}.labels{field_num}.HorizontalAlignment = 'right';
      app.segment{seg_num}.labels{field_num}.Position = label_pos;
      app.segment{seg_num}.labels{field_num}.Text = param.name;

    % Create segment selection dropdown box
    elseif strcmp(param.type,'segment_dropdown')
      % Set an index number for this component
      if ~isfield(app.segment{seg_num},'SegmentDropDown')
        app.segment{seg_num}.SegmentDropDown = {};
      end
      drop_num = length(app.segment{seg_num}.SegmentDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.segment{seg_num}.tab, ...
        'Position', param_pos);
        'ValueChangedFcn', createCallbackFcn(app, app.segment{seg_num}.do_segmentation, true), ...
        'Items', {}, ...
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
      % Get channel names based on the currently displaying plate
      plate_num = app.PlateDropDown.Value;
      chan_names = app.input_data.plates(plate_num).chan_names;
      chan_nums = app.input_data.plates(plate_num).channels;
      % Create UI components
      dropdown = uidropdown(app.segment{seg_num}.tab, ...
        'Items', chan_names, ...
        'ItemsData', chan_nums, ...
        'ValueChangedFcn', createCallbackFcn(app, app.segment{seg_num}.do_segmentation, true), ...
        'Position', param_pos);
        % 'Items', app.input_data.unique_channels, ...
      label = uilabel(app.segment{seg_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.segment{seg_num}.ChannelDropDown{chan_num} = dropdown;
      app.segment{seg_num}.ChannelLabel{chan_num} = label;

    else
      msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
      errordlg(msg);
      error(msg);
    end


  end


  % app.segment{seg_num}.do_segmentation(app, seg_name, algo_name) % trigger once


  % Fill in the names of segments across the GUI
  changed_SegmentName(app, seg_num);
end
