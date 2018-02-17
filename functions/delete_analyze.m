function fun(app, an_nums)
  if ~any(ismember(fields(app),'analyze'))
    return
  end

  component_names = { ...
    'fields', ...
    'labels', ...
    'MeasurementDropDown', ...
    'MeasurementLabel', ...
    'HelpButton', ...
  };
  for an_num=an_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.analyze{an_num},comp_name)
        for idx=1:length(app.analyze{an_num}.(comp_name))
          delete(app.analyze{an_num}.(comp_name){idx});
        end
        app.analyze{an_num}.(comp_name) = {};
      end
    end
  end
end