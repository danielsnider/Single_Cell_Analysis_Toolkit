function fun(app, seg_nums, how_much_to_detele)
  if ~any(ismember(fields(app),'segment'))
    return
  end

  % if any(ismember(fields(app),'segment_tabgp'))
  %   delete(app.segment_tabgp)
  %   app.segment_tabgp = [];
  % end

  component_names = { ...
    'fields', ...
    'labels', ...
    'SegmentDropDown', ...
    'SegmentDropDownLabel', ...
    'ChannelDropDown', ...
    'ChannelDropDownLabel', ...
    'run_button', ...
    'HelpButton', ...
  };
  for seg_num=seg_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.segment{seg_num},comp_name)
        for idx=1:length(app.segment{seg_num}.(comp_name))
          if isfield(app.segment{seg_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            delete(app.segment{seg_num}.(comp_name){idx}.UserData.ParamOptionalCheck);
          end
          delete(app.segment{seg_num}.(comp_name){idx});
          app.segment{seg_num}.(comp_name){idx} = [];
          
        end
        app.segment{seg_num}.(comp_name) = {};
      end
    end
    % if isfield(app.segment{seg_num},'tab')
    %   delete(app.segment{seg_num}.tab);
    %   app.segment{seg_num}.tab = [];
    % end
    % app.segment{seg_num} = {};
  end
  % app.segment = {};
end