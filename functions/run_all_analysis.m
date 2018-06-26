function run_all_analysis(app);

  for an_num=1:length(app.analyze)
    do_analyze(app, an_num);
  end

end