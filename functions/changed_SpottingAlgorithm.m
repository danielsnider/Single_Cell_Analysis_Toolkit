function result = fun(app, spot_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.spot{spot_num}.AlgorithmDropDown.Value

  % Delete existing UI components before creating new ones on top
  if isfield(app.spot{spot_num},'fields')
    for idx=1:length(app.spot{spot_num}.fields)
      delete(app.spot{spot_num}.fields{idx})
      delete(app.spot{spot_num}.labels{idx})
    end
  end

  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 100;
  for idx=1:length(params)
    % Location of GUI component
    v_offset = v_offset + 50;
    field_pos = [165 v_offset 50 22];
    label_pos = [5 v_offset-5 145 22];

    % Callback for when parameter value is changed by the user
    app.spot{spot_num}.Callback = @(app, event) do_spotting(spot_num, app, algo_name);

    % Parameter Input Box
    app.spot{spot_num}.fields{idx} = uispinner(app.spot{spot_num}.tab);
    app.spot{spot_num}.fields{idx}.ValueChangedFcn = createCallbackFcn(app, app.spot{spot_num}.Callback, true);
    app.spot{spot_num}.fields{idx}.Position = field_pos;
    app.spot{spot_num}.fields{idx}.Value = params(idx).default;
    
    % Parameter Text Label
    app.spot{spot_num}.labels{idx} = uilabel(app.spot{spot_num}.tab);
    app.spot{spot_num}.labels{idx}.HorizontalAlignment = 'right';
    app.spot{spot_num}.labels{idx}.Position = label_pos;
    app.spot{spot_num}.labels{idx}.Text = params(idx).name;
  end

  app.spot{spot_num}.Callback(app, 'Update') % trigger once
end
