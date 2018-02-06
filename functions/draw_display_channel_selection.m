function fun(app)

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Delete UI components that were there before
  for chan_num=1:length(app.display.channel)    
      delete(app.display.channel{chan_num}.checkbox);
      delete(app.display.channel{chan_num}.label);
      delete(app.display.channel{chan_num}.min_slider);
      delete(app.display.channel{chan_num}.max_slider);
      delete(app.display.channel{chan_num}.min_label);
      delete(app.display.channel{chan_num}.max_label);
      delete(app.display.channel{chan_num}.color_picker);
      delete(app.display.channel{chan_num}.focus);
  end
  app.display.channel = {};


  function CheckCallback(uiElem, Update, app, plate_num, chan_num)
    app.display.channel_override = false;
    app.plates(plate_num).enabled_channels(chan_num) = app.display.channel{chan_num}.checkbox.Value;
    update_figure(app);
  end

  function ColorPicker_Callback(uiElem, Update, app, plate_num, chan_num)
    app.display.channel_override = false;
    current_RGB = app.plates(plate_num).channel_colors(chan_num,:);
    new_RGB = uisetcolor(current_RGB);
    app.plates(plate_num).channel_colors(chan_num,:) = new_RGB;
    update_figure(app);
  end

  function MinSlider_Callback(uiElem, Update, app, plate_num, chan_num)
    app.plates(plate_num).channel_min(chan_num) = app.display.channel{chan_num}.min_slider.Value;
    update_figure(app);
  end
  function MaxSlider_Callback(uiElem, Update, app, plate_num, chan_num)
    app.plates(plate_num).channel_max(chan_num) = app.display.channel{chan_num}.max_slider.Value;
    update_figure(app);
  end

  function Focus_Callback(uiElem, Update, app, plate_num, chan_num)
    app.display.channel_override = chan_num;
    % Focus check boxes so that only one is checked
    for chan_num_idx = [app.plates(plate_num).channels]
      if chan_num == chan_num_idx
        app.display.channel{chan_num_idx}.checkbox.Value = 1;
        app.plates(plate_num).enabled_channels(chan_num_idx) = 1;
        continue
      end
      app.display.channel{chan_num_idx}.checkbox.Value = 0;
      app.plates(plate_num).enabled_channels(chan_num_idx) = 0;
    end
    update_figure(app);
  end

  v_offset = 325;

  % Loop over channels
  for chan_num=[app.plates(plate_num).channels]
    % Location of GUI component
    check_pos = [239,v_offset+4,25,15]; % 309
    label_pos = [256,v_offset+4,61,15]; % 309
    color_picker_pos = [382,v_offset,28,24]; % 305
    focus_pos = [413,v_offset,29,24]; % 305
    min_slider_pos = [320,v_offset+17,25,3]; % 322
    max_slider_pos = [320,v_offset+1,25,3]; % 306
    min_label_pos = [355,v_offset+13,25,15]; % 318
    max_label_pos = [355,v_offset-4,28,15]; % 301

    % Check Box
    app.display.channel{chan_num}.checkbox = uicheckbox(app.Tab_Display, ...
      'Position', check_pos, ...
      'Value', app.plates(plate_num).enabled_channels(chan_num), ...
      'Text', '', ...
      'ValueChangedFcn', {@CheckCallback, app, plate_num, chan_num});

    % Channel Label
    app.display.channel{chan_num}.label = uilabel(app.Tab_Display, ...
      'Text', app.plates(plate_num).chan_names{chan_num}, ...
      'Position', label_pos);

    % Min Slider
    app.display.channel{chan_num}.min_slider = uislider(app.Tab_Display, ...
      'MajorTicks', [], ...
      'MajorTickLabels', {}, ...
      'MinorTicks', [], ...
      'Value', app.plates(plate_num).channel_min(chan_num), ...
      'ValueChangedFcn', {@MinSlider_Callback, app, plate_num, chan_num}, ...
      'Position', min_slider_pos);

    % Max Slider
    app.display.channel{chan_num}.max_slider = uislider(app.Tab_Display, ...
      'MajorTicks', [], ...
      'MajorTickLabels', {}, ...
      'MinorTicks', [], ...
      'Value', app.plates(plate_num).channel_max(chan_num), ...
      'ValueChangedFcn', {@MaxSlider_Callback, app, plate_num, chan_num}, ...
      'Position', max_slider_pos);

    % Slider Labels
    app.display.channel{chan_num}.min_label = uilabel(app.Tab_Display, ...
      'Text', 'min', ...
      'FontSize', 12, ...
      'FontName', 'Yu Gothic', ...
      'Position', min_label_pos);
    app.display.channel{chan_num}.max_label = uilabel(app.Tab_Display, ...
      'Text', 'max', ...
      'FontSize', 12, ...
      'FontName', 'Yu Gothic', ...
      'Position', max_label_pos);

    % Colour Picker
    app.display.channel{chan_num}.color_picker = uibutton(app.Tab_Display, ...
      'Text', '', ...
      'Icon', 'painter-palette.png', ...
      'BackgroundColor', [.3,.75,.9], ...
      'ButtonPushedFcn', {@ColorPicker_Callback, app, plate_num, chan_num}, ...
      'Position', color_picker_pos);

    % Focus Button
    app.display.channel{chan_num}.focus = uibutton(app.Tab_Display, ...
      'Text', '', ...
      'Icon', 'eye.png', ...
      'ButtonPushedFcn', {@Focus_Callback, app, plate_num, chan_num}, ...
      'BackgroundColor', [.3,.75,.9], ...
      'Position', focus_pos);

    v_offset = v_offset - 35;
  end



end