function result = fun(app, seg_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.segment{seg_num}.AlgorithmDropDown.Value

  % Delete existing UI components before creating new ones on top
  if isfield(app.segment{seg_num},'fields')
    for idx=1:length(app.segment{seg_num}.fields)
      delete(app.segment{seg_num}.fields{idx})
      delete(app.segment{seg_num}.labels{idx})
    end
  end

  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Setup a string list of dynamic arguments to be passed to the plugin.
  % for example:
  %    'app.segmentation.fields{1}.Value, app.segmentation.fields{2}.Value'
  % algo_params = {};
  % for idx=1:length(params)
  %   algo_params(idx) = {sprintf('app.segment{%s}.fields{%s}.Value', num2str(seg_num), num2str(idx))};
  % end
  % algo_params = strjoin(algo_params,', ');

  % algo_params = {};
  % for idx=1:length(params)
  %   algo_params(idx) = {app.segment{seg_num}.fields{idx}.Value};
  % end

  % Display GUI component for each parameter to the algorithm
  v_offset = 100;
  for idx=1:length(params)
    % Location of GUI component
    v_offset = v_offset + 50;
    field_pos = [165 v_offset 50 22];
    label_pos = [5 v_offset-5 145 22];

    % Callback for when parameter value is changed by the user
    % app.segment{seg_num}.Callback = @(app, event) eval([algo_name '(app.img, ' algo_params ');']);
    % app.segment{seg_num}.Callback = @(app, event) do_segmentation(app,algo_name,algo_params,params);
    app.segment{seg_num}.Callback = @(app, event) do_segmentation(seg_num, app, algo_name);

    % Parameter Input Box
    app.segment{seg_num}.fields{idx} = uispinner(app.segment{seg_num}.tab);
    app.segment{seg_num}.fields{idx}.ValueChangedFcn = createCallbackFcn(app, app.segment{seg_num}.Callback, true);
    app.segment{seg_num}.fields{idx}.Position = field_pos;
    app.segment{seg_num}.fields{idx}.Value = params(idx).default;
    
    % Parameter Text Label
    app.segment{seg_num}.labels{idx} = uilabel(app.segment{seg_num}.tab);
    app.segment{seg_num}.labels{idx}.HorizontalAlignment = 'right';
    app.segment{seg_num}.labels{idx}.Position = label_pos;
    app.segment{seg_num}.labels{idx}.Text = params(idx).name;
  end
 
end
