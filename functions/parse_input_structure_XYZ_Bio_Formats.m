function parse_input_structure_XYZ_Split_Bio_Formats(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;
  current_series_id = app.ExperimentDropDown.Value;

  % List Image Files
  % Example: Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif
%   img_files = dir([img_dir '\*']);
img_files = dir([img_dir '/*']);
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
  % Remove subfolders if any
  img_files( cell2mat({img_files.isdir}) ) = []; % do delete
 
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found in:\n\n "%s".\n\n Please correct the ImageDir setting in the file:\n\n "%s".\n',img_dir, app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end

  multi_channel_imgs = [];
  for img_num=1:length(img_files)
    full_path = fullfile(img_files(img_num).folder, img_files(img_num).name);
    try
      data = bfopen(full_path,1, 1, 1, 1);
    catch ME
      error_msg = getReport(ME,'extended','hyperlinks','off');
      msg = sprintf('Unable to read image file: "%s".\n\nThe error was:\n\n%s',full_path,error_msg);
      title_ = 'Unable to read image file';
      if strfind(ME.message,'Unknown file format')
        msg = sprintf('Unable to read image file: "%s". \n\nThe file type is not a supported image type. Perhaps you have more than just images in the folder. Or perhaps you have the wrong ''ImageFileFormat'' in your plate map spreadsheet.\n\nThe error was:\n\n%s',full_path,error_msg);
      end
      throw_application_error(app,msg,title_)
    end


    first_series = 1;
    dat = data{first_series};
    omeMeta = data{first_series,4};
    ome_series_id = 0; % OME starts at 0
    stack_name = matlab.lang.makeValidName(char(omeMeta.getImageName(ome_series_id)));
    full_file_name = dat{1,2}; % example:         'C:\Users\danie\Dropbox\Kafri\Projects\Single_Cell_Analysis_Toolkit\daniel\Derrick_3D_images\control\HeLa_aPMP70-568 siCtrl_1z4.lsm; plane 1/5; Z?=1/5'
    multi_channel_img = [];
    multi_channel_img.zslices = 1:omeMeta.getPixelsSizeZ(ome_series_id).getValue(); % number of Z slices;
    multi_channel_img.channel_nums = 1:omeMeta.getChannelCount(ome_series_id);
    multi_channel_img.plate_num = plate_num;

    multi_channel_img.chans = [];
    multi_channel_img.ImageName = stack_name;
    multi_channel_img.experiment = stack_name;
    multi_channel_img.experiment_num = length(multi_channel_imgs)+1;
    for chan_num=multi_channel_img.channel_nums
      multi_channel_img.chans(chan_num).folder = img_files(img_num).folder;
      multi_channel_img.chans(chan_num).path = full_path;
    end
    multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
  end

  app.plates(plate_num).img_files = multi_channel_imgs;
  app.ExperimentDropDown.UserData = multi_channel_imgs;
  app.plates(plate_num).channels = 1:omeMeta.getChannelCount(ome_series_id);
  app.plates(plate_num).experiments  = unique({multi_channel_imgs.ImageName});
  app.plates(plate_num).zslices = 1:max([multi_channel_imgs.zslices]);

end