function fun(app)
  if ~any(ismember(fields(app),'display'))
    return
  end
  if ~isfield(app.display, 'segment')
    return
  end
  field_names = { ...
    'checkbox', ...
    'label', ...
    'gain_slider', ...
    'color_picker', ...
    'perimeter_toggle', ...
    'perimeter_thickness', ...
  };
  % Delete UI components that were there before
  for seg_num=1:length(app.display.segment)    
    for field_name=field_names
      if isfield(app.display.segment{seg_num},field_name)
        delete(app.display.segment{seg_num}.(string(field_name)));
      end
    end
  end
  app.display.segment = {};
end