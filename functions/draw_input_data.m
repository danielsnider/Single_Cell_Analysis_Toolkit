function fun(plates, app)
% function fun(algo_name, params, app, createCallbackFcn)
  % Setup a string list of dynamic arguments to be passed to the plugin.
  % for example:
  %    'app.spotting.fields{1}.Value, app.spotting.fields{2}.Value'

  
  tabgp = uitabgroup(app.Tab_Input,'Position',[15,24,803,331]);
  app.input_data.tabgp = tabgp;


  for idx=1:length(plates)
    plate = plates(idx);
    tab = uitab(tabgp,'Title',sprintf('Plate %s', num2str(idx)));
    label = uilabel(tab, 'Text', plate.Name, 'Position', [12,264,516,33], 'FontSize', 24, 'FontName', 'Yu Gothic UI Light');
    dirfield = uieditfield(tab, 'Value', plate.ImageDir, 'Position', [637,266,153,22], 'FontSize', 12, 'FontName', 'Helvetica', 'Editable','off')
    dirlabel = uilabel(tab, 'Text', 'Path to Images:', 'Position', [547,267,91,21], 'FontSize', 12, 'FontName', 'Yu Gothic UI');

    channel_strings = {};
    if isfield(plate, 'Ch1')
        channel_strings{1} = sprintf('Ch1: %s', plate.Ch1)
    end
    if isfield(plate, 'Ch2')
        channel_strings{2} = sprintf('Ch2: %s', plate.Ch2)
    end
    if isfield(plate, 'Ch3')
        channel_strings{3} = sprintf('Ch3: %s', plate.Ch3)
    end
    if isfield(plate, 'Ch4')
        channel_strings{4} = sprintf('Ch4: %s', plate.Ch4)
    end
    channel_box = uilistbox(tab, 'Position', [12,178,173,76], 'FontSize', 12, ...
        'FontName', 'Helvetica', 'Items', channel_strings)


    %% Format plate data from struct to two cell arrays for the metadata uitable
    fields = fieldnames(plate);
    count = 1;
    keys = {};
    values = {};
    for idx=1:length(fields)
      field = fields{idx};
      if ~ischar(plate.(field)) & ~isnumeric(plate.(field))
          continue
      end
      val = plate.(field);
      keys{count} = field;
      values{count} = val;
      count = count + 1;
    end
    metadata_table = uitable(tab,'Data',values,'ColumnName', keys, 'RowName',{'MetaData'}, 'Position',[196,178,594,76]);

    well_table = uitable(tab,'Data',plate.wells,'Position',[12,13,779,153],'ColumnEditable',false);
  end
  

  % % Delete existing UI components before creating new ones on top
  % if isfield(app.spotting,'fields')
  %   for idx=1:length(app.spotting.fields)
  %     delete(app.spotting.fields{idx})
  %     delete(app.spotting.labels{idx})
  %   end
  % end

  % app_params = {};
  % for idx=1:length(params)
  %   app_params(idx) = {sprintf('app.spotting.fields{%s}.Value', num2str(idx))};
  % end
  % app_params = strjoin(app_params,', ');
  % v_offset = 100;
  % for idx=1:length(params)
  %   v_offset = v_offset + 50;
  %   field_pos = [165 v_offset 50 22];
  %   label_pos = [5 v_offset-5 145 22];

    % fieldCallback = @(app, event) eval([algo_name '(app.img, ' app_params ');']);

    % app.spotting.fields{idx} = uispinner(app.Tab_Spot);
    % app.spotting.fields{idx}.ValueChangedFcn = createCallbackFcn(app, fieldCallback, true);
    % app.spotting.fields{idx}.Position = field_pos;
    % app.spotting.fields{idx}.Value = params(idx).default;
    
    % app.spotting.labels{idx} = uilabel(app.Tab_Spot);
    % app.spotting.labels{idx}.HorizontalAlignment = 'right';
    % app.spotting.labels{idx}.Position = label_pos;
    % app.spotting.labels{idx}.Text = params(idx).name;
  % end
end
