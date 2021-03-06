function fun(app)

  % Populate Plate Dropdown With Enabled Plates
  plate_names = {};
  plate_nums = [];
  for plate_num=1:length(app.plates)
    if app.plates(plate_num).checkbox.Value
      plate_names{length(plate_names)+1} = app.plates(plate_num).name;
      plate_nums = [plate_nums plate_num];
    end
  end
  app.PlateDropDown.Items = plate_names;
  app.PlateDropDown.ItemsData = plate_nums;

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles', 'MultiChannelFiles'})
    app.RowDropDown.Visible = 'off';
    app.ColumnDropDown.Visible = 'off';
    app.FieldDropDown.Visible = 'off';
    app.TimepointDropDown.Visible = 'off';
    app.RowDropDownLabel.Visible = 'off';
    app.ColumnDropDownLabel.Visible = 'off';
    app.FieldDropDownLabel.Visible = 'off';
    app.TimepointDropDownLabel.Visible = 'off';
    app.ZSliceDropDown.Visible = 'off';
    app.ZSliceDropDownLabel.Visible = 'off';

    app.ExperimentDropDown.Items = app.plates(plate_num).experiments;
    app.ExperimentDropDown.ItemsData = 1:length(app.plates(plate_num).experiments);
    app.ExperimentDropDown.UserData = app.plates(plate_num).img_files_subset;

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZ-Bio-Formats','XYZC-Bio-Formats'})
    app.RowDropDown.Visible = 'off';
    app.ColumnDropDown.Visible = 'off';
    app.FieldDropDown.Visible = 'off';
    app.TimepointDropDown.Visible = 'off';
    app.RowDropDownLabel.Visible = 'off';
    app.ColumnDropDownLabel.Visible = 'off';
    app.FieldDropDownLabel.Visible = 'off';
    app.TimepointDropDownLabel.Visible = 'off';
    app.ZSliceDropDown.Visible = 'on';
    app.ZSliceDropDownLabel.Visible = 'on';

    app.ExperimentDropDown.Items = app.plates(plate_num).experiments;
    app.ExperimentDropDown.ItemsData = 1:length(app.plates(plate_num).experiments);
    app.ExperimentDropDown.UserData = app.plates(plate_num).img_files_subset;

    % Populate ZSlice Dropdown
    image_file = get_current_multi_channel_image(app);
    avail_z_slices = intersect(image_file.zslices, app.plates(plate_num).keep_zslices);
    app.ZSliceDropDown.Items = arrayfun(@(x) {num2str(x)},avail_z_slices);
    app.ZSliceDropDown.ItemsData = 1:length(avail_z_slices);

    % Move ZSliceDropDown position up
    pos = app.ZSliceDropDown.Position;
    pos(2) = 255; % move vertically
    app.ZSliceDropDown.Position = pos;
    pos = app.ZSliceDropDownLabel.Position;
    pos(2) = 251; % move vertically
    app.ZSliceDropDownLabel.Position = pos;

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Format-SingleFile', 'XYZTC-Bio-Format-SingleFile'})
    app.RowDropDown.Visible = 'off';
    app.RowDropDownLabel.Visible = 'off';
    app.ColumnDropDown.Visible = 'off';
    app.ColumnDropDownLabel.Visible = 'off';
    app.FieldDropDown.Visible = 'off';
    app.FieldDropDownLabel.Visible = 'off';
    app.TimepointDropDown.Visible = 'on';
    app.TimepointDropDownLabel.Visible = 'on';
    app.ZSliceDropDown.Visible = 'on';
    app.ZSliceDropDownLabel.Visible = 'on';

    % Populate Experiment Dropdown
    app.ExperimentDropDown.Items = app.plates(plate_num).experiments;
    app.ExperimentDropDown.ItemsData = 1:length(app.plates(plate_num).experiments);
    app.ExperimentDropDown.UserData = app.plates(plate_num).img_files_subset;
    % store which images are loaded in memory
    % loaded_images_idx = find(cellfun(@(x) ~isempty(x), {app.plates(plate_num).img_files_subset.chans}));
    % app.plates(plate_num).loaded_images_idx = loaded_images_idx;

    % Populate Timepoint Dropdown
    app.TimepointDropDown.Items = arrayfun(@(x) {num2str(x)},unique([app.plates(plate_num).img_files_subset.timepoint]));
    app.TimepointDropDown.ItemsData = app.plates(plate_num).keep_timepoints;

    % Populate ZSlice Dropdown
    img_num = app.ExperimentDropDown.Value;
    img_name = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
    timepoint = app.TimepointDropDown.Value;
    selected_timepoint_idx = [app.ExperimentDropDown.UserData.timepoint] == timepoint;
    selected_img_name_idx = strcmp({app.ExperimentDropDown.UserData.ImageName}, img_name);
    select_idx = selected_img_name_idx & selected_timepoint_idx;
    image_file = get_current_multi_channel_image(app);
    avail_z_slices = intersect(image_file.zslices, app.plates(plate_num).keep_zslices);
    app.ZSliceDropDown.Items = arrayfun(@(x) {num2str(x)},avail_z_slices);
    app.ZSliceDropDown.ItemsData = avail_z_slices;

    % Move TimepointDropDown position up
    pos = app.TimepointDropDown.Position;
    pos(2) = 255; % move vertically
    app.TimepointDropDown.Position = pos;
    pos = app.TimepointDropDownLabel.Position;
    pos(2) = 259; % move vertically
    app.TimepointDropDownLabel.Position = pos;

    % Move ZSliceDropDown position up
    pos = app.ZSliceDropDown.Position;
    pos(2) = 226; % move vertically
    app.ZSliceDropDown.Position = pos;
    pos = app.ZSliceDropDownLabel.Position;
    pos(2) = 222; % move vertically
    app.ZSliceDropDownLabel.Position = pos;

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'OperettaSplitTiffs','IncuCyte','CellomicsTiffs'})
    app.RowDropDown.Visible = 'on';
    app.ColumnDropDown.Visible = 'on';
    app.FieldDropDown.Visible = 'on';
    app.TimepointDropDown.Visible = 'on';
    app.RowDropDownLabel.Visible = 'on';
    app.ColumnDropDownLabel.Visible = 'on';
    app.FieldDropDownLabel.Visible = 'on';
    app.TimepointDropDownLabel.Visible = 'on';
    app.ZSliceDropDown.Visible = 'off';
    app.ZSliceDropDownLabel.Visible = 'off';

    % Build list of experiments in the plate as a list of names and a list of well row/column numbers stored as complex values because matlab won't allow two seperate values per DataItem
    experiments = app.plates(plate_num).wells;
    experiments_filtered_names = {};
    experiments_filtered_nums = [];
    for row_num=app.plates(plate_num).keep_rows
      for col_num=app.plates(plate_num).keep_columns
        if ~isempty(experiments) && row_num <= size(experiments,1) && col_num <= size(experiments,2) && ~isempty(experiments{row_num,col_num})
          experiments_filtered_names{length(experiments_filtered_names)+1} = experiments{row_num,col_num};
          experiments_filtered_nums(length(experiments_filtered_nums)+1) = complex(row_num, col_num); % encode row and col positions in a complex number because matlab won't allow two seperate values per DataItem
        end
      end
    end
    % Populate Experiment Dropdown
    app.ExperimentDropDown.Items = experiments_filtered_names;
    app.ExperimentDropDown.ItemsData = experiments_filtered_nums;
    app.ExperimentDropDown.UserData = app.plates(plate_num).img_files_subset;

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

  % Handle case where there is no image available at the current image selection, set by the above. This happens on startup if there is no image in row=1,column=1 position.
  if isempty(get_current_multi_channel_image(app))
    if isfield(app.plates(plate_num).img_files_subset(1),'row')
        app.RowDropDown.Value = app.plates(plate_num).img_files_subset(1).row;
    end
    if isfield(app.plates(plate_num).img_files_subset(1),'column')
        app.ColumnDropDown.Value = app.plates(plate_num).img_files_subset(1).column;
    end
  end
end