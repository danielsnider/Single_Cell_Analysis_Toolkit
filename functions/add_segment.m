function fun(app, createCallbackFcn, plugin_identifier)
      % Set the current algorithm if directed toplugin_identifier)

  if no_images_loaded(app)
      return
  end

  function changed_SegmentName_(app, event)
    changed_SegmentName(app);
  end

  function Delete_Callback(app, event)
    if seg_num < length(app.segment)
      uialert(app.UIFigure,'Sorry, there is a bug which prevents you from deleting a Segment which is not the last one.','Sorry', 'Icon','warn');
      return
    end
    
    progressdlg_created_here = false;
    if ~isvalid(app.progressdlg)
      progressdlg_created_here = true;
      app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message','Deleting segment', 'Indeterminate','on');
      assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way
      % pause(0.1);
    end

    delete_segments(app, seg_num);
    app.segment(seg_num) = [];
    delete(tab);
    if length(app.segment) == 0
      delete(app.segment_tabgp);
      app.segment_tabgp = [];
    end
    changed_SegmentName(app)

    if progressdlg_created_here
      % pause(0.1);
      close(app.progressdlg);
    end
  end
  
  try
    if ~isvalid(app.progressdlg)
      app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message','Adding segment', 'Indeterminate','on');
      assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way
      % pause(0.1);
    end

    plate_num = app.PlateDropDown.Value;
    plugin_definitions = dir('./plugins/segmentation/**/definition*.m');
    %save('segment_plugins.mat','plugin_definitions')
    if isempty(plugin_definitions)
        load('segment_plugins.mat');
        handle_exe_mode(app);
    end
    plugin_names = {};
    plugin_pretty_names = {};
    for plugin_num = 1:length(plugin_definitions)
      plugin = plugin_definitions(plugin_num);
      plugin_name = plugin.name(1:end-2);
      if length(app.segment_plugin_definitions) < plugin_num
        [params, algorithm] = eval(plugin_name);
        app.segment_plugin_definitions(plugin_num).params = params;
        app.segment_plugin_definitions(plugin_num).algorithm = algorithm;
      else
        params = app.segment_plugin_definitions(plugin_num).params;
        algorithm = app.segment_plugin_definitions(plugin_num).algorithm;
      end
      if ~isfield(algorithm,'supports_3D_and_2D')
        % plugin supports only 2D or 3D
        if app.plates(plate_num).supports_3D
          if ~isfield(algorithm,'supports_3D') || ~algorithm.supports_3D
            % 2D only
            continue % unsupported plugin due to lack of 3D support
          end
        end
        if ~app.plates(plate_num).supports_3D && isfield(algorithm,'supports_3D') && algorithm.supports_3D
          % 3D only
          continue % unsupported plugin due to it having 3D support
        end
      end
      plugin_name = strsplit(plugin_name,'definition_');
      plugin_names{length(plugin_names)+1} = plugin_name{2};
      plugin_pretty_names{length(plugin_pretty_names)+1} = algorithm.name;
    end


    if isempty(plugin_names)
      msg = 'Sorry, no segmentation plugins found.';
      if app.plates(plate_num).supports_3D
        msg = sprintf('%s There may be no plugins installed for 3D images.',msg)
      end
      uialert(app.UIFigure,msg,'No Plugins', 'Icon','warn');
      close(progressdlg);
      return
    end


    % Setup
    if isempty(app.segment_tabgp)
      app.segment_tabgp = uitabgroup(app.Tab_Segment,'Position',[17,20,803,496]);
    end
    tabgp = app.segment_tabgp;
    seg_num = length(tabgp.Children)+1;
    app.segment{seg_num} = {};
    app.segment{seg_num}.params = params;
    app.segment{seg_num}.algorithm_info = algorithm;

    % Create new tab
    tab = uitab(tabgp,'Title',sprintf('Segment %i',seg_num), ...
      'BackgroundColor', [1 1 1]);
    app.segment{seg_num}.tab = tab;

    v_offset = 385;

    % Segment name edit field
    app.segment{seg_num}.Name = uieditfield(tab, ...
      'Value', '', ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_SegmentName_, true), ...
      'Position', [162,v_offset,200,22]);
    label = uilabel(tab, ...
      'Text', 'Segment Name', ...
      'Position', [57,v_offset+5,90,15]);
    v_offset = v_offset - 33;

    % Create algorithm selection dropdown box
    Callback = @(app, event) changed_SegmentationAlgorithm(app, seg_num, createCallbackFcn);
    app.segment{seg_num}.AlgorithmDropDown = uidropdown(tab, ...
      'Items', plugin_pretty_names, ...
      'ItemsData', plugin_names, ...
      'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
      'Position', [162,v_offset,200,22]);
    label = uilabel(tab, ...
      'Text', 'Algorithm', ...
      'Position', [90,v_offset+5,57,15]);
    v_offset = v_offset - 33;

    % Create Titles
    label = uilabel(tab, ...
      'Text', 'Details', ...
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [70,421,218,41]);
    label = uilabel(tab, ...
      'Text', 'Parameters', ...
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [480,421,218,41]);

    % Delete button
    delete_button = uibutton(tab, ...
      'Text', [app.Delete_Unicode.Text ''], ...
      'BackgroundColor', [.95 .95 .95], ...
      'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
      'Position', [369,385,26,23]);

    %% Set a display color to see in the figure
    app.segment{seg_num}.display_color = [];

    %% Initialize display check box for this channel
    plate_num = app.PlateDropDown.Value; % Currently selected plate number
    
    % Update the segment list in the display tab
    draw_display_segment_selection(app);

    % Switch to new tab
    app.segment_tabgp.SelectedTab = app.segment{seg_num}.tab;

    % Set the current algorithm if directed to
    if exist('plugin_identifier')
      % Sanity Check that plugin name exists
      index = find(strcmp(app.segment{seg_num}.AlgorithmDropDown.Items,plugin_identifier));
      if isempty(index)
        msg = sprintf('An incorrect segmentation algorithm name "%s" has been specified. Please double check the spelling and check what plugin names are available.',plugin_identifier);
        title_ = 'User Error - Incorrect Plugin Name';
        throw_application_error(app,msg,title_)
      end
      % Set plugin name
      algo_name = app.segment{seg_num}.AlgorithmDropDown.ItemsData{index};
      app.segment{seg_num}.AlgorithmDropDown.Value = algo_name;
    end

    % Populate GUI components in new tab
    app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

    if isvalid(app.progressdlg)
      % pause(0.1);
      close(app.progressdlg);
    end
  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
