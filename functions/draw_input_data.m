function fun(app, createCallbackFcn)
  tabgp = uitabgroup(app.Tab_Input,'Position',[17,20,803,477]);
  app.input_data.tabgp = tabgp;
  app.input_data.unique_channels = get_unique_channel_names(app);

  %% Filter input data
  function changed_FilterInput_(app, event)
    plate_num = event.Source.UserData;
    changed_FilterInput(app, plate_num);
  end

  for plate_num=1:length(app.plates)
    plate = app.plates(plate_num);

    tab = uitab(tabgp,'Title',sprintf('Plate %s', num2str(plate_num)), ...
      'BackgroundColor', [1 1 1]);

    plate_label = uilabel(tab, 'Text', plate.metadata.Name, 'Position', [34,413,494,33], 'FontSize', 24, 'FontName', 'Yu Gothic UI Light');

    dirfield = uieditfield(tab, 'Value', plate.metadata.ImageDir, 'Position', [636,413,153,22], 'FontSize', 12, 'FontName', 'Helvetica', 'Editable','off');
    dirlabel = uilabel(tab, 'Text', 'Path to Images:', 'Position', [548,413,91,21], 'FontSize', 12, 'FontName', 'Yu Gothic UI');

    channel_strings = {};
    if isfield(plate.metadata, 'Ch1')
        channel_strings{1} = sprintf('Ch1: %s', plate.metadata.Ch1);
    end
    if isfield(plate.metadata, 'Ch2')
        channel_strings{2} = sprintf('Ch2: %s', plate.metadata.Ch2);
    end
    if isfield(plate.metadata, 'Ch3')
        channel_strings{3} = sprintf('Ch3: %s', plate.metadata.Ch3);
    end
    if isfield(plate.metadata, 'Ch4')
        channel_strings{4} = sprintf('Ch4: %s', plate.metadata.Ch4);
    end
    channel_box = uilistbox(tab, 'Position', [13,305,130,74], 'FontSize', 12, ...
        'FontName', 'Helvetica', 'Items', channel_strings);
    channel_label = uilabel(tab, 'Text', 'Image Channels:', 'Position', [14,386,107,20], 'FontSize', 14, 'FontName', 'Yu Gothic UI');

    %% Format plate data from struct to two cell arrays for the metadata uitable, one for column names and one for values
    fields = fieldnames(plate.metadata);
    count = 1;
    keys = {};
    values = {};
    for field_num=1:length(fields)
      field = fields{field_num};
      if ~ischar(plate.metadata.(field)) & ~isnumeric(plate.metadata.(field))
          continue
      end
      val = plate.metadata.(field);
      keys{count} = field;
      values{count} = val;
      count = count + 1;
    end

    %% Meta Data Table
    metadata_table = uitable(tab,'Data',values,'ColumnName', keys, ...
      'RowName',{'MetaData'}, 'Position',[163,305,626,74], ...
      'ColumnEditable',true);
    metadata_label = uilabel(tab, 'Text', 'Plate Metadata:', 'Position', [163,386,102,20], 'FontSize', 14, 'FontName', 'Yu Gothic UI');

    % Number of Images
    numimages_label = uilabel(tab, 'Text', 'Number of Images:', ...
      'Position', [26,132,112,20], 'FontSize', 12, 'FontName', 'Yu Gothic UI', ...
      'HorizontalAlignment', 'right');
    app.plates(plate_num).NumberOfImagesField = uieditfield(tab, 'Position', [87,105,56,22], ...
      'UserData', plate_num, ...
      'Editable', 'off', ...
      'HorizontalAlignment', 'right');

    % Generate plate row column labels, ex. A, B, C
    unicode_A = 65; % unicode for A
    unicode_end = 65 + plate.rows; % ex. 'ABCDEF'
    letters = split(char(unicode_A):char(unicode_end),''); % ex. {0x} {A} {B}
    letters = {letters{2:end-1}}; % first and last are empty, thx matlab

    % Replace "NaN" to "" in the wells
    for x=1:size(plate.wells,1)
      for y=1:size(plate.wells,2)
        if isnan(plate.wells{x,y})
          plate.wells{x,y} = '';
        end
      end
    end

    visibility = 'on';
    if strcmp(plate.metadata.ImageFileFormat, 'ZeissSplitTiffs')
      pos = numimages_label.Position;
      numimages_label.Position = [pos(1) 276 pos(3) pos(4)]; % Move up because some fields will be missing for Zeiss
      pos = app.plates(plate_num).NumberOfImagesField.Position;
      app.plates(plate_num).NumberOfImagesField.Position = [pos(1) 249 pos(3) pos(4)]; % Move up because some fields will be missing for Zeiss
      visibility = 'off'; % hide the rest of the input fields, they are from row, column, etc. Operetta stuff
    end

    %% Plate Map Table
    well_table = uitable(tab,'Data',plate.wells,'Visible', visibility, 'Position',[163,15,624,254], ...
      'ColumnEditable',true, 'RowName',letters);
    well_label = uilabel(tab, 'Text', 'Plate Map:', 'Visible', visibility, 'Position', [163,276,73,20], 'FontSize', 14, 'FontName', 'Yu Gothic UI');

    %% Filter Data
    filter_label = uilabel(tab, 'Text', 'Filter Input:', 'Visible', visibility, 'Position', [15,276,93,20], 'FontSize', 14, 'FontName', 'Yu Gothic UI');

    rows_label = uilabel(tab, 'Text', 'Rows:', 'Visible', visibility, 'Position', [48,248,34,20], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_rows = uieditfield(tab, 'Visible', visibility, 'Position', [87,247,56,22], ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    columns_label = uilabel(tab, 'Text', 'Columns:', 'Visible', visibility, 'Position', [26,219,56,20], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_columns = uieditfield(tab, 'Visible', visibility, 'Position', [87,218,56,22], ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    fields_label = uilabel(tab, 'Text', 'Fields:', 'Visible', visibility, 'Position', [43,190,39,20], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_fields = uieditfield(tab, 'Visible', visibility, 'Position', [87,189,56,22], ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    timepoints_label = uilabel(tab, 'Text', 'Timepoints:', 'Visible', visibility, 'Position', [15,161,67,20], 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_timepoints = uieditfield(tab, 'Visible', visibility, 'Position', [87,160,56,22], ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );


  end

end
