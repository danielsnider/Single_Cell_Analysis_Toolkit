function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;
  current_series_id = app.ExperimentDropDown.Value;

  % List Image Files
  % Example: Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif
  img_files = dir([img_dir '\*']);

  % Remove banned file names
  banned_names = {'desktop.ini',...
    'Thumbs.db',...
    '.DS_Store',...
    'bad',...
    'ignore',...
    '.',...
    '..',...
    };
  img_files(ismember({img_files.name},banned_names)) = []; % do delete
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
    uialert(app.UIFigure,msg,'Image Files Not Found', 'Icon','error');
    error(msg);
  end
  if length(img_files) > 1
    msg = sprintf('Aborting because there more than one file found. Currently the "XYZCT-Bio-Formats" file format only supports opening one consolidated file with multiple image sets within it. Improving upon this is hoped for in the near future.');
    uialert(app.UIFigure,msg,'Image Files Not Found', 'Icon','error');
    error(msg);
  end

  img_num = app.ExperimentDropDown.Value;
  if ~isempty(img_num) % only happens on first startup
    img_name = app.ExperimentDropDown.Items{app.ExperimentDropDown.Value};
    msg = sprintf('Loading image stack %s', img_name);
  else
    msg = sprintf('Scanning image stacks.');
  end
  app.log_processing_message(app, msg);
  progressdlg = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
  'Message',msg, 'Indeterminate','on');

  % Open Bio-Formats data: all images and metadata are read into memory. TODO: Check size of file and warn user that this may take a while
  % app.log_processing_message(app, 'Loading XYZCT-Bio-Formats images...');
  pause(0.1) % Give gui time to update

  full_path = fullfile(img_files(1).folder, img_files(1).name); % use first becasue Currently the "XYZCT-Bio-Formats" file format only supports opening one consolidated file with multiple image sets within it. Improving upon this is hoped for in the near future.

  if isempty(app.bioformat_data)
    if endsWith(full_path, '.mat')
      load(full_path); % short circuit what we need
    else
      data = bfopen(full_path,1, 1, 1, 1);
    end
    app.log_processing_message(app, 'Finished loading images.');
    app.bioformat_data = data;
    pause(0.1) % Give gui time to update
  else
    data = app.bioformat_data;
  end

  %% Get OME Metadata
  any_series_id = 1;
  omeMeta = data{any_series_id,4};
  img_count = size(data,1);

  % Loop over series organising image stacks and saving them into 5D img_stacks
  img_stacks = [];
  for series_id=1:img_count
    dat = data{series_id};
    ome_series_id = series_id - 1; % OME starts at 0
    stack_name = matlab.lang.makeValidName(char(omeMeta.getImageName(ome_series_id)));

    % msg = sprintf('Scanning XYZCT-Bio-Formats stack %d of %d...', series_id, img_count);
    % app.log_processing_message(app, msg);

    idx = length(img_stacks)+1;
    img_stacks(idx).data = [];
    img_stacks(idx).zslices = omeMeta.getPixelsSizeZ(ome_series_id).getValue(); % number of Z slices;
    name = dat{1,2}; % example:     {'Z:\DanielS\Images\LauraD PeterK\Set 2 - Timelapse\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif; HyVolution/Series003; plane 1/80; Z=1/5; C=1/2; T=1/8' }
    search = regexp(name,'T=\d+/(?<time>\d+)','names');
    img_stacks(idx).timepoints = str2num(search.time);
    img_stacks(idx).num_chans =  omeMeta.getChannelCount(ome_series_id);
    img_stacks(idx).chan_nums = 1:omeMeta.getChannelCount(ome_series_id);
    img_stacks(idx).stack_name = stack_name;
    img_stacks(idx).series_id = series_id;
    img_stacks(idx).idx = idx;
    img_stacks(idx).cell_num_txt = sprintf('Cell %d',idx);
    if ~isempty(app.ExperimentDropDown.Value) && strcmp(stack_name, app.ExperimentDropDown.Items{app.ExperimentDropDown.Value})
      series_data = bfopenSeries(full_path,series_id);
      dat=series_data{1};
      stack_ = [];
      % Loop over planes
      for plane_id=1:length(dat)
        name = dat{plane_id,2}; % example:     {'Z:\DanielS\Images\LauraD PeterK\Set 2 - Timelapse\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif; HyVolution/Series003; plane 1/80; Z=1/5; C=1/2; T=1/8' }
        pos = regexp(name,' Z=(?<z>\d+).* C=(?<chan>\d+).* T=(?<time>\d+)','names');
        pos.z = str2num(pos.z);
        pos.time = str2num(pos.time);
        pos.chan = str2num(pos.chan);
        stack_(:,:,pos.z, pos.time, pos.chan) = dat{plane_id,1}; 
      end
      img_stacks(idx).data = stack_(:,:,:,:,:);
    end
    % idx = length(img_stacks)+1;
    % img_stacks(idx).zslices = size(stack_,3);
    % img_stacks(idx).timepoints = size(stack_,4);
    % img_stacks(idx).num_chans = size(stack_,5);
    % img_stacks(idx).chan_nums = 1:size(stack_,5);
    % img_stacks(idx).stack_name = stack_name;
    % img_stacks(idx).series_id = series_id;
    % img_stacks(idx).idx = idx;
    % img_stacks(idx).cell_num_txt = sprintf('Cell %d',idx);
  end

  % Loop over 5D img_stacks converting to 4D multi_channel_img format, flattening timepoints to simplify plugin algorithms
  multi_channel_imgs = [];
  for idx=1:length(img_stacks)
    for timepoint=1:img_stacks(idx).timepoints
      multi_channel_img = {};
      multi_channel_img.channel_nums = img_stacks(idx).chan_nums;
      multi_channel_img.zslices = 1:img_stacks(idx).zslices;
      multi_channel_img.plate_num = plate_num;
      multi_channel_img.timepoint = timepoint;
      multi_channel_img.series_id = img_stacks(idx).series_id;
      multi_channel_img.chans = [];
      % img_name = sprintf('timepoint=%d %s', timepoint, img_stacks(idx).stack_name);
      img_name = img_stacks(idx).stack_name;
      multi_channel_img.experiment = img_name;
      multi_channel_img.experiment_num = length(multi_channel_imgs)+1;
      multi_channel_img.ImageName = img_name;
      if ~isempty(app.ExperimentDropDown.Value) && strcmp(img_stacks(idx).stack_name, app.ExperimentDropDown.Items{app.ExperimentDropDown.Value})
        for chan_num=[multi_channel_img.channel_nums]
          multi_channel_img.chans(chan_num).data = img_stacks(idx).data(:,:,:,timepoint,chan_num);
          multi_channel_img.chans(chan_num).path = 'in memory';
        end
      end
      multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
    end
  end

  app.plates(plate_num).img_files = multi_channel_imgs;
  app.ExperimentDropDown.UserData = multi_channel_imgs;
  app.plates(plate_num).channels = 1:omeMeta.getChannelCount(ome_series_id);
  app.plates(plate_num).experiments  = unique({multi_channel_imgs.ImageName});
  app.plates(plate_num).timepoints = unique([multi_channel_imgs.timepoint]);
  app.plates(plate_num).zslices = 1:max([multi_channel_imgs.zslices]);

  % % store which images are loaded in memory
  % loaded_images_idx = find(cellfun(@(x) ~isempty(x), {multi_channel_imgs.chans}));
  % app.plates(plate_num).loaded_images_idx = loaded_images_idx;

  if ~ischar(img_num) % only happens on first startup
    close(progressdlg)
  end

end