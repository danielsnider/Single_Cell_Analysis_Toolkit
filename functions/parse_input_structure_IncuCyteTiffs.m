function fun(app, plate_num)

img_dir = app.plates(plate_num).metadata.ImageDir;




 
  % List Image Files. All 4 if statements, with onl 2 returning true takes ~ 10.638689 seconds to execute
  if ~contains(app.plates.metadata.Ch1,{'NaN','NONE'})
      img_files = dir([img_dir '\*' app.plates.metadata.Ch1 '\*.tif*']); % ex. \path\Images\*p01*.tif* Takes ~4.119164 seconds to execute
      app.plates(plate_num).img_files.Ch1 = img_files;
      channels_1 = repelem(1,size(img_files,1));
      uniq_channels = unique(channels_1,'sort');
  end

  if ~contains(app.plates.metadata.Ch2,{'NaN','NONE'})
      img_files = dir([img_dir '\*' app.plates.metadata.Ch2 '\*.tif*']); % ex. \path\Images\*p01*.tif*
      app.plates(plate_num).img_files.Ch2 = img_files;
      channels_2 = repelem(2,size(img_files,1));
      uniq_channels = [uniq_channels unique(channels_2,'sort')];
  end
  
  if ~contains(app.plates.metadata.Ch3,{'NaN','NONE'})
      img_files = dir([img_dir '\*' app.plates.metadata.Ch3 '\*.tif*']); % ex. \path\Images\*p01*.tif*
      app.plates(plate_num).img_files.Ch3 = img_files;
      channels_3 = repelem(3,size(img_files,1));
      uniq_channels = [uniq_channels unique(channels_3,'sort')];
  end
  
  if ~contains(app.plates.metadata.Ch4,{'NaN','NONE'})
      img_files = dir([img_dir '\*' app.plates.metadata.Ch4 '\*.tif*']); % ex. \path\Images\*p01*.tif*
      app.plates(plate_num).img_files.Ch4 = img_files;
      channels_4 = repelem(4,size(img_files,1));
      uniq_channels = [uniq_channels unique(channels_4,'sort')];
  end
  
  
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found in:\n\n "%s".\n\n Please correct the ImageDir setting in the file:\n\n "%s".\n',img_dir, app.ChooseplatemapEditField.Value);
    title_ = 'Image Files Not Found';
    throw_application_error(app,msg,title_);
  end
  
  plates = repelem(plate_num,size(img_files,1));
  uniq_plates = unique(plates,'sort');
  
  
  img_filename_meta_info_extraction = regexp({img_files.name}','_(?<rows>[A-Z])(?<columns>\d+)_(?<fields>\d+)_(?<timepoints>\d+y\d+m\d+d_\d+h\d+m).tif','names');
  
  % Get unique row, column, etc. values from all the image names. Running row/col/field and timepoint collection takes 2.522679 seconds
  rows = cellfun(@(x) x.rows,img_filename_meta_info_extraction,'UniformOutput',false);
  convert_num_rows = cellfun(@(x) uint8(upper(x))-64,rows,'UniformOutput',false);
  uniq_rows = unique([convert_num_rows{:}],'sort');
  columns = cellfun(@(x) str2num(x.columns),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_columns = unique([columns{:}],'sort');
  fields = cellfun(@(x) str2num(x.fields),img_filename_meta_info_extraction,'UniformOutput',false);
  uniq_fields = (unique([fields{:}],'sort'));
  timepoints = cellfun(@(x) x.timepoints,img_filename_meta_info_extraction,'UniformOutput',false);
  
  tmp = regexprep(timepoints,'m$','');
  tmp2 = regexprep(tmp,'h',':');
  tmp3 = regexprep(tmp2,'y|m','-');
  tmp4 = regexprep(tmp3,'d','');
  tmp5 = regexprep(tmp4,'_',' ');
  
  t = cellstr(datestr(datetime(tmp5,'InputFormat','yyyy-MM-dd HH:mm')));
  t_sort = sort(t);
  tt = unique(t_sort);
  tt_ids = [1:length(tt)]';
  for i=1:length(tt_ids)
      t(contains(t,datestr(tt(i)))) = cellstr(num2str(tt_ids(i)));
  end

  t = cellfun(@(x) str2num(x),t(:),'UniformOutput',false);
  uniq_timepoints = unique([t{:}] ,'stable');
  


  app.plates(plate_num).rows = uniq_rows;
  app.plates(plate_num).columns = uniq_columns;
  app.plates(plate_num).fields = uniq_fields;
  app.plates(plate_num).timepoints = uniq_timepoints;
  app.plates(plate_num).channels = uniq_channels;
  app.plates(plate_num).plates = uniq_plates;
  

if ~contains(app.plates.metadata.Ch1,{'NaN','NONE'})
    
    r = num2cell(convert_num_rows);
    [app.plates(plate_num).img_files.Ch1.row] = r{:};
    c = num2cell(columns);
    [app.plates(plate_num).img_files.Ch1.column] = c{:};
    f = num2cell(fields);
    [app.plates(plate_num).img_files.Ch1.field] = f{:};
    t = num2cell(t);
    [app.plates(plate_num).img_files.Ch1.timepoint] = t{:};
    c = num2cell(channels_1);
    [app.plates(plate_num).img_files.Ch1.channel] = c{:};
    p = num2cell(plates);
    [app.plates(plate_num).img_files.Ch1.plate] = p{:};
    
    
end

if ~contains(app.plates.metadata.Ch2,{'NaN','NONE'})
    
    r = num2cell(convert_num_rows);
    [app.plates(plate_num).img_files.Ch2.row] = r{:};
    c = num2cell(columns);
    [app.plates(plate_num).img_files.Ch2.column] = c{:};
    f = num2cell(fields);
    [app.plates(plate_num).img_files.Ch2.field] = f{:};
    t = num2cell(t);
    [app.plates(plate_num).img_files.Ch2.timepoint] = t{:};
    c = num2cell(channels_2);
    [app.plates(plate_num).img_files.Ch2.channel] = c{:};
    p = num2cell(plates);
    [app.plates(plate_num).img_files.Ch2.plate] = p{:};
    
    
end

if ~contains(app.plates.metadata.Ch3,{'NaN','NONE'})
    
    r = num2cell(convert_num_rows);
    [app.plates(plate_num).img_files.Ch3.row] = r{:};
    c = num2cell(columns);
    [app.plates(plate_num).img_files.Ch3.column] = c{:};
    f = num2cell(fields);
    [app.plates(plate_num).img_files.Ch3.field] = f{:};
    t = num2cell(t);
    [app.plates(plate_num).img_files.Ch3.timepoint] = t{:};
    c = num2cell(channels_3);
    [app.plates(plate_num).img_files.Ch3.channel] = c{:};
    p = num2cell(plates);
    [app.plates(plate_num).img_files.Ch3.plate] = p{:};
    
    
end

if ~contains(app.plates.metadata.Ch4,{'NaN','NONE'})
    
    r = num2cell(convert_num_rows);
    [app.plates(plate_num).img_files.Ch4.row] = r{:};
    c = num2cell(columns);
    [app.plates(plate_num).img_files.Ch4.column] = c{:};
    f = num2cell(fields);
    [app.plates(plate_num).img_files.Ch4.field] = f{:};
    t = num2cell(t);
    [app.plates(plate_num).img_files.Ch4.timepoint] = t{:};
    c = num2cell(channels);
    [app.plates(plate_num_4).img_files.Ch4.channel] = c{:};
    p = num2cell(plates);
    [app.plates(plate_num).img_files.Ch4.plate] = p{:};
  
end
startTime = tic;
  % Reorganize. Takes ~ 1013.724080 seconds/ 16.8954 minutes to process 12,600 images for 2 different channels
  disp('Start Reorganizing Image naming data')
  multi_channel_imgs = [];
  Channels_in_Struct = fieldnames(app.plates(plate_num).img_files);
  img_files = app.plates(plate_num).img_files.(char(Channels_in_Struct(1)));
  for img_num=1:length(img_files)
      fprintf('Reorganizing ... image number %i\n', img_num)
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
      for chan_num = 1:size(Channels_in_Struct,1)
          fprintf('--- Storing Channel %i info\n',chan_num)
          img_files = app.plates(plate_num).img_files.(char(Channels_in_Struct(chan_num)));
          image_file = img_files(img_num);
          multi_channel_img.chans(chan_num).path = [image_file.folder '\' image_file.name];
      end
      multi_channel_imgs = [multi_channel_imgs; multi_channel_img];

  end
toc(startTime)
  app.plates(plate_num).img_files = multi_channel_imgs;

end