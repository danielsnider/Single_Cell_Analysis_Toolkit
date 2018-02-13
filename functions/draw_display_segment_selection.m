function fun(app)

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Delete UI components that were there before
  delete_display_segments(app);
  
  function CheckCallback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  function Gain_Slider_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  function ColorPicker_Callback(uiElem, Update, app, plate_num, seg_num)
    enabled = app.display.segment{seg_num}.color_picker.Value;
    if enabled
      current_RGB = app.segment{seg_num}.display_color;
      new_RGB = uisetcolor(current_RGB);
      app.segment{seg_num}.display_color = new_RGB;
    else
      app.segment{seg_num}.display_color = [];
    end
    update_figure(app);
  end

  function Perimeter_Toggle_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  function Perimeter_Thickness_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  v_offset = 335;

  % Loop over segments
  for seg_num=1:length(app.segment)
    % Location of GUI component
    check_pos = [470,v_offset,25,15]; % 309
    label_pos = [487,v_offset,61,15]; % 309
    gain_pos = [552,v_offset-5,3,24]; % 304
    color_picker_pos = [563,v_offset-4,27,24]; % 306
    perimeter_toggle_pos = [593,v_offset-4,29,24]; % 306
    perimeter_thickness_pos = [625,v_offset-3,43,22]; % 307
  
    % Check Box
    app.display.segment{seg_num}.checkbox = uicheckbox(app.Tab_Display, ...
      'Position', check_pos, ...
      'Value', true, ...
      'Text', '', ...
      'ValueChangedFcn', {@CheckCallback, app, plate_num, seg_num});
      % 'Value', app.plates(plate_num).enabled_segments(seg_num), ...

    % Segment Label
    if strcmp(app.segment{seg_num}.Name.Value,'')
      segment_name = sprintf('Segment %i', seg_num);
    else
      segment_name = app.segment{seg_num}.Name.Value;
    end
    app.display.segment{seg_num}.label = uilabel(app.Tab_Display, ...
      'Text', segment_name, ...
      'Position', label_pos);

    % Gain Slider
    app.display.segment{seg_num}.gain_slider = uislider(app.Tab_Display, ...
      'MajorTicks', [], ...
      'MajorTickLabels', {}, ...
      'MinorTicks', [], ...
      'Orientation', 'vertical', ...
      'Value', 100, ...
      'ValueChangedFcn', {@Gain_Slider_Callback, app, plate_num, seg_num}, ...
      'Position', gain_pos); 

    % Colour Picker
    app.display.segment{seg_num}.color_picker = uibutton(app.Tab_Display, 'state', ...
      'Text', '', ...
      'Value', 0, ...
      'Icon', 'painter-palette.png', ...
      'BackgroundColor', [.3,.75,.9], ...
      'ValueChangedFcn', {@ColorPicker_Callback, app, plate_num, seg_num}, ...
      'Position', color_picker_pos);

    % Perimeter Toggle
    app.display.segment{seg_num}.perimeter_toggle = uibutton(app.Tab_Display, 'state', ...
      'Text', '', ...
      'Value', 1, ...
      'Icon', 'check-box-empty.png', ...
      'BackgroundColor', [.3,.75,.9], ...
      'ValueChangedFcn', {@Perimeter_Toggle_Callback, app, plate_num, seg_num}, ...
      'Position', perimeter_toggle_pos);

    % Perimeter Thickness
    app.display.segment{seg_num}.perimeter_thickness = uispinner(app.Tab_Display, ...
      'Value', 1, ...
      'Limits', [0 Inf], ...
      'ValueChangedFcn', {@Perimeter_Thickness_Callback, app, plate_num, seg_num}, ...
      'Position', perimeter_thickness_pos);

    v_offset = v_offset - 35;
  end

end

