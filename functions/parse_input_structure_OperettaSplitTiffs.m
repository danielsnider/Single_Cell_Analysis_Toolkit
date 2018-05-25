function fun(app, plate_num)
  img_dir = app.plates(plate_num).metadata.ImageDir;

  % The plate number in the filename of images
  plate_num_file_part = sprintf('p%02d',app.plates(plate_num).plate_num); % ex. p01   Needed to handle different plate numbers in image filenames.

  % List Image Files
  img_files = dir([img_dir '\*' plate_num_file_part '*.tif*']); % ex. \path\Images\*p01*.tif*
  app.plates(plate_num).img_files = img_files;
  
  if isempty(img_files)
    msg = sprintf('Aborting because there were no image files found. Please correct the ImageDir setting in the file "%s".',app.ChooseplatemapEditField.Value);
    uialert(app.UIFigure,msg,'Image Files Not Found', 'Icon','error');
    error(msg);
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

  % well_info = struct('row',rows,'column',columns,'field',fields,'timepoint',timepoints,'channel',channels,'plate',plates);
  % app.plates(plate_num).well_info = well_info;
  % % Set add the row, column, field, etc. values for each file to their struct data in app.plate.img_files
  % for file_num=1:length(app.plates(plate_num).img_files)
  %   app.plates(plate_num).img_files(file_num).row = rows(file_num);
  %   app.plates(plate_num).img_files(file_num).column = columns(file_num);
  %   app.plates(plate_num).img_files(file_num).field = fields(file_num);
  %   app.plates(plate_num).img_files(file_num).timepoint = timepoints(file_num);
  %   app.plates(plate_num).img_files(file_num).channel = channels(file_num);
  %   app.plates(plate_num).img_files(file_num).plate = plates(file_num);
  % end
end