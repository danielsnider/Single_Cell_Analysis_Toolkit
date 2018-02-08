function fun(app, meas_nums)
  if ~any(ismember(fields(app),'measure'))
    return
  end

  component_names = { ...
    'fields', ...
    'labels', ...
    'ChannelDropDown', ...
    'ChannelLabel', ...
    'ChannelListbox', ...
    'ChannelListboxLabel', ...
    'SegmentListbox', ...
    'SegmentListboxLabel', ...
  };
  for meas_num=meas_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.measure{meas_num},comp_name)
        for idx=1:length(app.measure{meas_num}.(comp_name))
          delete(app.measure{meas_num}.(comp_name){idx});
        end
        app.measure{meas_num}.(comp_name) = {};
      end
    end
  end
end