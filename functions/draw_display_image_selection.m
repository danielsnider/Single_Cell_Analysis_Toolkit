function fun(app)

  % Populate Plate Dropdown
  app.PlateDropDown.Items = {app.input_data.plates.Name};
  app.PlateDropDown.ItemsData = 1:length(app.input_data.plates);

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Build list of experiments in the plate as a list of names and a list of well row/column numbers stored as complex values because matlab won't allow two seperate values per DataItem
  experiments = app.input_data.plates(plate_num).wells;
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
  app.ExperimentDropDown.Value = app.ExperimentDropDown.ItemsData(1);

  % Populate Row Dropdown
  app.RowDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).rows);
  app.RowDropDown.ItemsData = app.input_data.plates(plate_num).rows;
  app.RowDropDown.Value = app.RowDropDown.ItemsData(1);

  % Populate Row Dropdown
  app.ColumnDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).columns);
  app.ColumnDropDown.ItemsData = app.input_data.plates(plate_num).columns;
  app.ColumnDropDown.Value = app.ColumnDropDown.ItemsData(1);

  % Populate Field Dropdown
  app.FieldDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).fields);
  app.FieldDropDown.ItemsData = app.input_data.plates(plate_num).fields;
  app.FieldDropDown.Value = app.FieldDropDown.ItemsData(1);

  % Populate Timepoint Dropdown
  app.TimepointDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).timepoints);
  app.TimepointDropDown.ItemsData = app.input_data.plates(plate_num).timepoints;
  app.TimepointDropDown.Value = app.TimepointDropDown.ItemsData(1);

end