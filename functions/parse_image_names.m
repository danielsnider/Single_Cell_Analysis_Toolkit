function fun(app)
  % images = {'images/example_cells/r02c02f01p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch4sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch4sk1fk1fl1.tiff'};

  for plate_num=1:length(app.plates)
    img_dir = app.plates(plate_num).metadata.ImageDir;
    naming_scheme = app.plates(plate_num).metadata.ImageNamingScheme;

    msg = sprintf('Loading image names for plate %i...', plate_num);
    app.log_startup_message(app, msg);

    % Only Operetta Image Naming Scheme is Supported
    if ~strcmp(naming_scheme, 'Operetta')
      msg = sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta".',naming_scheme);
      uialert(app.UIFigure,msg,'Unkown image naming scheme', 'Icon','error');
    end

    % The plate number in the filename of images
    plate_num_file_part = sprintf('p%02d',app.plates(plate_num).plate_num); % ex. p01   Needed to handle different plate numbers in image filenames.
    img_files = dir([img_dir '\*' plate_num_file_part '*.tif*']); % ex. \path\Images\*p01*.tif*
    app.plates(plate_num).img_files = img_files;
    app.image_names = [app.image_names; img_files];
    
    if isempty(img_files)
      msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
      uialert(app.UIFigure,msg,'Image Files Not Found', 'Icon','error');
      error(msg);
    end

    % Get unique row, column, etc. values from all the image names
    rows = cellfun(@(x) str2num(x(2:3)), {img_files.name},'UniformOutput',false);
    uniq_rows = unique([rows{:}],'sort');
    columns = cellfun(@(x) str2num(x(5:6)), {img_files.name},'UniformOutput',false);
    uniq_columns = unique([columns{:}],'sort');
    fields = cellfun(@(x) str2num(x(8:9)), {img_files.name},'UniformOutput',false);
    uniq_fields = unique([fields{:}],'sort');
    plates = cellfun(@(x) str2num(x(11:12)), {img_files.name},'UniformOutput',false);
    uniq_plates = unique([plates{:}],'sort');
    channels = cellfun(@(x) str2num(x(16)), {img_files.name},'UniformOutput',false);
    uniq_channels = unique([channels{:}],'sort');
    paren = @(x, varargin) str2num(x{varargin{:}}); % helper to extract value from array in one line
    timepoints = cellfun(@(x) paren(strsplit(x,{'sk','fk'}),2), {img_files.name},'UniformOutput',false);
    uniq_timepoints = unique([timepoints{:}],'sort');

    app.plates(plate_num).rows = uniq_rows;
    app.plates(plate_num).columns = uniq_columns;
    app.plates(plate_num).fields = uniq_fields;
    app.plates(plate_num).timepoints = uniq_timepoints;
    app.plates(plate_num).channels = uniq_channels;
    app.plates(plate_num).plates = uniq_plates;

    % Set add the row, column, field, etc. values for each file to their struct data in app.plate.img_files
    for file_num=1:length(app.plates(plate_num).img_files)
      app.plates(plate_num).img_files(file_num).row = rows(file_num);
      app.plates(plate_num).img_files(file_num).column = columns(file_num);
      app.plates(plate_num).img_files(file_num).field = fields(file_num);
      app.plates(plate_num).img_files(file_num).timepoint = timepoints(file_num);
      app.plates(plate_num).img_files(file_num).channel = channels(file_num);
      app.plates(plate_num).img_files(file_num).plate = plates(file_num);
    end

    % Enable by default all channels for display in the figure
    app.plates(plate_num).enabled_channels = logical(app.plates(plate_num).channels);

    % Enable by default full dynamic range of channel intensities for display in the figure
    app.plates(plate_num).channel_max = ones(1,length(app.plates(plate_num).channels))*100;
    app.plates(plate_num).channel_min = zeros(1,length(app.plates(plate_num).channels));

    % Default channels colors for display in the figure
    default_colors = [...
      1 0 0;
      0 1 0;
      0 0 1;
      1 1 0;
      0 1 1;
      1 0 1; % limitation introduced here on the number of channels
    ];
    app.plates(plate_num).channel_colors = default_colors(1:length(app.plates(plate_num).channels),:); % set each channel a default colour;


    % Build a list of channel names per plate in app.input_data.plate.chan_names. Ex. {'DAPI'} {'SE'}
    app.plates(plate_num).chan_names = {};
    for chan_num=[app.plates(plate_num).channels]
      chan_name = getfield(app.plates(plate_num).metadata,['Ch' num2str(chan_num)]);
      app.plates(plate_num).chan_names{chan_num} = chan_name;
    end

    % Update UI with defaults for row, column, etc. filtering values
    changed_FilterInput(app, plate_num);
  end

  % Build list of channel names across all plotes in app.input_data.channel_names. Ex. {'DAPI'} {'SE'}
  app.input_data.channel_map = cat(1,app.plates.chan_names);
  app.input_data.channel_names = unique(app.input_data.channel_map);

end
