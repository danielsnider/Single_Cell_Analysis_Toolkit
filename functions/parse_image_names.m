function fun(app)
  % images = {'images/example_cells/r02c02f01p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch4sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch4sk1fk1fl1.tiff'};

  for plate_num=1:length(app.input_data.plates)
    img_dir = app.input_data.plates(plate_num).ImageDir;
    naming_scheme = app.input_data.plates(plate_num).ImageNamingScheme;

    msg = sprintf('Loading image names for plate %i...', plate_num);
    app.log_startup_message(app, msg);

    % Only Operetta Image Naming Scheme is Supported
    if ~strcmp(naming_scheme, 'Operetta')
      errordlg(sprintf('Could not load image file names. Unkown image file naming scheme "%s". Please see your plate map spreadsheet and use "Operetta".',naming_scheme));
    end

    % The plate number in the filename of images
    plate_num_file_part = sprintf('p%02d',app.input_data.plates(plate_num).plate_num); % ex. p01   Needed to handle different plate numbers in image filenames.
    img_files = dir([img_dir '\*' plate_num_file_part '*.tif*']); % ex. \path\Images\*p01*.tif*

    % Get unique row, column, etc. values from all the image names
    app.input_data.plates(plate_num).rows = [];
    app.input_data.plates(plate_num).columns = [];
    app.input_data.plates(plate_num).fields = [];
    app.input_data.plates(plate_num).timepoints = [];
    app.input_data.plates(plate_num).channels = [];
    app.input_data.plates(plate_num).plates = [];
    for img_num=1:length(img_files)
      re = regexp(img_files(img_num).name,'r(?<row>\d+)c(?<column>\d+)f(?<field>\d+)p(?<plate>\d+)-ch(?<channel>\d+)sk(?<timepoint>\d+)','names');
      app.input_data.plates(plate_num).rows = [app.input_data.plates(plate_num).rows str2num(re.row)];
      app.input_data.plates(plate_num).columns = [app.input_data.plates(plate_num).columns str2num(re.column)];
      app.input_data.plates(plate_num).fields = [app.input_data.plates(plate_num).fields str2num(re.field)];
      app.input_data.plates(plate_num).timepoints = [app.input_data.plates(plate_num).timepoints str2num(re.timepoint)];
      app.input_data.plates(plate_num).channels = [app.input_data.plates(plate_num).channels str2num(re.channel)];
      app.input_data.plates(plate_num).plates = [app.input_data.plates(plate_num).plates str2num(re.plate)];
    end
    app.input_data.plates(plate_num).rows = unique(app.input_data.plates(plate_num).rows,'sort');
    app.input_data.plates(plate_num).columns = unique(app.input_data.plates(plate_num).columns,'sort');
    app.input_data.plates(plate_num).fields = unique(app.input_data.plates(plate_num).fields,'sort');
    app.input_data.plates(plate_num).timepoints = unique(app.input_data.plates(plate_num).timepoints,'sort');
    app.input_data.plates(plate_num).channels = unique(app.input_data.plates(plate_num).channels,'sort');
    app.input_data.plates(plate_num).plates = unique(app.input_data.plates(plate_num).plates,'sort');

    % Enable by default all channels for display in the figure
    app.input_data.plates(plate_num).enabled_channels = logical(app.input_data.plates(plate_num).channels);

    % Enable by default full dynamic range of channel intensities for display in the figure
    app.input_data.plates(plate_num).channel_max = ones(1,length(app.input_data.plates(plate_num).channels))*100;
    app.input_data.plates(plate_num).channel_min = zeros(1,length(app.input_data.plates(plate_num).channels));

    % Default channels colors for display in the figure
    default_colors = [...
      1 0 0;
      0 1 0;
      0 0 1;
      1 1 0;
      0 1 1;
      1 0 1; % limitation introduced here on the number of channels
    ];
    app.input_data.plates(plate_num).channel_colors = default_colors(1:length(app.input_data.plates(plate_num).channels),:); % set each channel a default colour;


    % Build a list of channel names in plate.chan_names. Ex. chan_names = {'DAPI'} {'SE'}
    app.input_data.plates(plate_num).chan_names = {};
    for chan_num=[app.input_data.plates(plate_num).channels]
      chan_name = getfield(app.input_data.plates(plate_num),['Ch' num2str(chan_num)]);
      app.input_data.plates(plate_num).chan_names{chan_num} = chan_name;
    end


end
