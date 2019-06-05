function parse_input_structure_MultiChannelFiles(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

  % List Image Files
  % Example: HeLa_aPMP70-568siCtrl_8z5.lsm
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
    msg = sprintf('Aborting because there were no image files found in:\n\n "%s".\n\n Please correct the ImageDir setting in the file:\n\n "%s".\n',img_dir, app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end

  % Determine channel numbers
  chan_nums = [];
  for chan_num=1:4 % limited to four channels
    if isfield(app.plates(plate_num).metadata,['Ch' num2str(chan_num)])
      chan_name = getfield(app.plates(plate_num).metadata,['Ch' num2str(chan_num)]);
      chan_nums = [chan_nums chan_num];
    end
  end
  app.plates(plate_num).channels = chan_nums;

  % Store unique values
  app.plates(plate_num).experiments = {img_files.name};

  % Store images data structure
  multi_channel_imgs = [];
  for img_num=1:length(img_files)
    multi_channel_img = {};
    multi_channel_img.channel_nums = chan_nums;
    multi_channel_img.plate_num = plate_num;
    multi_channel_img.chans = [];
    image_file = img_files(img_num);
    multi_channel_img.experiment = image_file.name;
    multi_channel_img.experiment_num = length(multi_channel_imgs)+1;
    multi_channel_img.ImageName = image_file.name;
    for chan_num=[chan_nums]
      multi_channel_img.chans(chan_num).folder = image_file.folder;
      multi_channel_img.chans(chan_num).path = fullfile(image_file.folder, image_file.name);
    end
    multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
  end
  app.plates(plate_num).img_files = multi_channel_imgs;
end