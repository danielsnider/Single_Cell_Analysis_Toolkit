function do_segmentation(seg_num, app, algo_name)
  % seeds = app.spotting{???}.Callback(app, 'Update'); % operate on the last loaded image in app.img
  

  % Create list of algorithm parameter values to be passed to the plugin
  algo_params = {};
  for idx=1:length(app.segment{seg_num}.fields)
    algo_params(idx) = {app.segment{seg_num}.fields{idx}.Value};
  end

  spot_num = app.segment{seg_num}.SeedDropDown.Value; % Input spots as configured by user
  seeds = app.spot{spot_num}.Callback(app, 'Update'); % operate on the last loaded image in app.img

  % Call algorithm
  result = feval(algo_name, app.img, seeds, algo_params{:});
end