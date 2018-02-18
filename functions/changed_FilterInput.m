function func(app, plate_num)

  filter_names = { ...
    'rows', ...
    'columns', ...
    'fields', ...
    'timepoints' ...
  };

  if strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'ZeissSplitTiffs')

    app.RowDropDown.Visible = 'off';
    app.ColumnDropDown.Visible = 'off';
    app.FieldDropDown.Visible = 'off';
    app.TimepointDropDown.Visible = 'off';
    app.RowDropDownLabel.Visible = 'off';
    app.ColumnDropDownLabel.Visible = 'off';
    app.FieldDropDownLabel.Visible = 'off';
    app.TimepointDropDownLabel.Visible = 'off';
    app.plates(plate_num).img_files_subset = app.plates(plate_num).img_files;

  elseif strcmp(app.plates(plate_num).metadata.ImageFileFormat, 'OperettaSplitTiffs')
    app.RowDropDown.Visible = 'on';
    app.ColumnDropDown.Visible = 'on';
    app.FieldDropDown.Visible = 'on';
    app.TimepointDropDown.Visible = 'on';
    app.RowDropDownLabel.Visible = 'on';
    app.ColumnDropDownLabel.Visible = 'on';
    app.FieldDropDownLabel.Visible = 'on';
    app.TimepointDropDownLabel.Visible = 'on';

    for filt_num = 1:length(filter_names)
      filter_name = filter_names{filt_num};

      %% Consolidate userfriendly filter format of '1','1,2', or '1,2,1:3','*' into a list [1 2 3]
      avail_vals = app.plates(plate_num).(filter_name); % the relavent field of interest, ex. row or column
      keep_request = app.plates(plate_num).(['filter_' filter_name]).Value; % the user input text box for what data they want to keep
      % Check for allowed characters, if user has not given only digits or '-' or '-', then set to default of '' empty to be updated to all available
      if ~isempty(keep_request)
        if any(regexp(unique(keep_request),'[^1-9-,]'))
          keep_request='';
        end
      end
      % Handle empty or '*' and use all available values
      if any([isempty(keep_request),strcmp(keep_request,''),strfind(keep_request,'*')])
        keep_vals = avail_vals;

      % Handle valid request such as '1','1,2', or '1,2,1:3','*' and turn into into a list [1 2 3]
      else
        keep_request = strrep(keep_request,'-',':'); % replace '1-3' to '1:3' so that matlab can parse correct syntax with str2num
        keep_vals = str2num(keep_request); % convert string such as '1,2,1:3' to number [1 2 1 2 3]. Yes, this executes code to expand the numbers, lol.
        keep_vals = unique(keep_vals); % remove duplicate numbers
        keep_vals = keep_vals(ismember(keep_vals,avail_vals)); % only keep values that exist in the avail_vals
        keep_vals = sort(keep_vals); % important for next step
      end

      % When no values were givin that are in the available values, use all available values values
      if isempty(keep_vals)
        keep_vals = avail_vals;
      end

      % Set the output text to display in the user interface
      if unique(diff(keep_vals)) == 1 % monotonically increasing values by 1 each step ex. 1,2,3, then set the displayed text in the user interface edit box to 1:3
        txt = [num2str(min(keep_vals)) '-' num2str(max(keep_vals))];
      else
        txt = strjoin(string(keep_vals),',');
      end
      % Update the text in the user interface edit box
      app.plates(plate_num).(['filter_' filter_name]).Value = txt;
      % Save values to app for filtering which will happen next
      app.plates(plate_num).(['keep_' filter_name]) = keep_vals;
    end

    % Filter file names in list
    app.plates(plate_num).img_files_subset = app.plates(plate_num).img_files;
    for filt_num = 1:length(filter_names)
      filter_name = filter_names{filt_num}; % get variable name to operate on
      filter_nam = filter_name(1:end-1); % remove 's' due to discrepancy in variable naming 
      img_vals=cell2mat([app.plates(plate_num).img_files_subset.(filter_nam)]); % the variable value for each image
      allowed_vals=app.plates(plate_num).(['keep_' filter_name]); % the allowed values
      selector = ismember(img_vals,allowed_vals); % get a list of which images are allowed
      subset=app.plates(plate_num).img_files_subset(selector); % access subset
      app.plates(plate_num).img_files_subset = subset; % save subset
    end
  end

  % Update the UI with the subset number of images
  app.plates(plate_num).NumberOfImagesField.Value = num2str(length(app.plates(plate_num).img_files_subset));

  % Update Display UI 
  % draw_display_image_selection(app);

end