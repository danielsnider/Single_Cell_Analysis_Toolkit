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
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end
  if length(img_files) > 1
    msg = sprintf('Aborting because there more than one file found. Currently the "XYZCT-Bio-Format-SingleFile" file format only supports opening one consolidated file with multiple image sets within it. Improving upon this is hoped for in the near future.');
    title_ = 'Too Many Files Found';
    throw_application_error(app,msg,title_);
  end

  msg = sprintf('Scanning image stacks.');
  app.log_processing_message(app, msg);
  % app.progressdlg2 = uiprogressdlg(app.UIFigure,'Title','Please Wait','Message',msg, 'Indeterminate','on');
  % assignin('base','app_progressdlg2',app.progressdlg2); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way

  % Open Bio-Formats data: all images and metadata are read into memory. TODO: Check size of file and warn user that this may take a while
  % app.log_processing_message(app, 'Loading XYZCT-Bio-Format-SingleFile images...');
  pause(0.1) % Give gui time to update

  full_path = fullfile(img_files(1).folder, img_files(1).name); % use first becasue Currently the "XYZCT-Bio-Format-SingleFile" file format only supports opening one consolidated file with multiple image sets within it. Improving upon this is hoped for in the near future.

  if isempty(app.bioformat_data)
    if endsWith(full_path, '.mat')
      load(full_path); % short circuit what we need
    else
      try
        data = bfopen(full_path,1, 1, 1, 1);
        % series_data = bfopenSeries(img_path,series_id,select_images, debug_level);
        % dat=series_data{1};
      catch ME
        error_msg = getReport(ME,'extended','hyperlinks','off');
        msg = sprintf('Unable to read image file: "%s".\n\nThe error was:\n\n%s',full_path,error_msg);
        title_ = 'Unable to read image file';
        if strfind(ME.message,'Unknown file format')
          msg = sprintf('Unable to read image file: "%s". \n\nThe file type is not a supported image type. Perhaps you have more than just images in the folder. Or perhaps you have the wrong ''ImageFileFormat'' in your plate map spreadsheet.\n\nThe error was:\n\n%s',full_path,error_msg);
        end
        throw_application_error(app,msg,title_)
      end
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

    idx = length(img_stacks)+1;
    name = dat{1,2}; % example:     {'Z:\DanielS\Images\LauraD PeterK\Set 2 - Timelapse\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif; HyVolution/Series003; plane 1/80; Z=1/5; C=1/2; T=1/8' }
    search = regexp(name,'T=\d+/(?<time>\d+)','names');
    img_stacks(idx).timepoints = str2num(search.time);
    img_stacks(idx).zslices = omeMeta.getPixelsSizeZ(ome_series_id).getValue(); % number of Z slices;
    img_stacks(idx).num_chans =  omeMeta.getChannelCount(ome_series_id);
    img_stacks(idx).chan_nums = 1:omeMeta.getChannelCount(ome_series_id);
    img_stacks(idx).stack_name = stack_name;
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
      multi_channel_img.num_chans = img_stacks(idx).num_chans;
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
      for chan_num=[multi_channel_img.channel_nums]
          multi_channel_img.chans(chan_num).path = full_path;
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

  % close(app.progressdlg2)

end