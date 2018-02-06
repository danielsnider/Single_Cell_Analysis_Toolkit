function fun(app, createCallbackFcn)
  segmentation_plugins = {'spotA','seed_based_watershedA'};

  % Setup
  if isempty(app.segment_tabgp)
    app.segment_tabgp = uitabgroup(app.Tab_Segment,'Position',[17,20,803,477]);
  end
  tabgp = app.segment_tabgp;
  seg_num = length(tabgp.Children)+1;

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Segment %i',seg_num), ...
    'BackgroundColor', [1 1 1]);
  app.segment{seg_num}.tab = tab;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_SegmentationAlgorithm(app, seg_num, createCallbackFcn);
  app.segment{seg_num}.AlgorithmDropDown = uidropdown(tab, ...
    'Items', segmentation_plugins, ...
    'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
    'Position', [162,360,200,22]);
  label = uilabel(tab, ...
    'Text', 'Algorithm', ...
    'Position', [90,365,57,15]);

  % Segment name edit field
  function changed_SegmentName_(app, event)
    changed_SegmentName(app, seg_num);
  end
  app.segment{seg_num}.Name = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @changed_SegmentName_, true), ...
    'Position', [162,327,200,22]);
  label = uilabel(tab, ...
    'Text', 'Segment Name', ...
    'Position', [57,332,90,15]);

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

  %% Set a display color to see in the figure
  app.segment{seg_num}.display_color = [];

  %% Initialize display check box for this channel
  plate_num = app.PlateDropDown.Value; % Currently selected plate number
  app.plates(plate_num).enabled_segments(seg_num) = 1;
  
  % Update the segment list in the display tab
  draw_display_segment_selection(app);

  % Switch to new tab
  app.segment_tabgp.SelectedTab = app.segment{seg_num}.tab;

  % Populate GUI components in new tab
  app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

end
