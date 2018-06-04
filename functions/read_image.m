function img = func(app, image_file, chan_num)
  plate_num = app.PlateDropDown.Value;
  img_path = image_file.chans(chan_num).path;

  % Sanity check
  if ~exist(img_path) % If the file doesn't exist warn user
    msg = sprintf('Could not find the image file at location: %s',img_path);
    uialert(app.UIFigure,msg,'File Not Found', 'Icon','error');
    error(msg);
  end

  % Log that we are loading the file
  if ~ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Formats'})
    [filepath,name,ext] = fileparts(img_path);
    if isvalid(app.StartupLogTextArea.tx) == 1
      msg = sprintf('Loading channel %d image %s', chan_num, [name ext]);
      if app.CheckBox_Parallel.Value && app.processing_running
          disp(msg)
  %         send(app.ProcessingLogQueue, msg);
      else
        app.log_processing_message(app, msg);
      end
    end
  end

  % File type specific loading
  if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZ-Split-Bio-Formats'})
    img_path = image_file.chans(chan_num).path;
    file_exists_check(img_path)

    data = bfopen(img_path);
    dat = data{1};
    % Make image stack
    img=[];
    count = 1;
    for zid=app.plates(plate_num).keep_zslices % also do z filtering
      img(:,:,count) = dat{zid,1};
      count = count + 1;
    end

  elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Formats'})
    ImageName = image_file.ImageName;
    series_id = image_file.series_id;
    num_chans = image_file.num_chans;
    timepoint = image_file.timepoint;
    zslices = image_file.zslices;
    select_images = chan_num:num_chans:num_chans*max(zslices); % bioformats stores images as a list of all channels, zslices and timepoints per stack, select the right channel and zslices
    select_images = select_images + ((timepoint-1)*max(zslices)*num_chans); % adjust to select the right timepoint

    if isvalid(app.StartupLogTextArea.tx) == 1
      msg = sprintf('Loading channel %d, timepoint %d, for image %s', chan_num, timepoint, ImageName);
      if app.CheckBox_Parallel.Value && app.processing_running
          disp(msg)
  %         send(app.ProcessingLogQueue, msg);
      else
        app.log_processing_message(app, msg);
      end
    end

    series_data = bfopenSeries(img_path,series_id,select_images);
    dat=series_data{1};
    % Make image stack
    img = [];
    count = 1;
    for zid=app.plates(plate_num).keep_zslices % also do z filtering
      img(:,:,count) = dat{zid,1};
      count = count + 1;
    end

  else
    img = imread(img_path);
  end

  % Extra work for file types
  if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'MultiChannelFiles'})
    img = img(:,:,chan_num);
  end

end