function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

  % List Image Files
  img_files = dir([img_dir '\*.tif*']);
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end

  % Zeiss starts channel nums sometimes at 0
  offset = 0;
  file_naming_has_id_number_then_channel = false;
  last_chan_num = NaN;

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
    img_files(img_num).chan_num = chan_num+offset; % Zeiss starts channel nums at 0 sometimes
    img_files(img_num).filename_without_channel = [patterns.filepart1 patterns.filepart2];
  end
  
  app.plates(plate_num).channels = unique([img_files.chan_num],'stable');
  chan_nums = app.plates(plate_num).channels;
  num_chans = length(chan_nums);
  
  %% Detect wether image files are sorted in a way where all channel 1 image are before all channel 2 images
  % We compare the first two images to see if the channel number changes
  if length(img_files)>=2
    img1_pattern = regexp(img_files(1).name,'(?<filepart1>.*)_[s]?[\d]?[cC][0]?(?<chan_num>\d)(?<filepart2>.*)','names');
    img1_chan_num = str2num(img1_pattern.chan_num);
    img2_pattern = regexp(img_files(2).name,'(?<filepart1>.*)_[s]?[\d]?[cC][0]?(?<chan_num>\d)(?<filepart2>.*)','names');
    img2_chan_num = str2num(img1_pattern.chan_num);
    if img1_chan_num == img2_chan_num
      file_naming_has_id_number_then_channel = false;
    end
  end

  % Store unique values
  if file_naming_has_id_number_then_channel
    app.plates(plate_num).experiments = unique({img_files.filename_without_channel},'stable');
  else
    image_names = unique({img_files.name},'stable'); 
    image_names = image_names(1:length(img_files)/num_chans); % get the set of filenames for the first channel only
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