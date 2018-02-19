function fun(app, createCallbackFcn)

  function changed_MeasureName(app, event)
    % Update tab title
    if strcmp(app.measure{meas_num}.Name.Value,'')
      app.measure{meas_num}.tab.Title = sprintf('Measure %i', meas_num);
    else
      app.measure{meas_num}.tab.Title = sprintf('Measure %i: %s', meas_num, app.measure{meas_num}.Name.Value);
    end
  end

  function Delete_Callback(app, event)
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

    plugin_definitions = dir('./plugins/measurements/**/definition*');
    plugin_names = {};
    plugin_pretty_names = {};
    for plugin_num = 1:length(plugin_definitions)
      plugin = plugin_definitions(plugin_num);
      plugin_name = plugin.name(1:end-2);
      [params, algorithm] = eval(plugin_name);
      plugin_name = strsplit(plugin_name,'definition_');
      plugin_names{plugin_num} = plugin_name{2};
      plugin_pretty_names{plugin_num} = algorithm.name;
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
    if ~isfield(app.measure{meas_num}.algorithm_info,'maintainer')
      app.measure{meas_num}.algorithm_info.maintainer = 'Unknown';
    end

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

    % Populate GUI components in new tab
    app.measure{meas_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
