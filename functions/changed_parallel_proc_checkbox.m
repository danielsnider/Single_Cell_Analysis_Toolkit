function fun(app)
  checked = app.CheckBox_Parallel.Value;

  if checked
    check_plugins_for_parallel_proc_support(app);
  end
end