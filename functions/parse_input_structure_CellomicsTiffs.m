function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

  % List Image Files
  img_files = dir([img_dir '\*.tif*']); % ex. \path\Images\*.tif*
  app.plates(plate_num).img_files = img_files;
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end

  % Example file name:     'CBLG-3776-1NW7_180627130001i3t001A01f01d1.TIF'

  img_filename_meta_info_extraction = regexp({img_files.name},'.*t(?<timepoints>\d+)(?<rows>[A-Z])(?<columns>\d+)f(?<fields>\d+).*','names');
  % row_letters = cellfun(@(x) x.rows,img_filename_meta_info_extraction,'UniformOutput',false)
  % uniq_row_letters = unique(rows,'sort');
  rows = cellfun(@(x) uint8(upper(x.rows))-64,img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_rows = unique([rows{:}],'sort');
  columns = cellfun(@(x) str2num(x.columns),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_columns = unique([columns{:}],'sort');
  fields = cellfun(@(x) str2num(x.fields),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_fields = (unique([fields{:}],'sort'));
  timepoints = cellfun(@(x) str2num(x.timepoints),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_timepoints = (unique([timepoints{:}],'sort'));

  app.plates(plate_num).rows = uniq_rows;
  app.plates(plate_num).columns = uniq_columns;
  app.plates(plate_num).fields = uniq_fields;
  app.plates(plate_num).timepoints = uniq_timepoints;

  uniq_channels = 1; % LIMITATION(Dan): I have only had access to a dataset with 1 channel
  channels = ones(length(fields));
  app.plates(plate_num).channels = uniq_channels;

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
    for chan_num=[uniq_channels]
      image_filename = image_file.name; % ex. r02c02f01p01-ch2sk1fk1fl1.tiff
      image_filename(16) = chan_nums_str{chan_num}; % change the channel number
      multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_filename];
    end
    multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
  end
  app.plates(plate_num).img_files = multi_channel_imgs;
end