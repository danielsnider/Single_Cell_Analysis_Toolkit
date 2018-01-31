function result = fun(spot_num, app, algo_name)
  % Create list of algorithm parameter values to be passed to the plugin
  algo_params = {};
  for idx=1:length(app.spot{spot_num}.fields)
    algo_params(idx) = {app.spot{spot_num}.fields{idx}.Value};
  end

  % Call algorithm
  result = feval(algo_name, app.img, algo_params{:});
end