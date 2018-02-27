function fun(app)
  % images = {'images/example_cells/r02c02f01p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f01p01-ch4sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch1sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch2sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch3sk1fk1fl1.tiff', 'images/example_cells/r02c02f02p01-ch4sk1fk1fl1.tiff'};

  for plate_num=1:length(app.plates)
    img_dir = app.plates(plate_num).metadata.ImageDir;
    naming_scheme = app.plates(plate_num).metadata.ImageFileFormat;

    msg = sprintf('Loading image names for plate %i...', plate_num);
    app.log_processing_message(app, msg);

    % Only OperettaSplitTiffs Image Naming Scheme is Supported
    if ~ismember(naming_scheme, {'OperettaSplitTiffs','ZeissSplitTiffs'})
      msg = sprintf('Could not load image file names. Unkown image file format "%s". Please see your plate map spreadsheet.',naming_scheme);
      uialert(app.UIFigure,msg,'Unkown Image File Format', 'Icon','error');
    end

    if strcmp(naming_scheme, 'OperettaSplitTiffs')
      % The plate number in the filename of images
      plate_num_file_part = sprintf('p%02d',app.plates(plate_num).plate_num); % ex. p01   Needed to handle different plate numbers in image filenames.

      % List Image Files
      img_files = dir([img_dir '\*' plate_num_file_part '*.tif*']); % ex. \path\Images\*p01*.tif*
      app.plates(plate_num).img_files = img_files;
      
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

      r = num2cell(rows);
      [app.plates(plate_num).img_files.row] = r{:};
      c = num2cell(columns);
      [app.plates(plate_num).img_files.column] = c{:};
      f = num2cell(fields);
      [app.plates(plate_num).img_files.field] = f{:};
      t = num2cell(timepoints);
      [app.plates(plate_num).img_files.timepoint] = t{:};
      c = num2cell(channels);
      [app.plates(plate_num).img_files.channel] = c{:};
      p = num2cell(plates);
      [app.plates(plate_num).img_files.plate] = p{:};

      % well_info = struct('row',rows,'column',columns,'field',fields,'timepoint',timepoints,'channel',channels,'plate',plates);
      % app.plates(plate_num).well_info = well_info;
      % % Set add the row, column, field, etc. values for each file to their struct data in app.plate.img_files
      % for file_num=1:length(app.plates(plate_num).img_files)
      %   app.plates(plate_num).img_files(file_num).row = rows(file_num);
      %   app.plates(plate_num).img_files(file_num).column = columns(file_num);
      %   app.plates(plate_num).img_files(file_num).field = fields(file_num);
      %   app.plates(plate_num).img_files(file_num).timepoint = timepoints(file_num);
      %   app.plates(plate_num).img_files(file_num).channel = channels(file_num);
      %   app.plates(plate_num).img_files(file_num).plate = plates(file_num);
      % end

    elseif strcmp(naming_scheme, 'ZeissSplitTiffs')

      % List Image Files
      img_files = dir([img_dir '\*.tif*']);
      
      if isempty(img_files)
        msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
        uialert(app.UIFigure,msg,'Image Files Not Found', 'Icon','error');
        error(msg);
      end

      % Zeiss starts channel nums sometimes at 0
      offset = 0;
      file_naming_has_id_number_then_channel = false;

      % Parse image names
      for img_num=1:length(img_files)
        % eg. jerboa_spleen-05_C02(Alexa Fluor 555)_ORG.tif
        % eg. jerboa_pancreas_apotome-Image Export-01_c4m142_ORG.tif
        % eg. jerboa_pancreas_apotome-Image Export-01_s1c4m142_ORG.tif   % note: the s1 here is for seek(?), like seeking to a different large region on the slide
        patterns = regexp(img_files(img_num).name,'(?<filepart1>.*)_[s]?[\d]?[cC][0]?(?<chan_num>\d)(?<filepart2>.*)','names');
        img_files(img_num).filepart1 = patterns.filepart1;
        img_files(img_num).filepart2 = patterns.filepart2;
        chan_num = str2num(patterns.chan_num);
        if chan_num == 0
          offset = 1;
          file_naming_has_id_number_then_channel = true; % channel number comes before the unique number for this image changing the sorting of the images
        end
        img_files(img_num).chan_num = chan_num+offset; % Zeiss starts channel nums at 0
      end
      
      app.plates(plate_num).channels = unique([img_files.chan_num],'stable');
      chan_nums = app.plates(plate_num).channels;
      num_chans = length(chan_nums);

      % Store unique values
      if file_naming_has_id_number_then_channel
        app.plates(plate_num).experiments = unique({img_files.filepart1},'stable');
      else
        image_names = unique({img_files.name},'stable') 
        image_names = image_names(1:length(img_files)/num_chans) % get the set of filenames for the first channel only
        app.plates(plate_num).experiments = image_names;
      end

      % Combine split image filenames (multiple items in the list per image, 1 for each channel) to a structure that is one list item per image (with multiple channels nested)
      multi_channel_imgs = [];
      if file_naming_has_id_number_then_channel
          loop_over = 1:num_chans:length(img_files);
      else
          loop_over = 1:length(img_files)/num_chans;
      end
          
      for img_num=loop_over
        multi_channel_img = {};
        multi_channel_img.channel_nums = chan_nums;
        multi_channel_img.plate_num = plate_num;
        multi_channel_img.chans = [];
        image_file = img_files(img_num);
        multi_channel_img.filepart1 = image_file.filepart1;
        multi_channel_img.filepart2 = image_file.filepart2;
        multi_channel_img.experiment = image_file.filepart1;
        multi_channel_img.experiment_num = length(multi_channel_imgs)+1;
        multi_channel_img.ImageName = image_file.name;
        for chan_num=[chan_nums]
            if file_naming_has_id_number_then_channel
                image_file = img_files(img_num+chan_num-1);
            else
                image_file = img_files(img_num+length(img_files)*(chan_num-1)/num_chans);
            end
          multi_channel_img.chans(chan_num).folder = image_file.folder;
          %multi_channel_img.chans(chan_num).name = ...
          %[image_file.filepart1 '_C0' num2str(chan_num-1) ...
          % image_file.filepart2]; % ex. jerboa_pancreas-09_C00(DAPI)_ORG.tif NOTE: Zeiss starts channel nums at 0
          multi_channel_img.chans(chan_num).path = fullfile(image_file.folder, image_file.name);
        end
        multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
      end

      app.plates(plate_num).img_files = multi_channel_imgs;
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
  app.input_data.channel_names = get_unique_channel_names(app);

end
