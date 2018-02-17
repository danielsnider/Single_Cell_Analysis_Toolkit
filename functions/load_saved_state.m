function fun(app,saved_app,createCallbackFcn)
  % Input Tab
  filter_names = { ...
    'rows', ...
    'columns', ...
    'fields', ...
    'timepoints' ...
  };
  for plate_num = 1:length(app.plates)
    for filt_num = 1:length(filter_names)
      filter_name = filter_names{filt_num};
      app.plates(plate_num).(['filter_' filter_name]).Value = saved_app.plates(plate_num).(['filter_' filter_name]).Value;
    end
    changed_FilterInput(app,plate_num);
  end

  % Preprocess Tab
  component_names = { ...
    'fields', ...
    'labels', ...
    'ParamOptionalCheck', ...
  };
  for proc_num=1:length(saved_app.preprocess)
    add_preprocess(app,createCallbackFcn);

    app.preprocess{proc_num}.AlgorithmDropDown.Value = saved_app.preprocess{proc_num}.AlgorithmDropDown.Value;
    app.preprocess{proc_num}.ChannelDropDown.Value = saved_app.preprocess{proc_num}.ChannelDropDown.Value;
    app.preprocess{proc_num}.Name.Value = saved_app.preprocess{proc_num}.Name.Value;
    app.preprocess{proc_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.preprocess{proc_num},comp_name) % only if it exists
        for idx=1:length(app.preprocess{proc_num}.(comp_name)) % loop over each item of this type
          field_names = fieldnames(app.preprocess{proc_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            try
              % Place the saved value into the app
              app.preprocess{proc_num}.(comp_name){idx}.(string(field_name)) = saved_app.preprocess{proc_num}.(comp_name){idx}.(string(field_name));
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  % Segment Tab
  component_names = { ...
    'fields', ...
    'labels', ...
    'SegmentDropDown', ...
    'SegmentLabel', ...
    'ChannelDropDown', ...
    'ChannelLabel', ...
    'ParamOptionalCheck', ...
  };
  for seg_num=1:length(saved_app.segment)
    add_segment(app,createCallbackFcn);

    app.segment{seg_num}.AlgorithmDropDown.Value = saved_app.segment{seg_num}.AlgorithmDropDown.Value;
    app.segment{seg_num}.Name.Value = saved_app.segment{seg_num}.Name.Value;
    app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.segment{seg_num},comp_name) % only if it exists
        for idx=1:length(app.segment{seg_num}.(comp_name)) % loop over each item of this type
          field_names = fieldnames(app.segment{seg_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
              try
                % Place the saved value into the app
                app.segment{seg_num}.(comp_name){idx}.(string(field_name)) = saved_app.segment{seg_num}.(comp_name){idx}.(string(field_name));
              catch ME
                if strfind(ME.message,'You cannot set the read-only property')
                  warning(ME.message); % only warn if a read-only error ocures
                  continue
                end
              end
            % end
          end
        end
      end
    end
  end

  % Measure Tab
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
  for meas_num=1:length(saved_app.measure)
    add_measure(app,createCallbackFcn);

    app.measure{meas_num}.AlgorithmDropDown.Value = saved_app.measure{meas_num}.AlgorithmDropDown.Value;
    app.measure{meas_num}.Name.Value = saved_app.measure{meas_num}.Name.Value;
    app.measure{meas_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.measure{meas_num},comp_name) % only if it exists
        for idx=1:length(app.measure{meas_num}.(comp_name)) % loop over each item of this type
          field_names = fieldnames(app.measure{meas_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            try
              % Place the saved value into the app
              app.measure{meas_num}.(comp_name){idx}.(string(field_name)) = saved_app.measure{meas_num}.(comp_name){idx}.(string(field_name));
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  %% Result Table
  if any(ismember(fields(saved_app),'ResultTable')) && istable(saved_app.ResultTable)
    app.ResultTable = saved_app.ResultTable
    app.Button_ViewMeasurements.Visible = 'on';
    app.Button_ExportMeasurements.Visible = 'on';
  end

end