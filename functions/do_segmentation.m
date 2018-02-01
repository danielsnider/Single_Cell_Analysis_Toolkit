function do_segmentation(seg_num, app, algo_name)
  % seeds = app.spotting{???}.Callback(app, 'Update'); % operate on the last loaded image in app.img
  

  % Create list of algorithm parameter values to be passed to the plugin
  algo_params = {};
  for idx=1:length(app.segment{seg_num}.fields)
    algo_params(length(algo_params)+1) = {app.segment{seg_num}.fields{idx}.Value};
  end

  for idx=1:length(app.segment{seg_num}.SegmentDropDown)
    seg_num = app.segment{seg_num}.SegmentDropDown{idx}.Value; % Input spots as configured by user
    result = app.segment{seg_num}.Callback(app, 'Update'); % operate on the last loaded image in app.img
    algo_params(length(algo_params)+1) = {result};
  end

  % Call algorithm
  result = feval(algo_name, app.img, algo_params{:});
end