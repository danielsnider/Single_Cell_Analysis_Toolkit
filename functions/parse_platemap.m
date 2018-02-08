function plates = func(full_path)
  % full_path = 'C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\daniel\MY_PLATEMAP.xlsx';
  [num,txt,raw] = xlsread(full_path);

  plates = [];


  % Find locations in csv where "BeginPlate" is present
  plate_start_locs = [];
  for y=1:size(txt,1)
    for x=1:size(txt,2)
      if strfind(txt{y,x}, 'BeginPlate')
          plate_start_locs = [plate_start_locs; x y];
      end
    end
  end

  %% Loop over each plate, parsing it
  for idx=1:size(plate_start_locs,1)
    plate = {};
    starty = plate_start_locs(idx,2);
    startx = plate_start_locs(idx,1);
    plate_size_text = txt{starty, startx};
    plate_size_struct = regexp(plate_size_text,'BeginPlate-Rows=(?<rows>\d+),Columns=(?<columns>\d+)','names');
    plate.rows = str2num(plate_size_struct.rows); % rows is like y resolution
    plate.columns = str2num(plate_size_struct.columns); % columns is like x resolution
    plate.num_wells = plate.rows*plate.columns;

    %% Store specific well information
    plate.wells = raw(starty+3 : starty+2+plate.rows , startx+1 : startx+plate.columns);

    %% Load Plate Metadata
    plate.metadata = {};
    offset = 0;
    while true
      iter_xoffset = startx+1+offset;
      if iter_xoffset > size(txt,2) % reached end of file
        break
      end
      key = txt{starty,iter_xoffset};
      value = txt{starty+1,iter_xoffset};
      if isempty(key) | isempty(value) % reached empty cell 
        break
      end
      % fprintf('Reading plate metadata: %s = %s\n',key,value);
      plate.metadata.(key) = value;
      offset = offset + 1;
    end

    %% Assert required plate metadata exists
    assert(isfield(plate.metadata, 'Name'), 'Failed to load platemap because required piece of plate metadata "Name" was not found.')
    assert(isfield(plate.metadata, 'Ch1') | isfield(plate.metadata, 'Ch2') | isfield(plate.metadata, 'Ch3') | isfield(plate.metadata, 'Ch4'), 'Failed to load platemap because no channels were set.')
    assert(isfield(plate.metadata, 'ImageDir'), 'Failed to load platemap because required piece of plate metadata "ImageDir" was not found.')
    assert(isfield(plate.metadata, 'ImageNamingScheme'), 'Failed to load platemap because required piece of plate metadata "ImageNamingScheme" was not found.')
    assert(isfield(plate.metadata, 'ImageFormat'), 'Failed to load platemap because required piece of plate metadata "ImageFormat" was not found.')

    %% Set default plate number setting. The plate number in the filename of images. For example see "p01" in r05c04f49p01-ch3sk1fk1fl1.tiff. 
    if strcmp(plate.metadata.ImageNamingScheme, 'Operetta')
      if ~isfield(plate, 'PlateNumber')
        plate.plate_num = 1;
      end
    end

    %% Find Condition Columns (extra columns on the right hand side of the plate to describe the experiment)
    xoffset = 1 + startx + plate.columns;
    yoffset = 2 + starty;
    condition_column_keys = {};
    condition_column_values = {};
    count = 0;
    while true
      iter_xoffset = xoffset+count;
      if iter_xoffset > size(txt,2) % reached end of file
        break
      end
      key = txt{yoffset, iter_xoffset};
      if isempty(key) % reached empty cell 
        break
      end
      values = {raw{yoffset+1:yoffset+plate.rows,iter_xoffset}};
      count = count + 1;
      condition_column_values{count} = values;
      condition_column_keys{count} = key;
    end

    %% Find Condition Rows (extra columns on the right hand side of the plate to describe the experiment)
    xoffset = startx;
    yoffset = 3 + starty + plate.rows;
    condition_row_keys = {};
    condition_row_values = {};
    count = 0;
    while true
      iter_yoffset = yoffset+count;
      if iter_yoffset > size(txt,1) % reached end of file
        break
      end
      key = txt{iter_yoffset, xoffset};
      if isempty(key) % reached empty cell 
        break
      end
      values = {raw{iter_yoffset, xoffset+1:xoffset+plate.columns}};
      count = count + 1;
      condition_row_values{count} = values;
      condition_row_keys{count} = key;
    end

    %% Add the experimental information found in the condition columns to the well info of each individual well (seperated by commas)
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
          if isnan(plate.wells{yy,xx}) % skip unset wells
            continue
          end
          % Append info seperated by a comma
          plate.wells{yy,xx} = sprintf('%s, %s', plate.wells{yy,xx}, condition);
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
        % Loop over well info items in this plate column and add the information found in the condition row to each well info
        for yy=1:plate.rows
          if isnan(plate.wells{yy,xx}) % skip unset wells
            continue
          end
          % Append info seperated by a comma
          plate.wells{yy,xx} = sprintf('%s, %s', plate.wells{yy,xx}, condition);
        end
      end
    end

    %% Store plate information
    plates = [plates; plate];
  end

end