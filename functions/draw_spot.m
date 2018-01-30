function fun(algo_name, params, app, createCallbackFcn)
% function fun(algo_name, params, app, createCallbackFcn)
  % Setup a string list of dynamic arguments to be passed to the plugin.
  % for example:
  %    'app.spotting.fields{1}.Value, app.spotting.fields{2}.Value'

  app_params = {};
  for idx=1:length(params)
    app_params(idx) = {sprintf('app.spotting.fields{%s}.Value', num2str(idx))};
  end
  app_params = strjoin(app_params,', ');
  v_offset = 100;
  for idx=1:length(params)
    v_offset = v_offset + 50;
    field_pos = [165 v_offset 50 22];
    label_pos = [5 v_offset-5 145 22];

    app.spotting.Callback = @(app, event) eval([algo_name '(app.img, ' app_params ');']);

    app.spotting.fields{idx} = uispinner(app.Tab_Spot);
    app.spotting.fields{idx}.ValueChangedFcn = createCallbackFcn(app, app.spotting.Callback, true);
    app.spotting.fields{idx}.Position = field_pos;
    app.spotting.fields{idx}.Value = params(idx).default;
    
    app.spotting.labels{idx} = uilabel(app.Tab_Spot);
    app.spotting.labels{idx}.HorizontalAlignment = 'right';
    app.spotting.labels{idx}.Position = label_pos;
    app.spotting.labels{idx}.Text = params(idx).name;
  end
end
