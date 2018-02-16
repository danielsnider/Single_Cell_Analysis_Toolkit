function fun(app)
  % Dencode row and col positions of this experiment from a complex number because we stored it this way because matlab won't allow two seperate values per DataItem
  row_num = abs(real(app.ExperimentDropDown.Value));
  col_num = abs(imag(app.ExperimentDropDown.Value));

  app.RowDropDown.Value = row_num;
  app.ColumnDropDown.Value = col_num;

  start_processing_of_one_image(app);
  update_figure(app);
end

