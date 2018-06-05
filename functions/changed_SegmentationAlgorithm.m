function result = fun(app, seg_num, createCallbackFcn)

  % Setup a function needed later (note that functions cannot be defined in loops)
  function ParamOptionalCheckBoxCallback(uiElem, Update, app)
    seg_num = uiElem.UserData.seg_num;
    param = uiElem.UserData.param;
    param_index = uiElem.UserData.param_index;
    val = 'off';
    if uiElem.Value
      val = 'on';
    end
    if ismember(param.type,{'numeric','text','dropdown'})
      app.segment{seg_num}.fields{param_index}.Enable = val;
    elseif strcmp(param.type,'segment_dropdown')
      app.segment{seg_num}.SegmentDropDown{param_index}.Enable = val;
    elseif strcmp(param.type,'image_channel_dropdown')
      app.segment{seg_num}.ChannelDropDown{param_index}.Enable = val;
    end
    do_segmentation_(app,'Update');
  end

  function Help_Callback(uiElem, Update, app)
    help_text = uiElem.UserData.help_text;
    param_name = uiElem.UserData.param_name;
    uialert(app.UIFigure,help_text,param_name, 'Icon','info');
  end

  function checkbox = MakeOptionalCheckbox(app, seg_num, param, param_index)
    check_pos = [param_pos(1)-20 param_pos(2)+4 25 15];
    userdata = {}; % context to pass to callback
    userdata.seg_num = seg_num;
    userdata.param = param;
    userdata.param_index = param_index;
    default_state = true;
    default_enable = 'on';
    if isfield(param,'optional_default_state') && isequal(param.optional_default_state,false)
        default_state = false;
        default_enable = 'off';
    end
    checkbox = uicheckbox(app.segment{seg_num}.tab, ...
    'Position', check_pos, ...
    'Value', default_state, ...
    'Text', '', ...
    'UserData', userdata, ...
    'ValueChangedFcn', {@ParamOptionalCheckBoxCallback, app});
    if ismember(param.type,{'numeric','text','dropdown'})
      app.segment{seg_num}.fields{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'segment_dropdown')
      app.segment{seg_num}.SegmentDropDown{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'image_channel_dropdown')
      app.segment{seg_num}.ChannelDropDown{param_index}.Enable = default_enable;
    end
  end

  % Callback for when parameter value is changed by the user
  function do_segmentation_(app, Update)
    if app.segment{seg_num}.run_button{1}.Value
      msg = sprintf('Refreshing segmentation...');
      progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
      'Message',msg,'Indeterminate','on');

      busy_state_change(app, 'busy');
      prev_fig = get(groot,'CurrentFigure'); % Save current figure

      % Preprocess list of input channels to be passed to the plugin
      for idx=1:length(app.segment{seg_num}.ChannelDropDown)
        if isfield(app.segment{seg_num}.ChannelDropDown{idx}.UserData,'ParamOptionalCheck') && ~app.segment{seg_num}.ChannelDropDown{idx}.UserData.Value
          algo_params(length(algo_params)+1) = {false};
          continue
        end
        drop_num = app.segment{seg_num}.ChannelDropDown{idx}.Value;
        chan_name = app.segment{seg_num}.ChannelDropDown{idx}.UserData.chan_names(drop_num);
        plate_num = app.PlateDropDown.Value;
        dep_chan_num = find(strcmp(app.plates(plate_num).chan_names,chan_name));
        image_file = get_current_multi_channel_image(app);
        app.image(dep_chan_num).data = do_preprocessing(app,plate_num,dep_chan_num,image_file);
      end

      app.segment{seg_num}.result = do_segmentation(app, seg_num, algo_name, app.image);
      update_figure(app);
      if ~isempty(prev_fig)
        figure(prev_fig); % Set back current figure to focus
      end
      close(progressdlg);
      busy_state_change(app, 'not busy');
    end
  end

  try
    % Get new selection of algorithm
    algo_name = app.segment{seg_num}.AlgorithmDropDown.Value;

    % Delete existing UI components before creating new ones on top
    delete_segments(app,[seg_num]);

    % Load parameters of the algorithm plugin
    [params, algorithm] = eval(['definition_' algo_name]);
    app.segment{seg_num}.algorithm_info = algorithm;
    if ~isfield(app.segment{seg_num}.algorithm_info,'maintainer')
      app.segment{seg_num}.algorithm_info.maintainer = 'Unknown';
    end
    if ~isfield(app.segment{seg_num}.algorithm_info,'supports_3D')
      app.segment{seg_num}.algorithm_info.supports_3D = false; % TODO: sanity check that user provided true or false
    end

    % Run button
    app.segment{seg_num}.run_button{1} = uibutton(app.segment{seg_num}.tab, 'state', ...
      'Text','',...
      'Icon', 'play-button.png', ...
      'Value',0,...
      'BackgroundColor', [.95 .95 .95], ...
      'ValueChangedFcn', createCallbackFcn(app, @do_segmentation_, true), ...
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
        if ~isfield(app.segment{seg_num},'fields')
          app.segment{seg_num}.fields = {};
        end
        field_num = length(app.segment{seg_num}.fields) + 1;
        param_index = field_num;
        % Create UI components
        if strcmp(param.type,'numeric')
          app.segment{seg_num}.fields{field_num} = uispinner(app.segment{seg_num}.tab);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.segment{seg_num}.fields{field_num}.Limits = param.limits;
          end
          app.segment{seg_num}.fields{field_num}.ValueDisplayFormat = '%g';
        elseif strcmp(param.type,'text')
          app.segment{seg_num}.fields{field_num} = uieditfield(app.segment{seg_num}.tab);
        elseif strcmp(param.type,'dropdown')
          app.segment{seg_num}.fields{field_num} = uidropdown(app.segment{seg_num}.tab);
          app.segment{seg_num}.fields{field_num}.Items = param.options;
        elseif strcmp(param.type,'checkbox')
          app.segment{seg_num}.fields{field_num} = uicheckbox(app.segment{seg_num}.tab);
          app.segment{seg_num}.fields{field_num}.Text = '';
          param_pos = [param_pos(1) param_pos(2)+4 25 15];
        elseif strcmp(param.type,'listbox')
          app.segment{seg_num}.fields{field_num} = uilistbox(app.segment{seg_num}.tab, ...
            'Items', param.options, ...
            'Multiselect', 'on');
          v_offset = v_offset - 34;
          param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
        elseif strcmp(param.type,'slider')
          param_pos = [param_pos(1) param_pos(2)+5 param_pos(3) param_pos(4)];
          app.segment{seg_num}.fields{field_num} = uislider(app.segment{seg_num}.tab, ...
            'MajorTicks', [], ...
            'MajorTickLabels', {}, ...
            'MinorTicks', []);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.segment{seg_num}.fields{field_num}.Limits = param.limits;
          end
        end
        app.segment{seg_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, @do_segmentation_, true);
        app.segment{seg_num}.fields{field_num}.Position = param_pos;
        app.segment{seg_num}.fields{field_num}.Value = param.default;
        app.segment{seg_num}.fields{field_num}.UserData.param_idx = idx;

        app.segment{seg_num}.labels{field_num} = uilabel(app.segment{seg_num}.tab);
        app.segment{seg_num}.labels{field_num}.HorizontalAlignment = 'right';
        app.segment{seg_num}.labels{field_num}.Position = label_pos;
        app.segment{seg_num}.labels{field_num}.Text = param.name;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.segment{seg_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, seg_num, param, param_index);
        end

      % Create segment selection dropdown box
      elseif strcmp(param.type,'segment_dropdown')
        % Set an index number for this component
        if ~isfield(app.segment{seg_num},'SegmentDropDown')
          app.segment{seg_num}.SegmentDropDown = {};
        end
        drop_num = length(app.segment{seg_num}.SegmentDropDown) + 1;
        param_index = drop_num;
        % Create UI components
        dropdown = uidropdown(app.segment{seg_num}.tab, ...
          'Position', param_pos, ...
          'ValueChangedFcn', createCallbackFcn(app, @do_segmentation_, true), ...
          'Items', {} );
        label = uilabel(app.segment{seg_num}.tab, ...
          'Text', param.name, ...
          'HorizontalAlignment', 'right', ...
          'Position', label_pos);
        % Save ui elements
        app.segment{seg_num}.SegmentDropDown{drop_num} = dropdown;
        app.segment{seg_num}.SegmentDropDown{drop_num}.UserData.param_idx = idx;
        app.segment{seg_num}.SegmentDropDownLabel{drop_num} = label;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.segment{seg_num}.SegmentDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, seg_num, param, param_index);
        end

      % Create input channel selection dropdown box
      elseif strcmp(param.type,'image_channel_dropdown')
        % Set an index number for this component
        if ~isfield(app.segment{seg_num},'ChannelDropDown')
          app.segment{seg_num}.ChannelDropDown = {};
        end
        param_index = length(app.segment{seg_num}.ChannelDropDown) + 1;
        % Get channel names based on the currently displaying plate
        plate_num = app.PlateDropDown.Value;
        if ~isnumeric(app.PlateDropDown.Value)
            plate_num=1; % bad startup value
        end
        chan_names = app.plates(plate_num).chan_names;
        chan_nums = app.plates(plate_num).channels;
        % Create UI components
        dropdown = uidropdown(app.segment{seg_num}.tab, ...
          'Items', chan_names, ...
          'ItemsData', chan_nums, ...
          'ValueChangedFcn', createCallbackFcn(app, @do_segmentation_, true), ...
          'Position', param_pos);
        label = uilabel(app.segment{seg_num}.tab, ...
          'Text', param.name, ...
          'HorizontalAlignment', 'right', ...
          'Position', label_pos);
        % Save ui elements
        app.segment{seg_num}.ChannelDropDown{param_index} = dropdown;
        app.segment{seg_num}.ChannelDropDown{param_index}.UserData.param_idx = idx;
        app.segment{seg_num}.ChannelDropDown{param_index}.UserData.chan_names = chan_names;
        app.segment{seg_num}.ChannelDropDownLabel{param_index} = label;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.segment{seg_num}.ChannelDropDown{param_index}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, seg_num, param, param_index);
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
        if ~isfield(app.segment{seg_num},'HelpButton')
          app.segment{seg_num}.HelpButton = {};
        end
        help_num = length(app.segment{seg_num}.HelpButton) + 1;
        app.segment{seg_num}.HelpButton{help_num} = uibutton(app.segment{seg_num}.tab, ...
        'Text', '', ... 
        'Icon', 'question-sign.png', ...
        'BackgroundColor', [0.5 0.5 0.5], ...
        'UserData', userdata, ...
        'ButtonPushedFcn', {@Help_Callback, app}, ...  
        'Position', help_pos);
      end
    end

    % Display help information for this algorithm in the GUI
    algo_help_panel = uipanel(app.segment{seg_num}.tab, ...
      'Title',['Algorithm Documentation '], ...
      'Position',[50,60,350,280], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    help_text = uitextarea(algo_help_panel,'Value',algorithm.help, 'Position',[0,0,350,261],'Editable','off');

    % Fill in the names of segments across the GUI including here
    changed_SegmentName(app);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
