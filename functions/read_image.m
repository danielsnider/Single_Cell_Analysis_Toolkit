function img = func(app, image_file, chan_num)
  plate_num = app.PlateDropDown.Value;
  img_path = image_file.chans(chan_num).path;

  % Sanity check
  if ~exist(img_path) % If the file doesn't exist warn user
    msg = sprintf('Could not find the image file at location: %s',img_path);
    title_ = 'File Not Found';
    throw_application_error(app,msg,title_);
  end

  % Log that we are loading the file
  if ~ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Format-SingleFile'})
    [filepath,name,ext] = fileparts(img_path);
    if isvalid(app.StartupLogTextArea.tx) == 1
      msg = sprintf('Loading channel %d of image %s', chan_num, [name ext]);
      if app.CheckBox_Parallel.Value && app.processing_running
        send(app.ProcessingLogQueue, msg);
      else
        app.log_processing_message(app, msg);
      end
    end
  end

  % File type specific loading
  if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZ-Bio-Formats'})
    data = bfopen(img_path);
    dat = data{1};
    % Make image stack
    img=[];
    count = 1;
    keep_zslices = intersect(image_file.zslices, app.plates(plate_num).keep_zslices);
    for zid=keep_zslices % also do z filtering
      img(:,:,count) = dat{zid,1};
      count = count + 1;
    end

  % File type specific loading
  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZC-Bio-Formats'})
    data = bfopen(img_path);
    dat = data{1};
    % Make image stack
    full_img=[];
    count = 1;
    num_chans = length(app.plates(plate_num).channels);
    num_planes = size(dat,1);
    for zid=[1:num_chans:num_planes]+chan_num-1 % get all slices for this channel
      full_img(:,:,count) = dat{zid,1};
      count = count + 1;
    end

    % Filter z-slices
    count = 1;
    img=[];
    keep_zslices = intersect(image_file.zslices, app.plates(plate_num).keep_zslices);
    for keep_zid=keep_zslices % z filtering
      img(:,:,count) = full_img(:,:,keep_zid);
      count = count + 1;
    end

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Format-SingleFile'})
    ImageName = image_file.ImageName;
    series_id = image_file.series_id;
    num_chans = image_file.num_chans;
    timepoint = image_file.timepoint;
    zslices = image_file.zslices;
    select_images = chan_num:num_chans:num_chans*max(zslices); % bioformats stores images as a list of all channels, zslices and timepoints per stack, select the right channel and zslices
    select_images = select_images + ((timepoint-1)*max(zslices)*num_chans); % adjust to select the right timepoint

    debug_level = 'ERROR';
    if isvalid(app.StartupLogTextArea.tx) == 1
      msg = sprintf('Loading channel %d, timepoint %d, for image %s', chan_num, timepoint, ImageName);
      if app.CheckBox_Parallel.Value && app.processing_running
        send(app.ProcessingLogQueue, msg);
        debug_level = 'NO CHANGE';
      else
        app.log_processing_message(app, msg);
        debug_level = 'ERROR';
      end
    end

    series_data = bfopenSeries(img_path,series_id,select_images, debug_level);
    dat=series_data{1};
    % Make image stack
    img = [];
    count = 1;
    keep_zslices = intersect(image_file.zslices, app.plates(plate_num).keep_zslices);
    for zid=keep_zslices % also do z filtering
      img(:,:,count) = dat{zid,1};
      count = count + 1;
    end

  else
    try
      img = imread(img_path);
    catch ME
      error_msg = getReport(ME,'extended','hyperlinks','off');
      msg = sprintf('Unable to read image file: "%s".\n\nThe error was:\n\n%s',img_path,error_msg);
      title_ = 'Unable to read image file';
      if strcmp(ME.message,'Unable to determine the file format.')
        msg = sprintf('Unable to read image file: "%s". \n\nThe file type is not a supported image type. Perhaps you have more than just images in the folder. Or perhaps you have the wrong ''ImageFileFormat'' in your plate map spreadsheet.\n\nThe error was:\n\n%s',img_path,error_msg);
      end
      throw_application_error(app,msg,title_)
    end
  end

  % Extra work for file types
  if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'MultiChannelFiles'})
    img = img(:,:,chan_num);
  end

end
