function fun(app, createCallbackFcn)
  plugin_definitions = dir('./plugins/analyze/**/definition*');
  plugin_names = {};
  plugin_pretty_names = {};
  for plugin_num = 1:length(plugin_definitions)
    plugin = plugin_definitions(plugin_num);
    plugin_name = plugin.name(1:end-2);
    [params, algorithm_name, algorithm_help] = eval(plugin_name);
    plugin_name = strsplit(plugin_name,'definition_');
    plugin_names{plugin_num} = plugin_name{2};
    plugin_pretty_names{plugin_num} = algorithm_name;
  end

  % Setup
  if isempty(app.analyze_tabgp)
    app.analyze_tabgp = uitabgroup(app.Tab_Analyze,'Position',[17,20,803,496]);
  end
  tabgp = app.analyze_tabgp;
  an_num = length(tabgp.Children)+1;
  app.analyze{an_num} = {};

  app.Button_RunAllAnalysis.Visible = 'on';

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Analyze %i',an_num), ...
    'BackgroundColor', [1 1 1]);
  app.analyze{an_num}.tab = tab;

  v_offset = 385;

  % Analyze name edit field
  function changed_AnalyzeName(app, event)
    if strcmp(app.analyze{an_num}.Name.Value,'')
      app.analyze{an_num}.tab.Title = sprintf('Analysis %i', an_num);
    else
      app.analyze{an_num}.tab.Title = sprintf('Analysis %i: %s', an_num, app.analyze{an_num}.Name.Value);
    end
  end
  app.analyze{an_num}.Name = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @changed_AnalyzeName, true), ...
    'Position', [162,v_offset,200,22]);
  label = uilabel(tab, ...
    'Text', 'Analyze Name', ...
    'Position', [57,v_offset+5,90,15]);
  v_offset = v_offset - 33;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_AnalyzePlugin(app, an_num, createCallbackFcn);
  app.analyze{an_num}.AlgorithmDropDown = uidropdown(tab, ...
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
  function Delete_Callback(app, event)
    delete_analyze(app, an_num);
    app.analyze(an_num) = [];
    delete(tab);
    if length(app.analyze) == 0
      delete(app.analyze_tabgp);
      app.analyze_tabgp = [];
      app.Button_RunAllAnalysis.Visible = 'off';
    end
  end
  delete_button = uibutton(tab, ...
    'Text', [app.Delete_Unicode.Text ''], ...
    'BackgroundColor', [.95 .95 .95], ...
    'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
    'Position', [369,385,26,23]);

  %% Set a display color to see in the figure
  app.analyze{an_num}.display_color = [];

  %% Initialize display check box for this channel
  plate_num = app.PlateDropDown.Value; % Currently selected plate number
  
  % Switch to new tab
  app.analyze_tabgp.SelectedTab = app.analyze{an_num}.tab;

  % Populate GUI components in new tab
  app.analyze{an_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');


  % % Create new tab
  % tab = uitab(app.Tab_Analyze,'Title',plugin_pretty_name, ...
  %   'BackgroundColor', [1 1 1]);
  % app.analyze{an_num}.tab = tab;

  % v_offset = 385;

  % % Create Titles
  % label = uilabel(tab, ...
  %   'Text', plugin_pretty_name, ...
  %   'FontName', 'Yu Gothic UI Light', ...
  %   'FontSize', 28, ...
  %   'Position', [70,421,218,41]);
  % label = uilabel(tab, ...
  %   'Text', 'Parameters', ...
  %   'FontName', 'Yu Gothic UI Light', ...
  %   'FontSize', 28, ...
  %   'Position', [480,421,218,41]);

  % % Load parameters of the plugin
  % [params, algorithm_name, algorithm_help] = eval(['definition_' algo_name]);

  % % Draw plugin
  % draw_analyze_plugin(app, params, algorithm_name, createCallbackFcn);


end