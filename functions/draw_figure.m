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

  % Populate Row Dropdown
  app.RowDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).rows);
  app.RowDropDown.ItemsData = app.input_data.plates(plate_num).rows;

  % Populate Row Dropdown
  app.ColumnDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).columns);
  app.ColumnDropDown.ItemsData = app.input_data.plates(plate_num).columns;
  
  % Populate Field Dropdown
  app.FieldDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).fields);
  app.FieldDropDown.ItemsData = app.input_data.plates(plate_num).fields;
  
  % Populate Timepoint Dropdown
  app.TimepointDropDown.Items = arrayfun(@(x) {num2str(x)},app.input_data.plates(plate_num).timepoints);
  app.TimepointDropDown.ItemsData = app.input_data.plates(plate_num).timepoints;


  %% Build path to current image from dropdown selections
  img_dir = app.input_data.plates(plate_num).ImageDir;
  plate_file_num = app.input_data.plates(plate_num).plate_num; % The plate number in the filename of images
  row = app.RowDropDown.Value;
  column = app.ColumnDropDown.Value;
  field = app.FieldDropDown.Value;
  timepoint = app.TimepointDropDown.Value;

  %% Load Images
  if strcmp(app.input_data.plates(plate_num).ImageNamingScheme, 'Operetta')
    for chan_num=[app.input_data.plates(plate_num).channels]
      app.image(chan_num).path = sprintf(...
        '%s/r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
        img_dir,row,column,field,plate_file_num,chan_num,timepoint);
      app.image(chan_num).data = imread(app.image(chan_num).path);
    end
  end
  
  %% Display Images
  % Initialize image of a composite of one or more channels
  first_chan_num = app.input_data.plates(plate_num).channels(1); % may not always be 1 in position 1, it's a crazy world out there
  composite_img = uint16(zeros([size(app.image(first_chan_num).data),3]));

  % Build composite image
  number_of_channels = length(app.input_data.plates(plate_num).channels);
  for chan_num=[app.input_data.plates(plate_num).channels]
    colour = rand(1,3);
    scaled_img = app.image(chan_num).data./number_of_channels;
    colour_img = uint16(zeros(size(composite_img)));
    colour_img(:,:,1) = scaled_img .* colour(1);
    colour_img(:,:,2) = scaled_img .* colour(2);
    colour_img(:,:,3) = scaled_img .* colour(3);
    composite_img = composite_img + colour_img;
  end
  % Increase image brightness to use full range of unit16 values
  scale_factor = 2^16./max(colour_img(:));
  composite_img = composite_img .* scale_factor;

  % Display
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off');
  imshow(composite_img,[]);
  hold on

  % Display segments as colorized layers
  for seg_num=1:length(app.segment)
    seg = app.segment{seg_num}.data;
    seg = imdilate(seg,strel('disk',5));
    seg_colors = label2rgb(uint16(seg), 'jet', [1 1 1], 'shuffle');
    layer = imshow(seg_colors,[]);
    layer.AlphaData = logical(seg)*.5;
  end

  hold off
end