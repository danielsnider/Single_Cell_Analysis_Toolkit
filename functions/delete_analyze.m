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
    % Delete Image
    if isfield(app.analyze{an_num},'ExampleImage')
      delete(app.analyze{an_num}.ExampleImage);
      app.analyze{an_num}.ExampleImage = [];
    end
    % Delete Documentation
    if isfield(app.analyze{an_num},'ExampleImage')
      delete(app.analyze{an_num}.DocumentationBox);
      app.analyze{an_num}.DocumentationBox = [];
    end
    % Delete Parameters
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.analyze{an_num},comp_name)
        for idx=1:length(app.analyze{an_num}.(comp_name))
          if isfield(app.analyze{an_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            delete(app.analyze{an_num}.(comp_name){idx}.UserData.ParamOptionalCheck);
          end
          delete(app.analyze{an_num}.(comp_name){idx});
        end
        app.analyze{an_num}.(comp_name) = {};
      end
    end
  end
end