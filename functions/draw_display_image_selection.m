function fun(app)

  % Populate Plate Dropdown
  metadata = [app.plates.metadata];
  app.PlateDropDown.Items = {metadata.Name};
  app.PlateDropDown.ItemsData = 1:length(app.plates);

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Build list of experiments in the plate as a list of names and a list of well row/column numbers stored as complex values because matlab won't allow two seperate values per DataItem
  experiments = app.plates(plate_num).wells;
  experiments_filtered_names = {};
  experiments_filtered_nums = [];
  for x=1:size(experiments,1)
    for y=1:size(experiments,2)
      if ~isnan(experiments{x,y})
        experiments_filtered_names{length(experiments_filtered_names)+1} = experiments{x,y};
        experiments_filtered_nums(length(experiments_filtered_nums)+1) = complex(x, y); % encode x and y positions in a complex number because matlab won't allow two seperate values per DataItem
      end
    end
  end

  % Populate Experiment Dropdown
  app.ExperimentDropDown.Items = experiments_filtered_names;
  app.ExperimentDropDown.ItemsData = experiments_filtered_nums;

  % Populate Row Dropdown
  app.RowDropDown.Items = arrayfun(@(x) {num2str(x)},app.plates(plate_num).rows);
  app.RowDropDown.ItemsData = app.plates(plate_num).keep_rows;

  % Populate Row Dropdown
  app.ColumnDropDown.Items = arrayfun(@(x) {num2str(x)},app.plates(plate_num).columns);
  app.ColumnDropDown.ItemsData = app.plates(plate_num).keep_columns;

  % Populate Field Dropdown
  app.FieldDropDown.Items = arrayfun(@(x) {num2str(x)},app.plates(plate_num).fields);
  app.FieldDropDown.ItemsData = app.plates(plate_num).keep_fields;

  % Populate Timepoint Dropdown
  app.TimepointDropDown.Items = arrayfun(@(x) {num2str(x)},app.plates(plate_num).timepoints);
  app.TimepointDropDown.ItemsData = app.plates(plate_num).keep_timepoints;

end