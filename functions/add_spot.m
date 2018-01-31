function fun(app, createCallbackFcn)
  spotting_plugins = {'spotA','spotB'};

  % Setup
  if isempty(app.spotting.tabgp)
    app.spotting.tabgp = uitabgroup(app.Tab_Spot,'Position',[15,24,803,331]);
  end
  tabgp = app.spotting.tabgp;
  spot_num = length(tabgp.Children)+1;

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Spot %i',spot_num));
  app.spot{spot_num}.tab = tab;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_SpottingAlgorithm(app, spot_num, createCallbackFcn);
  app.spot{spot_num}.AlgorithmDropDown = uidropdown(tab, ...
    'Items', spotting_plugins, ...
    'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
    'Position', [158,260,100,22]);
  label = uilabel(tab, ...
    'Text', 'Algorithm', ...
    'Position', [86,264,57,15]);

  function NameCallback(app, event)
    tab.Title = sprintf('Spot %i: %s', spot_num, app.spot{spot_num}.SpotName.Value)
  end
  

  % Create seed selection dropdown box
  % NameCallback = @(app, event) tab.Title = sprintf('Spot %i: %s', spot_num, app.spot{spot_num}.SpotName.Value);
  app.spot{spot_num}.SpotName = uieditfield(tab, ...
    'Value', 'Nucleus', ...
    'ValueChangedFcn', createCallbackFcn(app, @NameCallback, true), ...
    'Position', [627,260,100,22]);
  label = uilabel(tab, ...
    'Text', 'Spot Name', ...
    'Position', [520,264,92,15]);

  % Switch to new tab
  app.spotting.tabgp.SelectedTab = app.spot{spot_num}.tab;

  % Populate GUI components in new tab
  app.spot{spot_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update')
end
