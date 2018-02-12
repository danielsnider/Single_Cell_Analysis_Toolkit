function NameCallback(app, proc_num)
  %% Save list of preprocess names in app.preprocess_names
  preprocess_names = {};
  for n=1:length(app.preprocess)
    preprocess_names{n} = app.preprocess{n}.Name.Value;
    if strcmp(preprocess_names{n},'')
      preprocess_names{n} = sprintf('Preprocess %i', n);
    end
  end
  % Fix matlab one element things differently
  if length(preprocess_names) == 1 
      preprocess_names = {preprocess_names{1}};
  end

  %% Update tab title
  if strcmp(app.preprocess{proc_num}.Name.Value,'')
    app.preprocess{proc_num}.tab.Title = sprintf('Preprocess %i', proc_num);
  else
    app.preprocess{proc_num}.tab.Title = sprintf('Preprocess %i: %s', proc_num, app.preprocess{proc_num}.Name.Value);
  end

end