function fun(app, createCallbackFcn, plugin_identifier)
  if no_images_loaded(app)
      return
  end

  function changed_MeasureName(app, event)
    % Update tab title
    if strcmp(app.measure{meas_num}.Name.Value,'')
      app.measure{meas_num}.tab.Title = sprintf('Measure %i', meas_num);
    else
      app.measure{meas_num}.tab.Title = sprintf('Measure %i: %s', meas_num, app.measure{meas_num}.Name.Value);
    end
  end

  function Delete_Callback(app, event)
    if meas_num < length(app.measure)
      uialert(app.UIFigure,'Sorry, there is a bug which prevents you from deleting a Measure which is not the last one.','Sorry', 'Icon','warn');
      return
    end
    delete_measures(app, meas_num);
    app.measure(meas_num) = [];
    delete(tab);
    if length(app.measure) == 0
      delete(app.measure_tabgp);
      app.measure_tabgp = [];
    end
  end

  try
    if isempty(app.segment)
      msg = sprintf('Cannot add measurement because no segments have been configured. Please add a segment before measuring it.');
      uialert(app.UIFigure,msg,'Missing Segments', 'Icon','info');
      return
    end

    plate_num = app.PlateDropDown.Value;
    plugin_definitions = dir('./plugins/measurements/**/definition*.m');
    %save('measure_plugins.mat','plugin_definitions')
    if isempty(plugin_definitions)
        load('measure_plugins.mat');
    end
    plugin_names = {};
    plugin_pretty_names = {};
    for plugin_num = 1:length(plugin_definitions)
      plugin = plugin_definitions(plugin_num);
      plugin_name = plugin.name(1:end-2);
      [params, algorithm] = eval(plugin_name);
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
      msg = 'Sorry, no measurement plugins found.';
      if app.plates(plate_num).supports_3D
        msg = sprintf('%s There may be no plugins installed for 3D images.',msg)
      end
      uialert(app.UIFigure,msg,'No Plugins', 'Icon','warn');
      return
    end

    % Setup
    if isempty(app.measure_tabgp)
      app.measure_tabgp = uitabgroup(app.Tab_Measure,'Position',[17,145,803,371]);
    end
    tabgp = app.measure_tabgp;
    meas_num = length(tabgp.Children)+1;

    % Create new tab
    tab = uitab(tabgp,'Title',sprintf('Measure %i',meas_num), ...
      'BackgroundColor', [1 1 1]);
    app.measure{meas_num}.tab = tab;
    app.measure{meas_num}.params = params;
    app.measure{meas_num}.algorithm_info = algorithm;

    % Create algorithm selection dropdown box
    Callback = @(app, event) changed_MeasureAlgorithm(app, meas_num, createCallbackFcn);
    app.measure{meas_num}.AlgorithmDropDown = uidropdown(tab, ...
      'Items', plugin_pretty_names, ...
      'ItemsData', plugin_names, ...
      'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
      'Position', [162,227,200,22]);
    label = uilabel(tab, ...
      'Text', 'Algorithm', ...
      'Position', [90,232,57,15]);

    % Measure name edit field
    app.measure{meas_num}.Name = uieditfield(tab, ...
      'Value', '', ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_MeasureName, true), ...
      'Position', [162,260,200,22]);
    label = uilabel(tab, ...
      'Text', 'Measure Name', ...
      'Position', [57,265,90,15]);

    % Create Titles
    label = uilabel(tab, ...
      'Text', 'Details', ...  
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [70,296,218,41]);
    label = uilabel(tab, ...
      'Text', 'Parameters', ...
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [480,296,218,41]);

    % Delete button
    delete_button = uibutton(tab, ...
      'Text', [app.Delete_Unicode.Text ''], ...
      'BackgroundColor', [.95 .95 .95], ...
      'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
      'Position', [369,260,26,23]);

    
    % Update the segment list in the display tab
    draw_display_measure_selection(app);

    % Switch to new tab
    app.measure_tabgp.SelectedTab = app.measure{meas_num}.tab;

    % Set the current algorithm if directed to
    if exist('plugin_identifier')
      app.measure{meas_num}.AlgorithmDropDown.Value = app.measure{meas_num}.AlgorithmDropDown.ItemsData{find(strcmp(app.measure{meas_num}.AlgorithmDropDown.Items,plugin_identifier))};
    end

    % Populate GUI components in new tab
    app.measure{meas_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
