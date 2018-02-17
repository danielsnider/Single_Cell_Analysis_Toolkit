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
    app.preprocess_tabgp = uitabgroup(app.Tab_Preprocess,'Position',[17,20,803,496]);
  end
  tabgp = app.preprocess_tabgp;
  proc_num = length(tabgp.Children)+1;
  app.preprocess{proc_num} = {};

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Preprocess %i',proc_num), ...
    'BackgroundColor', [1 1 1]);
  app.preprocess{proc_num}.tab = tab;

  v_offset = 385;

  % Preprocess name edit field
  function changed_PreprocessName_(app, event)
    changed_PreprocessName(app, proc_num);
  end
  app.preprocess{proc_num}.Name = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @changed_PreprocessName_, true), ...
    'Position', [162,v_offset,200,22]);
  label = uilabel(tab, ...
    'Text', 'Preprocess Name', ...
    'Position', [57,v_offset+5,103,15]);
  v_offset = v_offset - 33;

  % Preprocess channel dropdown
  dropdown = uidropdown(app.preprocess{proc_num}.tab, ...
    'Items', app.input_data.channel_names, ...
    'Position', [162,v_offset,200,22]);
  label = uilabel(app.preprocess{proc_num}.tab, ...
    'Text', 'Preprocess Channel', ...
    'HorizontalAlignment', 'right', ...
    'Position', [34,v_offset+5,117,15]);
  app.preprocess{proc_num}.ChannelDropDown = dropdown;
  app.preprocess{proc_num}.ChannelLabel = label;
  v_offset = v_offset - 33;


  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_PreprocessAlgorithm(app, proc_num, createCallbackFcn);
  app.preprocess{proc_num}.AlgorithmDropDown = uidropdown(tab, ...
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
    delete_preprocess(app, proc_num);
    app.preprocess(proc_num) = [];
    delete(tab);
    if length(app.preprocess) == 0
      delete(app.preprocess_tabgp);
      app.preprocess_tabgp = [];
    end
  end
  delete_button = uibutton(tab, ...
    'Text', [app.Delete_Unicode.Text ''], ...
    'BackgroundColor', [.95 .95 .95], ...
    'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
    'Position', [369,385,26,23]);

  % Switch to new tab
  app.preprocess_tabgp.SelectedTab = app.preprocess{proc_num}.tab;

  % Populate GUI components in new tab
  app.preprocess{proc_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

end
