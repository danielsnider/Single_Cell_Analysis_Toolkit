function fun(app, createCallbackFcn)
  measure_plugins = {'region_props','subsegments_count','mitosis_detection_saddlepoint'};

  % Setup
  if isempty(app.measure_tabgp)
    app.measure_tabgp = uitabgroup(app.Tab_Measure,'Position',[18,145,795,371]);
  end
  tabgp = app.measure_tabgp;
  meas_num = length(tabgp.Children)+1;

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Measure %i',meas_num), ...
    'BackgroundColor', [1 1 1]);
  app.measure{meas_num}.tab = tab;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_MeasureAlgorithm(app, meas_num, createCallbackFcn);
  app.measure{meas_num}.AlgorithmDropDown = uidropdown(tab, ...
    'Items', measure_plugins, ...
    'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
    'Position', [162,227,200,22]);
  label = uilabel(tab, ...
    'Text', 'Algorithm', ...
    'Position', [57,232,90,15]);

  % Measure name edit field
  function changed_MeasureName(app, event)
    % Update tab title
    if strcmp(app.measure{meas_num}.Name.Value,'')
      app.measure{meas_num}.tab.Title = sprintf('Measure %i', meas_num);
    else
      app.measure{meas_num}.tab.Title = sprintf('Measure %i: %s', meas_num, app.measure{meas_num}.Name.Value);
    end
  end
  app.measure{meas_num}.Name = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @changed_MeasureName, true), ...
    'Position', [162,260,200,22]);
  label = uilabel(tab, ...
    'Text', 'Measure Name', ...
    'Position', [90,265,57,15]);

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

  
  % Update the segment list in the display tab
  draw_display_measure_selection(app);

  % Switch to new tab
  app.measure_tabgp.SelectedTab = app.measure{meas_num}.tab;

  % Populate GUI components in new tab
  app.measure{meas_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

end
