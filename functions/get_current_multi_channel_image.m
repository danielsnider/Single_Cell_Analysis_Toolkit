function multi_channel_img = fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
    %% Build path to current image from dropdown selections
    image_dir = app.plates(plate_num).metadata.ImageDir;
    plate_file_num = app.plates(plate_num).plate_num; % The plate number in the filename of images
    row = app.RowDropDown.Value;
    column = app.ColumnDropDown.Value;
    field = app.FieldDropDown.Value;
    timepoint = app.TimepointDropDown.Value;

    multi_channel_img = {};
    multi_channel_img.channel_nums = app.plates(plate_num).channels;
    multi_channel_img.plate_num = plate_num;
    multi_channel_img.chans = [];
    multi_channel_img.row = row;
    multi_channel_img.column = column;
    multi_channel_img.field = field;
    multi_channel_img.timepoint = timepoint;
    for chan_num=[app.plates(plate_num).channels]
      image_name = sprintf(...
        'r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
        row,column,field,plate_file_num,chan_num,timepoint);
      image_path = sprintf(...
        '%s/%s', image_dir,image_name);
      if ~exist(image_path) % If the file doesn't exist, reset the dropdown box values and return to avoid updating the figure
        image_name = sprintf(...
          'r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tif',...
          row,column,field,plate_file_num,chan_num,timepoint);
        image_path = sprintf(...
          '%s/%s', image_dir,image_name);
      end
      if ~exist(image_path) % If the file doesn't exist, reset the dropdown box values and return to avoid updating the figure
        draw_display(app);
        uialert(app.UIFigure,sprintf('Sorry, the image file you are trying to process does not exist. A bug allowed this to happen. Image path: %s',image_path),'Bug', 'Icon','error');
        multi_channel_img = [];
        return
      end

      multi_channel_img.ImageName = image_name;
      multi_channel_img.chans(chan_num).folder = image_dir;
      multi_channel_img.chans(chan_num).name = image_name;
      multi_channel_img.chans(chan_num).path = image_path;
    end
  
  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles','MultiChannelFiles','XYZ-Bio-Formats','XYZC-Bio-Formats'})
    img_num = app.ExperimentDropDown.Value;
    multi_channel_img = app.ExperimentDropDown.UserData(img_num);
  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Format-SingleFile', 'XYZTC-Bio-Format-SingleFile'})
    img_num = app.ExperimentDropDown.Value;
    img_name = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
    timepoint = app.TimepointDropDown.Value;
    selected_timepoint_idx = [app.ExperimentDropDown.UserData.timepoint] == timepoint;
    selected_img_name_idx = strcmp({app.ExperimentDropDown.UserData.ImageName}, img_name);
    select_idx = selected_img_name_idx & selected_timepoint_idx;
    multi_channel_img = app.ExperimentDropDown.UserData(select_idx);
    
  elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'IncuCyte')
      
    % Build path to current image from dropdown selections
    image_dir = app.plates(plate_num).metadata.ImageDir;
    row = app.RowDropDown.Value;
    column = app.ColumnDropDown.Value;
    field = app.FieldDropDown.Value;
    timepoint = app.TimepointDropDown.Value;
    
    multi_channel_img = app.plates(plate_num).img_files_subset(contains(cellfun(@(x) (num2str(x)),{(app.plates(plate_num).img_files_subset.row)},'UniformOutput',false),num2str(row))&...
    contains(cellfun(@(x) (num2str(x)),{(app.plates(plate_num).img_files_subset.column)},'UniformOutput',false),num2str(column))&...
    contains(cellfun(@(x) (num2str(x)),{(app.plates(plate_num).img_files_subset.field)},'UniformOutput',false),num2str(field))&...
    ismember(cellfun(@(x) (num2str(x)),[(app.plates(plate_num).img_files_subset.timepoint)],'UniformOutput',false),num2str(timepoint)));
    
  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'CellomicsTiffs'})
    % Build path to current image from dropdown selections
    image_dir = app.plates(plate_num).metadata.ImageDir;
    row = app.RowDropDown.Value;
    column = app.ColumnDropDown.Value;
    field = app.FieldDropDown.Value;
    timepoint = app.TimepointDropDown.Value;
    
    multi_channel_img = app.plates(plate_num).img_files_subset(ismember([app.plates(plate_num).img_files_subset.row],row) & ...
      ismember([app.plates(plate_num).img_files_subset.column],column) & ...
      ismember([app.plates(plate_num).img_files_subset.field],field) & ...
      ismember([app.plates(plate_num).img_files_subset.timepoint],timepoint));

  end
      
      
end