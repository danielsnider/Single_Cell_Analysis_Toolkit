function fun(app)
  if no_images_loaded(app)
      return
  end

  checked = app.DisplayMeasureCheckBox.Value;
  
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Don't overlay metrics for Bio Formats (not yet implemented)
  if checked && app.plates(plate_num).supports_3D
      msg = sprintf('Sorry, metric overlay is currently not supported for the 3D image stack formats.');
      uialert(app.UIFigure,msg,'Not Yet Implemented', 'Icon','warn');
      app.DisplayMeasureCheckBox.Value = false;
      return
    end
  
  if checked
    app.Button_ViewOverlaidMeasurements.Visible = 'on';
  else
    app.Button_ViewOverlaidMeasurements.Visible = 'off';
  end

  update_figure(app);

end