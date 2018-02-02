function result = do_segmentation(app, seg_num, algo_name)
  %°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
  
  try

    % Create list of algorithm parameter values to be passed to the plugin
    algo_params = {};
    for idx=1:length(app.segment{seg_num}.fields)
      algo_params(length(algo_params)+1) = {app.segment{seg_num}.fields{idx}.Value};
    end

    for idx=1:length(app.segment{seg_num}.SegmentDropDown)
      dep_seg_num = app.segment{seg_num}.SegmentDropDown{idx}.Value;
      dep_algo_name = app.segment{dep_seg_num}.AlgorithmDropDown.Value;
      result = do_segmentation(app, dep_seg_num, dep_algo_name); % operate on the last loaded image in app.img
      algo_params(length(algo_params)+1) = {result};
    end

    % Call algorithm
     result = feval(algo_name, app.img, algo_params{:});
     app.segment{seg_num}.data = result;

  catch ME
    if strfind(ME.message,'infinite recursion within the program')
      errordlg('You have configured a circular loop in your segmentation dependencies. For example, A depends on B which depends on A. This causes infinite recursion within the program and matlab has ran out of memory. Please find and remove the dependency loop in your segmentation settings.')
    end
    rethrow(ME)
  end
end