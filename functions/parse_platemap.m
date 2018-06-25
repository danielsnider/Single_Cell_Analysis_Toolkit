function [plates, app_parameters] = func(full_path)
  % full_path = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\MY_PLATEMAP.xlsx';
  [num,txt,raw] = xlsread(full_path);

  plates = [];
  
  % Find locations in csv where "BeginPlate" or "Plugin=" is present
  plate_start_locs = [];
  plugin_start_locs = [];
  for y=1:size(raw,1)
    for x=1:size(raw,2)
      if strfind(raw{y,x}, 'BeginPlate')
        plate_start_locs = [plate_start_locs; x y];
      elseif strfind(raw{y,x}, 'Plugin=')
        plugin_start_locs = [plugin_start_locs; x y];
      end
    end
  end

  %% Loop over each plate, parsing it 
  for idx=1:size(plate_start_locs,1)
    plate = {};
    starty = plate_start_locs(idx,2);
    startx = plate_start_locs(idx,1);
    plate_size_text = raw{starty, startx};
    plate_size_struct = regexp(plate_size_text,'BeginPlate-Rows=(?<rows>\d+),Columns=(?<columns>\d+)','names');
    plate.rows = str2num(plate_size_struct.rows); % rows is like y resolution
    plate.columns = str2num(plate_size_struct.columns); % columns is like x resolution
    plate.num_wells = plate.rows*plate.columns;

    %% Store specific well information
    txt_str = cellstr(cellfun(@string, raw));
    txt_str = txt_str(starty+3 : starty+2+plate.rows , startx+1 : startx+plate.columns);
    plate.wells = txt_str;

    %% Load Plate Metadata
    plate.metadata = {};
    offset = 0;
    while true
      iter_xoffset = startx+1+offset;
      if iter_xoffset > size(raw,2) % reached end of file
        break
      end
      key = string(raw{starty,iter_xoffset});
      if isempty(key) | ismissing(key)==1 % reached empty cell 
        break
      end
      key = genvarname(key);
      value = raw{starty+1,iter_xoffset};
      if key == "Ch2" % dealing with empty channels
          if isempty(value)
              value = 'NONE';
          end
      elseif key == "Ch3" % dealing with empty channels
          if isempty(value)
              value = 'NONE';
          end
      elseif key == "Ch4" % dealing with empty channels
          if isempty(value)
              value = 'NONE';
          end    
      end
%       fprintf('Reading plate metadata: %s = %s\n',string(key),value);
%       pause()
      if  isnumeric(value)
        plate.metadata.(string(key)) = num2str(value);
      else
        plate.metadata.(string(key)) = (value);
      end

      offset = offset + 1;
      
    end

    %% Assert required plate metadata exists
    assert(isfield(plate.metadata, 'Name'), 'Failed to load platemap because required piece of plate metadata "Name" was not found.')
    assert((isfield(plate.metadata, 'Ch1') | isfield(plate.metadata, 'Ch2') | isfield(plate.metadata, 'Ch3') | isfield(plate.metadata, 'Ch4'))==1, 'Failed to load platemap because no channels were set.')
    assert(isfield(plate.metadata, 'ImageDir'), 'Failed to load platemap because required piece of plate metadata "ImageDir" was not found.')
    assert(isfield(plate.metadata, 'ImageFileFormat'), 'Failed to load platemap because required piece of plate metadata "ImageFileFormat" was not found.')

    %% Set default plate number setting. The plate number in the filename of images. For example see "p01" in r05c04f49p01-ch3sk1fk1fl1.tiff. 
    if strcmp(plate.metadata.ImageFileFormat, 'OperettaSplitTiffs')
      if ~isfield(plate, 'PlateNumber')
        plate.plate_num = 1;
      end
    end

    %% Find Condition Columns (extra columns on the right hand side of the plate to describe the experiment)
    condition_column_keys = {};
    condition_column_values = {};
    if plate.columns > 0
      xoffset = 1 + startx + plate.columns;
      yoffset = 2 + starty;
      count = 0;
      while true
        iter_xoffset = xoffset+count;
        if iter_xoffset > size(raw,2) % reached end of file
          break
        end
        key = raw{yoffset, iter_xoffset};
        if isempty(key) % reached empty cell 
          break
        end
        values = {raw{yoffset+1:yoffset+plate.rows,iter_xoffset}};
        count = count + 1;
        condition_column_values{count} = values;
        condition_column_keys{count} = key;
      end
    end

    %% Find Condition Rows (extra columns on the right hand side of the plate to describe the experiment)
    condition_row_keys = {};
    condition_row_values = {};
    if plate.rows > 0
      xoffset = startx;
      yoffset = 3 + starty + plate.rows;
      count = 0;
      while true
        iter_yoffset = yoffset+count;
        if iter_yoffset > size(raw,1) % reached end of file
          break
        end
        key = raw{iter_yoffset, xoffset};
        if isempty(key) % reached empty cell 
          break
        end
        values = {raw{iter_yoffset, xoffset+1:xoffset+plate.columns}};
        count = count + 1;
        condition_row_values{count} = values;
        condition_row_keys{count} = key;
      end
    end    
    
    
    %% Add the experimental information found in the condition columns to the well info of each individual well (seperated by commas)
    % Initialize a cope of plate.wells to store meta-datastructures
    plate.wells_meta = plate.wells;
    % Loop over condition columns
    for n=1:length(condition_column_keys)
      key = condition_column_keys{n};
      values = condition_column_values{n};
      % Loop over each item in the condition column
      for yy=1:length(values)
        if isnan(values{yy}) % Skip unset items
          continue
        end
        val = toString(values{yy}, 'disp');
        condition = sprintf('%s %s', key, val);
        % Loop over well info items in this plate row and add the information found in the condition column to each well info
        for xx=1:plate.columns
          if any([~isstruct(plate.wells{yy,xx})&isnan(plate.wells{yy,xx})  isempty(plate.wells{yy,xx})]) % skip unset wells
            continue
          end
          % Append info seperated by a comma
          plate.wells{yy,xx} = sprintf('%s, %s', plate.wells{yy,xx}, condition);
          % Append datastructure info to plate.wells_meta
          if ~isstruct(plate.wells_meta{yy,xx})
            plate.wells_meta{yy,xx} = struct();
          end
          plate.wells_meta{yy,xx}.WellCondition = txt_str{yy,xx};
          plate.wells_meta{yy,xx}.(matlab.lang.makeValidName(key)) = val;
        end
      end
    end

    %% Add the experimental information found in the condition rows to the well info of each individual well (seperated by commas)
    % Loop over condition rows
    for n=1:length(condition_row_keys)
      key = condition_row_keys{n};
      values = condition_row_values{n};
      % Loop over each item in the condition row
      for xx=1:length(values)
        if isnan(values{xx}) % Skip unset items
          continue
        end
        val = toString(values{xx}, 'disp');
        condition = sprintf('%s %s', key, val);
        condition_meta = val;
        % Loop over well info items in this plate column and add the information found in the condition row to each well info
        for yy=1:plate.rows
%           if any([(~isstruct(plate.wells{yy,xx})&isnan(plate.wells{yy,xx})) isempty(plate.wells{yy,xx})]) % skip unset wells
          if isempty(plate.wells{yy,xx})
            continue
          end
          % Append info seperated by a comma
          plate.wells{yy,xx} = sprintf('%s, %s', plate.wells{yy,xx}, condition);
          % Append datastructure info to plate.wells_meta
          if ~isstruct(plate.wells_meta{yy,xx})
            plate.wells_meta{yy,xx} = struct();
          end
          plate.wells_meta{yy,xx}.WellCondition = txt_str{yy,xx};
          
          % Temporary fix. Need to delve further into what the issue might
          % be
          disp(key)
          try
            plate.wells_meta{yy,xx}.(matlab.lang.makeValidName(key)) = (val);
          catch
            continue
          end
          
        end
      end
    end
     
    plate.name = plate.metadata.Name;

    %% Store plate information
    plates = [plates; plate];
  end

  %% Loop over each plugin, parsing it 
  plugins = [];
  raw_size_1 = size(raw,1);
  for idx=1:size(plugin_start_locs,1)
    plugin = {};
    starty = plugin_start_locs(idx,2);
    startx = plugin_start_locs(idx,1);

    % Plugin Info
    plugin_text = raw{starty, startx};
    plugin_text = regexp(plugin_text,'Plugin=(?<type>\w+)','names');
    typ = lower(plugin_text.type); % eg. 'segmentation','measurement'
    plugin.type = typ;
    plugin.identifier = raw{starty+2, startx};
    plugin.name = raw{starty+4, startx};

    % Plugin Parameters
    plugin.parameters = containers.Map;
    offset=0;
    while true
      iter_yoffset = offset+starty+1;
      offset = offset+1;
      if iter_yoffset > raw_size_1 % reached end of file
        break
      end
      key=raw{iter_yoffset, startx+1};
      value=raw{iter_yoffset, startx+2};
      if any(isnan(key)) || isempty(key)
        break % found whitespace at end of plugin parameters, stop looping
      end
      if any(isnan(value)) || isempty(value)
        continue % ignore empty values
      end
      plugin.parameters(key) = value;
    end
    plugins = [plugins; plugin];
  end
  app_parameters.plugins = plugins;

end