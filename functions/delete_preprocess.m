function fun(app, proc_nums)
  if ~any(ismember(fields(app),'preprocess'))
    return
  end

  component_names = { ...
    'fields', ...
    'labels', ...
    'ParamOptionalCheck', ...
    'HelpButton', ...
  };
  for proc_num=proc_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.preprocess{proc_num},comp_name)
        for idx=1:length(app.preprocess{proc_num}.(comp_name))
          delete(app.preprocess{proc_num}.(comp_name){idx});
          app.preprocess{proc_num}.(comp_name){idx} = [];
        end
        app.preprocess{proc_num}.(comp_name) = {};
      end
    end
    % if isfield(app.preprocess{proc_num},'tab')
    %   delete(app.preprocess{proc_num}.tab);
    %   app.preprocess{proc_num}.tab = [];
    % end
    % app.preprocess{proc_num} = {};
  end
end