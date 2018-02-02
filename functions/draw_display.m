function fun(app)



  % Populate Plate Dropdown
  app.PlateDropDown.Items = {app.input_data.plates.Name};
  app.PlateDropDown.ItemsData = 1:length(app.input_data.plates);

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Delete UI components that were there before
  for chan_num=1:length(app.display.channel)    
      delete(app.display.channel{chan_num}.checkbox);
      delete(app.display.channel{chan_num}.label);
  end
  app.display.channel = {};

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

  % % Populate Checkmarks according 
  % for chan_num=[app.input_data.plates(plate_num).enabled_channels]
  %   app.display.channel{chan_num}.checkbox.Value = app.input_data.plates(plate_num).enabled_channels(chan_num);
  % end

  % Populate Channel Selection Checkboxes
  function CheckCallback(uiElem, Update, app, plate_num, chan_num)
      app.input_data.plates(plate_num).enabled_channels(chan_num) = app.display.channel{chan_num}.checkbox.Value;
      update_figure(app);
  end
  v_offset = 194;
  for chan_num=[app.input_data.plates(plate_num).channels]
    % Location of GUI component
    check_pos = [310,v_offset,25,15];
    label_pos = [330,v_offset-1,55,15];

    app.display.channel{chan_num}.checkbox = uicheckbox(app.Tab_Display, ...
      'Position', check_pos, ...
      'Value', app.input_data.plates(plate_num).enabled_channels(chan_num), ...
      'Text', '', ...
      'ValueChangedFcn', {@CheckCallback, app, plate_num, chan_num});
    app.display.channel{chan_num}.label = uilabel(app.Tab_Display, ...
      'Text', app.input_data.plates(plate_num).chan_names{chan_num}, ...
      'Position', label_pos);

    v_offset = v_offset - 30;
  end

  % app.input_data.plates(plate_num).enabled_channels(2) = app.CheckBox_11.Value



end