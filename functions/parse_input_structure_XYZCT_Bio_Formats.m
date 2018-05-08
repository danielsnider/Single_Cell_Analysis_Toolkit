function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

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

  % Open Bio-Formats data: all images and metadata are read into memory. TODO: Check size of file and warn user that this may take a while
  app.log_processing_message(app, 'Loading XYZCT-Bio-Formats images...');
  load('data-3-decon-cells.mat'); % short circuit what we need
  % data = bfopen(fullfile(img_files(1).folder, img_files(1).name));
  app.log_processing_message(app, 'Finished loading images.');

  %% Get OME Metadata
  any_series_id = 1;
  omeMeta = data{any_series_id,4};
  img_count = size(data,1);

  % Loop over series organising image stacks and saving them into 5D img_stacks
  img_stacks = [];
  for series_id=1:img_count
    dat = data{series_id};
    stack_name = dat{1,2};

    msg = sprintf('Organizing XYZCT-Bio-Formats stack %d of %d...', series_id, img_count);
    app.log_processing_message(app, msg);

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
    idx = length(img_stacks)+1;
    img_stacks(idx).data = stack_(:,:,:,:,:);
    img_stacks(idx).zslices = size(stack_,3);
    img_stacks(idx).timepoints = size(stack_,4);
    img_stacks(idx).num_chans = size(stack_,5);
    img_stacks(idx).chan_nums = 1:size(stack_,5);
    stack_name_pretty = strsplit(stack_name,'x');
    stack_name_pretty = stack_name_pretty{2};
    img_stacks(idx).stack_name = stack_name_pretty;
    img_stacks(idx).series_id = series_id;
    img_stacks(idx).idx = idx;
    img_stacks(idx).cell_num_txt = sprintf('Cell %d',idx);
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
      multi_channel_img.chans = [];
      img_name = sprintf('timepoint=%d %s', timepoint, img_stacks(idx).stack_name);
      multi_channel_img.experiment = img_name;
      multi_channel_img.experiment_num = length(multi_channel_imgs)+1;
      multi_channel_img.ImageName = img_name;
      for chan_num=[multi_channel_img.channel_nums]
        multi_channel_img.chans(chan_num).data = img_stacks(idx).data(:,:,:,timepoint,chan_num);
        multi_channel_img.chans(chan_num).path = 'in memory';
      end
      multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
    end
  end

  app.plates(plate_num).img_files = multi_channel_imgs;
  app.plates(plate_num).channels = 1:size(stack_,5);
  app.plates(plate_num).experiments  = {multi_channel_imgs.ImageName};
  app.plates(plate_num).timepoints = unique([multi_channel_imgs.timepoint]);
  app.plates(plate_num).zslices = 1:max([multi_channel_imgs.zslices]);

end