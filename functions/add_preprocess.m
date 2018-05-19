function fun(app, createCallbackFcn)
  
  function Delete_Callback(app, event)
    if proc_num < length(app.preprocess)
      uialert(app.UIFigure,'Sorry, there is a bug which prevents you from deleting a Preprocess which is not the last one.','Sorry', 'Icon','warn');
      return
    end
    plate_num = app.PlateDropDown.Value;
    chan_num = get_chan_num_for_proc_num(app, proc_num);
    img_path = get_current_image_path(app, chan_num);
    delete_preprocess(app, proc_num);
    app.preprocess(proc_num) = [];
    delete(tab);
    if length(app.preprocess) == 0
      delete(app.preprocess_tabgp);
      app.preprocess_tabgp = [];
    end
    % Preprocess this image without the preprocess operation that was just deleted
    do_preprocessing_on_current_image(app, proc_num, chan_num, img_path);
  end

  function changed_PreprocessName_(app, event)
    changed_PreprocessName(app, proc_num);
  end

  function InputChannelChangedCallback(app, event)
    do_preprocessing_on_current_image(app, proc_num);
  end

  try
    plate_num = app.PlateDropDown.Value;
    plugin_definitions = dir('./plugins/preprocess/**/definition*.m');
    if isempty(plugin_definitions)
        load('preprocess_plugins.mat');
    end
    plugin_names = {};
    plugin_pretty_names = {};
    for plugin_num = 1:length(plugin_definitions)
      plugin = plugin_definitions(plugin_num);
      plugin_name = plugin.name(1:end-2);
      [params, algorithm] = eval(plugin_name);
      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'XYZCT-Bio-Formats')
        if ~isfield(algorithm,'supports_3D') || ~algorithm.supports_3D
          continue % unsupported plugin due to lack of 3D support
        end
      end
      plugin_name = strsplit(plugin_name,'definition_');
      plugin_names{length(plugin_names)+1} = plugin_name{2};
      plugin_pretty_names{length(plugin_pretty_names)+1} = algorithm.name;
    end

    if isempty(plugin_names)
      msg = 'Sorry, no preprocess plugins found.';
      if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'XYZCT-Bio-Formats')
        msg = sprintf('%s There may be no plugins installed for 3D images.',msg)
      end
      uialert(app.UIFigure,msg,'No Plugins', 'Icon','warn');
      return
    end

    % Setup
    if isempty(app.preprocess_tabgp)
      app.preprocess_tabgp = uitabgroup(app.Tab_Preprocess,'Position',[17,20,803,496]);
    end
    tabgp = app.preprocess_tabgp;
    proc_num = length(tabgp.Children)+1;
    app.preprocess{proc_num} = {};
    app.preprocess{proc_num}.params = params;
    app.preprocess{proc_num}.algorithm_info = algorithm;
    if ~isfield(app.preprocess{proc_num}.algorithm_info,'maintainer')
      app.preprocess{proc_num}.algorithm_info.maintainer = 'Unknown';
    end

    % Create new tab
    tab = uitab(tabgp,'Title',sprintf('Preprocess %i',proc_num), ...
      'BackgroundColor', [1 1 1]);
    app.preprocess{proc_num}.tab = tab;

    v_offset = 385;

    % Preprocess name edit field
    app.preprocess{proc_num}.Name = uieditfield(tab, ...
      'Value', '', ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_PreprocessName_, true), ...
      'Position', [162,v_offset,200,22]);
    label = uilabel(tab, ...
      'Text', 'Preprocess Name', ...
      'Position', [57,v_offset+5,103,15]);
    v_offset = v_offset - 33;

    % Preprocess channel dropdown
    channel_names = get_enabled_channel_names(app);
    dropdown = uidropdown(app.preprocess{proc_num}.tab, ...
      'Items', channel_names, ...
      'ValueChangedFcn', createCallbackFcn(app, @InputChannelChangedCallback, true), ...
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
    delete_button = uibutton(tab, ...
      'Text', [app.Delete_Unicode.Text ''], ...
      'BackgroundColor', [.95 .95 .95], ...
      'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
      'Position', [369,385,26,23]);

    % Switch to new tab
    app.preprocess_tabgp.SelectedTab = app.preprocess{proc_num}.tab;

    % Populate GUI components in new tab
    app.preprocess{proc_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
