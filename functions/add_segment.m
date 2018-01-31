function fun(app, createCallbackFcn)
  segmentation_plugins = {'seed_based_watershedA','seed_based_watershedB'};

  % Setup
  if isempty(app.segmentation.tabgp)
    app.segmentation.tabgp = uitabgroup(app.Tab_Segment,'Position',[15,24,803,331]);
  end
  tabgp = app.segmentation.tabgp;
  seg_num = length(tabgp.Children)+1;

  % Create new tab
  tab = uitab(tabgp,'Title',sprintf('Segment %i',seg_num));
  app.segment{seg_num}.tab = tab;

  % Create algorithm selection dropdown box
  Callback = @(app, event) changed_SegmentationAlgorithm(app, seg_num, createCallbackFcn);
  app.segment{seg_num}.AlgorithmDropDown = uidropdown(tab, ...
    'Items', segmentation_plugins, ...
    'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
    'Position', [162,220,100,22]);
  label = uilabel(tab, ...
    'Text', 'Algorithm', ...
    'Position', [90,224,57,15]);

  % Create seed selection dropdown box
  app.segment{seg_num}.SeedDropDown = uidropdown(tab, ...
    'Items', {'Nucleus'}, ...
    'ItemsData', [1], ...
    'Position', [627,260,100,22]);
    % 'Items', app.spotting.names, ...
  label = uilabel(tab, ...
    'Text', 'Spot Using', ...
    'Position', [520,264,92,15]);

  % Segment name edit field
  function NameCallback(app, event)
    tab.Title = sprintf('Segment %i: %s', seg_num, app.segment{seg_num}.SegmentName.Value)
  end
  app.segment{seg_num}.SegmentName = uieditfield(tab, ...
    'Value', '', ...
    'ValueChangedFcn', createCallbackFcn(app, @NameCallback, true), ...
    'Position', [162,257,100,22]);
  label = uilabel(tab, ...
    'Text', 'Segment Name', ...
    'Position', [57,261,90,15]);

  % 283,261,92,15 label input
  % 390,257,100,22 dropdown input



  % Switch to new tab
  app.segmentation.tabgp.SelectedTab = app.segment{seg_num}.tab;

  % Populate GUI components in new tab
  app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update')
end
