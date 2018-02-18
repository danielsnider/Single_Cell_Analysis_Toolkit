    function fun(app, createCallbackFcn)
  plugin_definitions = dir('./plugins/segmentation/**/definition*');
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
  if isempty(app.segment_tabgp)
    app.segment_tabgp = uitabgroup(app.Tab_Segment,'Position',[17,20,803,496]);
  end
  tabgp = app.segment_tabgp;
  seg_num = length(tabgp.Children)+1;
  app.segment{seg_num} = {};

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Segment %i',seg_num), ...
    'BackgroundColor', [1 1 1]);
  app.segment{seg_num}.tab = tab;

  v_offset = 385;

  % Segment name edit field
  function changed_SegmentName_(app, event)
    changed_SegmentName(app);
  end
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
  function Delete_Callback(app, event)
    delete_segments(app, seg_num);
    app.segment(seg_num) = [];
    delete(tab);
    if length(app.segment) == 0
      delete(app.segment_tabgp);
      app.segment_tabgp = [];
    end
    changed_SegmentName(app)
  end
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

  % Populate GUI components in new tab
  app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

end
