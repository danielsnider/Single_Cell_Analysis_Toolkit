function fun(app)
  if no_images_loaded(app)
      return
  end

  value = app.DisplayMeasureCheckBox.Value;
  
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Don't overlay metrics for Bio Formats (not yet implemented)
  if value && strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'XYZCT-Bio-Formats')
      msg = sprintf('Sorry, metric overlay is currently not supported for the "XYZCT-Bio-Formats" image format.');
      uialert(app.UIFigure,msg,'Not Yet Implemented', 'Icon','warn');
      app.DisplayMeasureCheckBox.Value = false;
      return % don't create montage
    end
  
  update_figure(app);
end