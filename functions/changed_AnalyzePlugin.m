function result = fun(app, an_num, createCallbackFcn)
  % Get new selection of plugin
  algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;

  % Delete existing UI components before creating new ones on top
  delete_analyze(app,[an_num]);

  % Setup a function needed later (note that functions cannot be defined in loops)
  function ParamOptionalCheckBoxCallback(uiElem, Update, app)
    an_num = uiElem.UserData.an_num;
    param = uiElem.UserData.param;
    param_index = uiElem.UserData.param_index;
    val = 'off';
    if uiElem.Value
      val = 'on';
    end
    if ismember(param.type,{'numeric','text','dropdown'})
      app.analyze{an_num}.fields{param_index}.Enable = val;
    elseif strcmp(param.type,'measurement_dropdown')
      app.analyze{an_num}.MeasurementDropDown{param_index}.Enable = val;
    end
    do_analyze(app, an_num);
  end

  function Help_Callback(uiElem, Update, app)
    help_text = uiElem.UserData.help_text;
    param_name = uiElem.UserData.param_name;
    uialert(app.UIFigure,help_text,param_name, 'Icon','info');
  end

  function checkbox = MakeOptionalCheckbox(app, an_num, param, param_index)
    check_pos = [param_pos(1)-20 param_pos(2)+4 25 15];
    userdata = {}; % context to pass to callback
    userdata.an_num = an_num;
    userdata.param = param;
    userdata.param_index = param_index;
    default_state = true;
    default_enable = 'on';
    if isfield(param,'optional_default_state') && ~isempty(param.optional_default_state)
      default_state = param.optional_default_state;
      default_enable = 'off';
    end
    checkbox = uicheckbox(app.analyze{an_num}.tab, ...
    'Position', check_pos, ...
    'Value', default_state, ...
    'Text', '', ...
    'UserData', userdata, ...
    'ValueChangedFcn', {@ParamOptionalCheckBoxCallback, app});
    if ismember(param.type,{'numeric','text','dropdown'})
      app.analyze{an_num}.fields{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'analyze_dropdown')
      app.analyze{an_num}.MeasurementDropDown{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'image_channel_dropdown')
      app.analyze{an_num}.ChannelDropDown{param_index}.Enable = default_enable;
    end
  end

  % Callback for when parameter value is changed by the user
  function do_analyze_(app, Update)
    do_analyze(app, an_num);
  end

  % Load parameters of the algorithm plugin
  [params, algorithm_name, algorithm_help] = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 419;
  for idx=1:length(params)
    param = params(idx);

    % Location of GUI component
    v_offset = v_offset - 33;

    param_pos = [620 v_offset 125 22];
    label_pos = [400 v_offset-5 200 22];
    help_pos = [param_pos(1)+130 param_pos(2)+1 20 20];
    param_index = NaN;

    % Change spacing if optional parameter to allow space for a checkbox
    if isfield(param,'optional') && ~isempty(param.optional)
      param_pos = [param_pos(1)+20 param_pos(2) param_pos(3)-20 param_pos(4)];
    end

    % Correct unavailable user set default value
    if ismember(param.type,{'dropdown','listbox'})
      if ~ismember(param.default, param.options) 
          param.default = param.options{1};
      end
    end
    % Parameter Input Box
    if ismember(param.type,{'numeric','text','dropdown'})
      % Set an index number for this component
      if ~isfield(app.analyze{an_num},'fields')
        app.analyze{an_num}.fields = {};
      end
      field_num = length(app.analyze{an_num}.fields) + 1;
      param_index = field_num;
      % Create UI components
      if strcmp(param.type,'numeric')
        app.analyze{an_num}.fields{field_num} = uispinner(app.analyze{an_num}.tab);
        if isfield(param,'limits') & size(param.limits)==[1 2]
          app.analyze{an_num}.fields{field_num}.Limits = param.limits;
        end
      elseif strcmp(param.type,'text')
        app.analyze{an_num}.fields{field_num} = uieditfield(app.analyze{an_num}.tab);
      elseif strcmp(param.type,'dropdown')
        app.analyze{an_num}.fields{field_num} = uidropdown(app.analyze{an_num}.tab);
        app.analyze{an_num}.fields{field_num}.Items = param.options;
      end
      app.analyze{an_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, @do_analyze_, true);
      app.analyze{an_num}.fields{field_num}.Position = param_pos;
      app.analyze{an_num}.fields{field_num}.Value = param.default;
      app.analyze{an_num}.labels{field_num} = uilabel(app.analyze{an_num}.tab);
      app.analyze{an_num}.labels{field_num}.HorizontalAlignment = 'right';
      app.analyze{an_num}.labels{field_num}.Position = label_pos;
      app.analyze{an_num}.labels{field_num}.Text = param.name;
      % Handle if this parameter is optional 
      if isfield(param,'optional') && ~isempty(param.optional)
        app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
      end

    % Create analyze selection dropdown box
    elseif strcmp(param.type,'measurement_dropdown')
      % Set an index number for this component
      if ~isfield(app.analyze{an_num},'MeasurementDropDown')
        app.analyze{an_num}.MeasurementDropDown = {};
      end
      drop_num = length(app.analyze{an_num}.MeasurementDropDown) + 1;
      param_index = drop_num;
      % Create UI components
      dropdown = uidropdown(app.analyze{an_num}.tab, ...
        'Position', param_pos, ...
        'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
        'Items', {} );
      label = uilabel(app.analyze{an_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      % Save ui elements
      app.analyze{an_num}.MeasurementDropDown{drop_num} = dropdown;
      app.analyze{an_num}.MeasurementLabel{drop_num} = label;
      % Handle if this parameter is optional 
      if isfield(param,'optional') && ~isempty(param.optional)
        app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
      end

    else
      msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
      uialert(app.UIFigure,msg,'Known Parameter Type', 'Icon','error');
      error(msg);
    end

    % Question mark help button
    if isfield(param,'help') && ~isempty(param.help)
      userdata.help_text = param.help;
      userdata.param_name = param.name;
      if ~isfield(app.analyze{an_num},'HelpButton')
        app.analyze{an_num}.HelpButton = {};
      end
      help_num = length(app.analyze{an_num}.HelpButton) + 1;
      app.analyze{an_num}.HelpButton{help_num} = uibutton(app.analyze{an_num}.tab, ...
      'Text', '', ... 
      'Icon', 'question-sign.png', ...
      'BackgroundColor', [0.5 0.5 0.5], ...
      'UserData', userdata, ...
      'ButtonPushedFcn', {@Help_Callback, app}, ...  
      'Position', help_pos);
    end
  end

  % Display help information for this algorithm in the GUI
  algo_help_panel = uipanel(app.analyze{an_num}.tab, ...
    'Title',['Plugin Documentation '], ...
    'Position',[50,60,350,280], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
  help_text = uitextarea(algo_help_panel,'Value',algorithm_help, 'Position',[0,0,350,261],'Editable','off');

  changed_MeasurementNames(app);

end
