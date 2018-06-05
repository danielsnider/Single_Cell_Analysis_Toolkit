function result = fun(app, proc_num, createCallbackFcn)

  % Setup a function needed later (note that functions cannot be defined in loops)
  function ParamOptionalCheckBoxCallback(uiElem, Update, app)
    proc_num = uiElem.UserData.proc_num;
    param = uiElem.UserData.param;
    param_index = uiElem.UserData.param_index;
    val = 'off';
    if uiElem.Value
      val = 'on';
    end
    if ismember(param.type,{'numeric','text','dropdown'})
      app.preprocess{proc_num}.fields{param_index}.Enable = val;
    end
    do_preprocessing_(app,'Update');
  end
 
  function Help_Callback(uiElem, Update, app)
    help_text = uiElem.UserData.help_text;
    param_name = uiElem.UserData.param_name;
    uialert(app.UIFigure,help_text,param_name, 'Icon','info');
  end

  function checkbox = MakeOptionalCheckbox(app, proc_num, param, param_index)
    check_pos = [param_pos(1)-20 param_pos(2)+4 25 15];
    userdata = {}; % context to pass to callback
    userdata.proc_num = proc_num;
    userdata.param = param;
    userdata.param_index = param_index;
    default_state = true;
    default_enable = 'on';
    if isfield(param,'optional_default_state') && isequal(param.optional_default_state,false)
        default_state = false;
        default_enable = 'off';
    end
    checkbox = uicheckbox(app.preprocess{proc_num}.tab, ...
    'Position', check_pos, ...
    'Value', default_state, ...
    'Text', '', ...
    'UserData', userdata, ...
    'ValueChangedFcn', {@ParamOptionalCheckBoxCallback, app});
    if ismember(param.type,{'numeric','text','dropdown'})
      app.preprocess{proc_num}.fields{param_index}.Enable = default_enable;
    end
  end

  % Callback for when parameter value is changed by the user
  function do_preprocessing_(app, Update)
    busy_state_change(app,'busy');
    do_preprocessing_on_current_image(app, proc_num);
    busy_state_change(app,'not busy');
  end

    try
    % Get new selection of algorithm
    algo_name = app.preprocess{proc_num}.AlgorithmDropDown.Value;

    % Delete existing UI components before creating new ones on top
    delete_preprocess(app,[proc_num]);
    
    % Return if no algorithms (3D supports fewer algorithms)
    if isempty(algo_name)
      return
    end

    % Load parameters of the algorithm plugin
    [params, algorithm] = eval(['definition_' algo_name]);
    app.preprocess{proc_num}.algorithm_info = algorithm;
    if ~isfield(app.preprocess{proc_num}.algorithm_info,'maintainer')
      app.preprocess{proc_num}.algorithm_info.maintainer = 'Unknown';
    end
    if ~isfield(app.preprocess{proc_num}.algorithm_info,'supports_3D')
      app.preprocess{proc_num}.algorithm_info.supports_3D = false; % TODO: sanity check that user provided true or false
    end

    % Run button
    app.preprocess{proc_num}.run_button{1} = uibutton(app.preprocess{proc_num}.tab, 'state', ...
      'Text','',...
      'Icon', 'play-button.png', ...
      'Value',0,...
      'BackgroundColor', [.95 .95 .95], ...
      'ValueChangedFcn', createCallbackFcn(app, @do_preprocessing_, true), ...
      'Position', [369,352,26,23]);

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
      if ismember(param.type,{'numeric','text','dropdown','slider','listbox','checkbox'})
        % Set an index number for this component
        if ~isfield(app.preprocess{proc_num},'fields')
          app.preprocess{proc_num}.fields = {};
        end
        field_num = length(app.preprocess{proc_num}.fields) + 1;
        param_index = field_num;
        % Create UI components
        if strcmp(param.type,'numeric')
          app.preprocess{proc_num}.fields{field_num} = uispinner(app.preprocess{proc_num}.tab);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.preprocess{proc_num}.fields{field_num}.Limits = param.limits;
          end
          app.preprocess{proc_num}.fields{field_num}.ValueDisplayFormat = '%g';
        elseif strcmp(param.type,'text')
          app.preprocess{proc_num}.fields{field_num} = uieditfield(app.preprocess{proc_num}.tab);
        elseif strcmp(param.type,'dropdown')
          app.preprocess{proc_num}.fields{field_num} = uidropdown(app.preprocess{proc_num}.tab);
          app.preprocess{proc_num}.fields{field_num}.Items = param.options;
        elseif strcmp(param.type,'checkbox')
          app.preprocess{proc_num}.fields{field_num} = uicheckbox(app.preprocess{proc_num}.tab);
          app.preprocess{proc_num}.fields{field_num}.Text = '';
          param_pos = [param_pos(1) param_pos(2)+4 25 15];
        elseif strcmp(param.type,'listbox')
          app.preprocess{proc_num}.fields{field_num} = uilistbox(app.preprocess{proc_num}.tab, ...
            'Items', param.options, ...
            'Multiselect', 'on');
          v_offset = v_offset - 34;
          param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
        elseif strcmp(param.type,'slider')
          param_pos = [param_pos(1) param_pos(2)+5 param_pos(3) param_pos(4)];
          app.preprocess{proc_num}.fields{field_num} = uislider(app.preprocess{proc_num}.tab, ...
            'MajorTicks', [], ...
            'MajorTickLabels', {}, ...
            'MinorTicks', []);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.preprocess{proc_num}.fields{field_num}.Limits = param.limits;
          end
        end
        app.preprocess{proc_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, @do_preprocessing_, true);
        app.preprocess{proc_num}.fields{field_num}.Position = param_pos;
        app.preprocess{proc_num}.fields{field_num}.Value = param.default;
        app.preprocess{proc_num}.fields{field_num}.UserData.param_idx = idx;
        app.preprocess{proc_num}.labels{field_num} = uilabel(app.preprocess{proc_num}.tab);
        app.preprocess{proc_num}.labels{field_num}.HorizontalAlignment = 'right';
        app.preprocess{proc_num}.labels{field_num}.Position = label_pos;
        app.preprocess{proc_num}.labels{field_num}.Text = param.name;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.preprocess{proc_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, proc_num, param, param_index);
        end

      else
        msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
        title_ = 'Unknown Parameter Type';
        throw_application_error(app,msg,title_);
      end

      % Question mark help button
      if isfield(param,'help') && ~isempty(param.help)
        userdata.help_text = param.help;
        userdata.param_name = param.name;
        if ~isfield(app.preprocess{proc_num},'HelpButton')
          app.preprocess{proc_num}.HelpButton = {};
        end
        help_num = length(app.preprocess{proc_num}.HelpButton) + 1;
        app.preprocess{proc_num}.HelpButton{help_num} = uibutton(app.preprocess{proc_num}.tab, ...
        'Text', '', ... 
        'Icon', 'question-sign.png', ...
        'BackgroundColor', [0.5 0.5 0.5], ...
        'UserData', userdata, ...
        'ButtonPushedFcn', {@Help_Callback, app}, ...  
        'Position', help_pos);
      end 
    end

    % Display help information for this algorithm in the GUI
    algo_help_panel = uipanel(app.preprocess{proc_num}.tab, ...
      'Title',['Algorithm Documentation '], ...
      'Position',[50,60,350,247], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    help_text = uitextarea(algo_help_panel,'Value',algorithm.help, 'Position',[0,0,350,228],'Editable','off');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
