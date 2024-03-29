function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

  % List Image Files
  img_files = dir([img_dir '\*.tif*']); % ex. \path\Images\*.tif*
  app.plates(plate_num).img_files = img_files;
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found in:\n\n "%s".\n\n Please correct the ImageDir setting in the file:\n\n "%s".\n',img_dir, app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end

  % Example file name:     'Wan Test 3D Run 2 after STIM 1-56_G02.TIF'

  img_filename_meta_info_extraction = regexp({img_files.name},'.*(?<timepoints>\d+)-(?<timepoints2>\d+)_(?<rows>[A-Z])(?<columns>\d+).*','names');

  timepoints1 = cellfun(@(x) x.timepoints,img_filename_meta_info_extraction,'UniformOutput',false);
  timepoints2 = cellfun(@(x) x.timepoints2,img_filename_meta_info_extraction,'UniformOutput',false);
  timepoints = cellfun(@(x) str2num(x),strcat(timepoints1, timepoints2),'UniformOutput',false);
  uniq_timepoints = (unique([timepoints{:}],'sort'));

  rows = cellfun(@(x) uint8(upper(x.rows))-64,img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_rows = unique([rows{:}],'sort');
  columns = cellfun(@(x) str2num(x.columns),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_columns = unique([columns{:}],'sort');
  % fields = cellfun(@(x) str2num(x.fields),img_filename_meta_info_extraction,'UniformOutput',false);
  % uniq_fields = (unique([fields{:}],'sort'));
  % FIELDS ALWAYS 1 because I want a quick fix and removing fields may cause more work elsewhere
  uniq_fields = 1;
  fields = {};
  for idx=1:length(rows)
    fields{idx} = [1];
  end

  app.plates(plate_num).rows = uniq_rows;
  app.plates(plate_num).columns = uniq_columns;
  app.plates(plate_num).fields = uniq_fields;
  app.plates(plate_num).timepoints = uniq_timepoints;

  uniq_channels = 1; % LIMITATION(Dan): I have only had access to a dataset with 1 channel
  channels = ones(length(rows));
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
    multi_channel_img.well_info_string = app.plates(plate_num).wells{multi_channel_img.row, multi_channel_img.column};
    multi_channel_img.well_info_struct = app.plates(plate_num).wells_meta{multi_channel_img.row, multi_channel_img.column};
    for chan_num=[uniq_channels]
      % Currently only works for 1 channel
      image_filename = image_file.name; % ex. CBLG-3776-1NW7_180627130001i3t008H10f01d1.TIF
      multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_filename];
    end
    multi_channel_imgs = [multi_channel_imgs; multi_channel_img];
  end
  app.plates(plate_num).img_files = multi_channel_imgs;
end