function fun(app)
  plate_num = app.PlateDropDown.Value;
  if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')
      start_processing_of_one_image(app);
      update_figure(app);
      return % for Zeiss the experiments are actually just file names instead of locations in a platemap, this can be handled more gracefully
  end
  % Dencode row and col positions of this experiment from a complex number because we stored it this way because matlab won't allow two seperate values per DataItem
  row_num = abs(real(app.ExperimentDropDown.Value));
  col_num = abs(imag(app.ExperimentDropDown.Value));

  app.RowDropDown.Value = row_num;
  app.ColumnDropDown.Value = col_num;

  start_processing_of_one_image(app);
  update_figure(app);
end

