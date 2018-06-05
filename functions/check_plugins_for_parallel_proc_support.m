function any_offending_plugin = fun(app)
  any_offending_plugin = false;
  
  if ~app.CheckBox_Parallel.Value
    return % return if unchecked
  end

  for seg_num=1:length(app.segment)
    algorithm_info = app.segment{seg_num}.algorithm_info;
    if isfield(algorithm_info,'supports_parallel_processing') && ~algorithm_info.supports_parallel_processing
      any_offending_plugin = true;
      offending_plugin_name = app.segment{seg_num}.algorithm_info.name;
    end
  end

  if any_offending_plugin
    app.CheckBox_Parallel.Value = false;
    msg = sprintf('Sorry, the plugin ''%s'' does not support parallel processing.',offending_plugin_name);
    title_ = 'Plugin does not support parallel processing';
    uialert(app.UIFigure,msg,title_, 'Icon','warn');
  end

end