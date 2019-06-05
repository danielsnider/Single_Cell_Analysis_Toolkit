function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;
  % The plate number in the filename of images
  plate_num_file_part = sprintf('p%02d',app.plates(plate_num).plate_num); % ex. p01   Needed to handle different plate numbers in image filenames.

  % List Image Files
  img_files = dir([img_dir '/*' plate_num_file_part '*.tif*']); % ex. \path\Images\*p01*.tif*
  app.plates(plate_num).img_files = img_files;
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
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

  % Reorganize
  img_files = app.plates(plate_num).img_files;
  multi_channel_imgs = [];
  chan_nums_str = {'1','2','3','4'};
  for img_num=1:length(img_files)
    multi_channel_img = {};
    multi_channel_img.channel_nums = uniq_channels;
    multi_channel_img.plate_num = plate_num;
    multi_channel_img.chans = [];
    image_file = img_files(img_num);
    multi_channel_img.row = image_file.row{:};
    multi_channel_img.column = image_file.column{:};
    multi_channel_img.field = image_file.field{:};
    multi_channel_img.timepoint = image_file.timepoint{:};
    multi_channel_img.ImageName = image_file.name;
    multi_channel_img.well_info_string = app.plates(plate_num).wells{multi_channel_img.row, multi_channel_img.column};
    multi_channel_img.well_info_struct = app.plates(plate_num).wells_meta{multi_channel_img.row, multi_channel_img.column};
    for chan_num=[uniq_channels]
      image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
      image_filename(16) = chan_nums_str{chan_num}; % change the channel number
      multi_channel_img.chans(chan_num).path = [image_file.folder '/' image_filename];
    end
    multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
  end
  app.plates(plate_num).img_files = multi_channel_imgs;
end
