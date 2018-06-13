function fun(app, createCallbackFcn)
  tabgp = uitabgroup(app.Tab_Input,'Position',[17,20,803,477]);
  app.input_data.tabgp = tabgp;
  app.input_data.unique_channels = get_unique_channel_names(app);

  %% Filter input data
  function changed_FilterInput_(app, event)
    plate_num = event.Source.UserData;
    changed_FilterInput(app, plate_num);
  end

  function CheckCallback(app, event)
    changed_EnabledPlates(app);
  end

  for plate_num=1:length(app.plates)
    plate = app.plates(plate_num);

    tab = uitab(tabgp,'Title',sprintf('Plate %s', num2str(plate_num)), ...
      'BackgroundColor', [1 1 1]);

    % Plate Name
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

    %% Default Positions
    Plate_Map_Table_position = [163,15,624,254];
    Plate_Map_Table_label_position = [163,276,73,20];
    Filter_Data_label_position = [15,276,93,20];
    Filter_Row_label_position = [48,248,34,20];
    Filter_Row_position = [87,247,56,22];
    Filter_Columns_label_position = [26,219,56,20];
    Filter_Columns_position = [87,218,56,22];
    Filter_Fields_label_position = [43,190,39,20];
    Filter_Fields_position = [87,189,56,22];
    Filter_Timepoints_label_position = [15,161,67,20];
    Filter_Timepoints_position = [87,160,56,22];
    Filter_zslices_label_position = [35,130,47,22];
    Filter_zslices_position = [87,131,56,22];

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
%     for x=1:size(plate.wells,1)
%       for y=1:size(plate.wells,2)
%         if isnan(plate.wells{x,y})
%           plate.wells{x,y} = '';
%         end
%       end
%     end

    % Add Plate Checkbox
    app.plates(plate_num).checkbox = uicheckbox(tab, ...
      'Position', [15,419,25,15], ...
      'Value', true, ...
      'Text', '', ...
      'ValueChangedFcn', createCallbackFcn(app, @CheckCallback, true));


    if ismember(app.plates(plate_num).metadata.ImageFileFormat, {'OperettaSplitTiffs'})
      Plate_Map_Table_visibility = 'on';
      Filter_Data_visibility = 'on';
      Filter_Row_visibility = 'on';
      Filter_Columns_visibility = 'on';
      Filter_Fields_visibility = 'on';
      Filter_Timepoints_visibility = 'on';
      Filter_zslices_visibility = 'off';
    elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'ZeissSplitTiffs','SingleChannelFiles','MultiChannelFiles'})
      Plate_Map_Table_visibility = 'off';
      Filter_Data_visibility = 'off';
      Filter_Row_visibility = 'off';
      Filter_Columns_visibility = 'off';
      Filter_Fields_visibility = 'off';
      Filter_Timepoints_visibility = 'off';
      Filter_zslices_visibility = 'off';
      pos = numimages_label.Position;
      numimages_label.Position = [pos(1) 276 pos(3) pos(4)]; % Move up because some fields will be missing for Zeiss
      pos = app.plates(plate_num).NumberOfImagesField.Position;
      app.plates(plate_num).NumberOfImagesField.Position = [pos(1) 249 pos(3) pos(4)]; % Move up because some fields will be missing for Zeiss
    elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZ-Bio-Formats','XYZC-Bio-Formats'})
      Plate_Map_Table_visibility = 'off';
      Filter_Data_visibility = 'off';
      Filter_Row_visibility = 'off';
      Filter_Columns_visibility = 'off';
      Filter_Fields_visibility = 'off';
      Filter_Timepoints_visibility = 'off';
      Filter_zslices_visibility = 'on';
      Filter_zslices_label_position = [15,248,67,20];
      Filter_zslices_position = [87,247,56,22];
      pos = numimages_label.Position;
      numimages_label.Position = [pos(1) 210 pos(3) pos(4)]; % Move up because some fields will be missing
      pos = app.plates(plate_num).NumberOfImagesField.Position;
      app.plates(plate_num).NumberOfImagesField.Position = [pos(1) 183 pos(3) pos(4)]; % Move up because some fields will be missing

    elseif ismember(app.plates(plate_num).metadata.ImageFileFormat, {'XYZCT-Bio-Format-SingleFile'})
      %first labal 248
      %first edit box 247
      %secon edit box 218 (29 diff)
      Plate_Map_Table_visibility = 'off';
      Filter_Data_visibility = 'on';
      Filter_Row_visibility = 'off';
      Filter_Columns_visibility = 'off';
      Filter_Fields_visibility = 'off';
      Filter_Timepoints_visibility = 'on';
      Filter_zslices_visibility = 'on';
      % Move up because some fields will be missing for Bio-formats
      Filter_Timepoints_label_position = [15,248,67,20];
      Filter_Timepoints_position = Filter_Row_position;
      Filter_zslices_label_position = [35,219,47,22];
      Filter_zslices_position = Filter_Columns_position;
      pos = numimages_label.Position;
      numimages_label.Position = [pos(1) 190 pos(3) pos(4)]; % Move up because some fields will be missing for Bio-formats
      pos = app.plates(plate_num).NumberOfImagesField.Position;
      app.plates(plate_num).NumberOfImagesField.Position = [pos(1) 163 pos(3) pos(4)]; % Move up because some fields will be missing for Zeiss
    end

    % Plate Map Table
    well_label = uilabel(tab, 'Text', 'Plate Map:', 'Visible', Plate_Map_Table_visibility, 'Position', Plate_Map_Table_label_position, 'FontSize', 14, 'FontName', 'Yu Gothic UI');
    well_table = uitable(tab,'Data',plate.wells,'Visible', Plate_Map_Table_visibility, 'Position', Plate_Map_Table_position, ...
      'ColumnEditable',true, 'RowName',letters);

    % Filter Data Title
    filter_label = uilabel(tab, 'Text', 'Filter Input:', 'Visible', Filter_Data_visibility, 'Position', Filter_Data_label_position, 'FontSize', 14, 'FontName', 'Yu Gothic UI');

    % Filter Columns
    rows_label = uilabel(tab, 'Text', 'Rows:', 'Visible', Filter_Row_visibility, 'Position', Filter_Row_label_position, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_rows = uieditfield(tab, 'Visible', Filter_Row_visibility, 'Position', Filter_Row_position, ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    % Filter Columns
    columns_label = uilabel(tab, 'Text', 'Columns:', 'Visible', Filter_Columns_visibility, 'Position', Filter_Columns_label_position, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_columns = uieditfield(tab, 'Visible', Filter_Columns_visibility, 'Position', Filter_Columns_position, ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    % Filter Fields
    fields_label = uilabel(tab, 'Text', 'Fields:', 'Visible', Filter_Fields_visibility, 'Position', Filter_Fields_label_position, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_fields = uieditfield(tab, 'Visible', Filter_Fields_visibility, 'Position', Filter_Fields_position, ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    % Filter Timepoints
    timepoints_label = uilabel(tab, 'Text', 'Timepoints:', 'Visible', Filter_Timepoints_visibility, 'Position', Filter_Timepoints_label_position, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_timepoints = uieditfield(tab, 'Visible', Filter_Timepoints_visibility, 'Position', Filter_Timepoints_position, ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

    % Filter Z Slices
    zslices_label = uilabel(tab, 'Text', 'Z Slices:', 'Visible', Filter_zslices_visibility, 'Position', Filter_zslices_label_position, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    app.plates(plate_num).filter_zslices = uieditfield(tab, 'Visible', Filter_zslices_visibility, 'Position', Filter_zslices_position, ...
      'UserData', plate_num, ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_FilterInput_, true) ...
    );

  end

end
