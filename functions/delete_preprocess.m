function fun(app, proc_nums)
  if ~any(ismember(fields(app),'proprocess'))
    return
  end

  component_names = { ...
    'fields', ...
    'labels', ...
    'ChannelDropDown', ...
    'ChannelLabel', ...
    'ParamOptionalCheck', ...
    'HelpButton', ...
  };
  for proc_num=proc_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.proprocess{proc_num},comp_name)
        for idx=1:length(app.proprocess{proc_num}.(comp_name))
          delete(app.proprocess{proc_num}.(comp_name){idx});
          app.proprocess{proc_num}.(comp_name){idx} = [];
        end
        app.proprocess{proc_num}.(comp_name) = {};
      end
    end
  end
end