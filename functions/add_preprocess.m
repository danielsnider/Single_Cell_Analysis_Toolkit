function fun(app, createCallbackFcn)
  plugin_definitions = dir('./plugins/preprocess/**/definition*');
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
  if isempty(app.preprocess_tabgp)
    app.preprocess_tabgp = uitabgroup(app.Tab_Preprocess,'Position',[17,20,803,477]);
  end
  tabgp = app.preprocess_tabgp;
  proc_num = length(tabgp.Children)+1;
  app.preprocess{proc_num} = {};

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Preprocess %i',proc_num), ...
    'BackgroundColor', [1 1 1]);
  app.preprocess{proc_num}.tab = tab;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_ProprocessAlgorithm(app, proc_num, createCallbackFcn);
  app.preprocess{proc_num}.AlgorithmDropDown = uidropdown(tab, ...
    'Items', plugin_pretty_names, ...
    'ItemsData', plugin_names, ...
    'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
    'Position', [162,327,200,22]);
  label = uilabel(tab, ...
    'Text', 'Algorithm', ...
    'Position', [90,332,57,15]);

  % Preprocess name edit field
  function changed_PreprocessName_(app, event)
    changed_PreprocessName(app, proc_num);
  end
  app.preprocess{proc_num}.Name = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @changed_PreprocessName_, true), ...
    'Position', [162,360,200,22]);
  label = uilabel(tab, ...
    'Text', 'Preprocess Name', ...
    'Position', [57,365,103,15]);

  % Create Titles
  label = uilabel(tab, ...
    'Text', 'Details', ...
    'FontName', 'Yu Gothic UI Light', ...
    'FontSize', 28, ...
    'Position', [70,396,218,41]);
  label = uilabel(tab, ...
    'Text', 'Parameters', ...
    'FontName', 'Yu Gothic UI Light', ...
    'FontSize', 28, ...
    'Position', [480,396,218,41]);

  % Switch to new tab
  app.preprocess_tabgp.SelectedTab = app.preprocess{proc_num}.tab;

  % Populate GUI components in new tab
  app.preprocess{proc_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

end
