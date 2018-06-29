function func(app, app_parameters, createCallbackFcn)
  plugins = app_parameters.plugins;
  settings = app_parameters.settings;

  % Loop over plugins, creating the plugin tab and setting the parameters
  for plugin=plugins'

     % Load Preprocessing plugins and parameters
    if strcmpi(plugin.type,'Preprocess') % strcmpi in-case sensitive

      % Create new preprocess Tab and select the correct plugin by it's indentifier
      add_preprocess(app, createCallbackFcn,plugin.identifier);
      proc_num = length(app.preprocess);
      tab_name = app.preprocess{proc_num}.tab.Title;
      plugin_pretty_name = app.preprocess{proc_num}.AlgorithmDropDown.Items{find(strcmp(app.preprocess{proc_num}.AlgorithmDropDown.ItemsData,app.preprocess{proc_num}.AlgorithmDropDown.Value))};

      if isnan(plugin.name)
        plugin.name = '';
      end
      app.preprocess{proc_num}.Name.Value = plugin.name; % Name this plugin according to user input

      % Load Preprocess Parameters
      for key=plugin.parameters.keys
          
        finishNow = false;
        value_set = false;
        key=key{:};
        value = plugin.parameters(key);
        ui_labels = { ... % order matters, must corrospond with ui_values
          'ChannelLabel', ...
          'labels', ...
        };
        ui_values = { ... % order matters, must corrospond with ui_labels
          'ChannelDropDown', ...
          'fields', ...
        };
        if isstr(value) && strcmp(value,'Inf')
          value = Inf;
        end
        if isstr(value)
          value=strtrim(strsplit(value,',')); % convert 'Nuc, Cell, Pero' to {'Nuc'},{'Cell'},{'Pero'}
        end
        if iscell(value) && length(value) == 1 %% WHY??????????? Undoing ^
          value=value{:};
        end
        
        for uid=1:length(ui_labels)
          ui_label = ui_labels{uid};
          if isfield(app.preprocess{proc_num}, ui_label)
            for idx=1:length(app.preprocess{proc_num}.(ui_label))
              try
                  uid_eval = strcmp(app.preprocess{proc_num}.(ui_label).Text, key); % Needed for ChannelLabel
              catch
                  uid_eval = strcmp(app.preprocess{proc_num}.(ui_label){idx}.Text, key); % Needed for labels
              end
              if uid_eval==true
                if iscell(app.preprocess{proc_num}.(ui_label))
                    this_ui_component = app.preprocess{proc_num}.(ui_values{uid}){idx};
                else
                    this_ui_component = app.preprocess{proc_num}.(ui_values{uid});
                end
                
                this_ui_component.Enable = true;
                if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                  this_ui_component.UserData.ParamOptionalCheck.Value = true;
                  if isequal(value, false) || isstr(value) && strcmpi(value,'FALSE')
                    this_ui_component.Enable = false;
                    this_ui_component.UserData.ParamOptionalCheck.Value = false;
                    finishNow = true;
                    value_set = true;
                    break
                  elseif isequal(value, true) || isstr(value) && strcmpi(value,'TRUE')
                      finishNow = true;
                      value_set = true;
                      break
                  end
                end
                if isprop(this_ui_component,'ItemsData') && ~isempty(this_ui_component.ItemsData) % special case when ItemsData exist-
                  value_data = this_ui_component.ItemsData(find(ismember(this_ui_component.Items,value)));
                  if ~isempty(value_data)
                    value = value_data;
                  end
                  if iscell(value) % special case when ItemsData is a cell rather than numeric
                    value = value{:};
                  end
                end
                
                try
                    try
                        this_ui_component.Value = value;
                    catch
                        this_ui_component.Value = str2double(value);
                    end
                catch ME
                  if ~iscell(value)  
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',value, key, plugin_pretty_name, tab_name);
                  elseif iscell(value)
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',strjoin(value,','), key, plugin_pretty_name, tab_name);  
                  end
                  title_ = 'User Error - Bad Parameter Value';
                  throw_application_error(app,msg,title_)
                end
                value_set = true;
                finishNow = true;
                if iscell(app.preprocess{proc_num}.(ui_values{uid}))
                    app.preprocess{proc_num}.(ui_values{uid}){idx} = this_ui_component;
                else
                    app.preprocess{proc_num}.(ui_values{uid}) = this_ui_component;
                end
                break % continue to next parameter key/value pair
              end
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters

        if ~value_set
          msg = sprintf('Could not set the parameter with name "%s" because it doesn''t exist as an option in the available parameter names for the "%s" preprocess plugin. Please correct the name "%s" in the "%s" section of your plate map spreadsheet. You can check the available paramater names by clicking ''Add Segment'' and choosing the "%s" segmentation plugin.', key, plugin_pretty_name, key, plugin.name, plugin_pretty_name);
          title_ = 'User Error - Bad Parameter Name';
          throw_application_error(app,msg,title_)
        end

      end % end looping over keys
      changed_PreprocessName(app,proc_num);
    end % end if this plugin type=='Preprocessing'

    % Load segmentation plugins and parameters
    if strcmp(plugin.type,'segmentation')

      % Create new segment Tab and select the correct plugin by it's indentifier
      add_segment(app, createCallbackFcn, plugin.identifier);
      seg_num = length(app.segment);
      tab_name = app.segment{seg_num}.tab.Title;
      plugin_pretty_name = app.segment{seg_num}.AlgorithmDropDown.Items{find(strcmp(app.segment{seg_num}.AlgorithmDropDown.ItemsData,app.segment{seg_num}.AlgorithmDropDown.Value))};

      if isnan(plugin.name)
        plugin.name = '';
      end
      app.segment{seg_num}.Name.Value = plugin.name; % Name this plugin according to user input

      % Load Segmentation Parameters
      for key=plugin.parameters.keys
        finishNow = false;
        value_set = false;
        key=key{:};
        value = plugin.parameters(key);
        ui_labels = { ... % order matters, must corrospond with ui_values
          'ChannelDropDownLabel', ...
          'SegmentDropDownLabel', ...
          'labels', ...
        };
        ui_values = { ... % order matters, must corrospond with ui_labels
          'ChannelDropDown', ...
          'SegmentDropDown', ...
          'fields', ...
        };
        if isstr(value) && strcmp(value,'Inf')
          value = Inf;
        end
        if isstr(value)
          value=strtrim(strsplit(value,',')); % convert 'Nuc, Cell, Pero' to {'Nuc'},{'Cell'},{'Pero'}
        end
        if iscell(value) && length(value) == 1
          value=value{:};
        end
        for uid=1:length(ui_labels)
          ui_label = ui_labels{uid};
          if isfield(app.segment{seg_num}, ui_label)
            for idx=1:length(app.segment{seg_num}.(ui_label))
              if strcmp(app.segment{seg_num}.(ui_label){idx}.Text, key)
                this_ui_component = app.segment{seg_num}.(ui_values{uid}){idx};
                this_ui_component.Enable = true;
                if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                  this_ui_component.UserData.ParamOptionalCheck.Value = true;
                  if isequal(value, false) || isstr(value) && strcmpi(value,'FALSE')
                    this_ui_component.Enable = false;
                    this_ui_component.UserData.ParamOptionalCheck.Value = false;
                    finishNow = true;
                    value_set = true;
                    break
                  elseif isequal(value, true) || isstr(value) && strcmpi(value,'TRUE')
                    finishNow = true;
                    value_set = true;
                    break
                  end
                end
                if isprop(this_ui_component,'ItemsData') && ~isempty(this_ui_component.ItemsData) % special case when ItemsData exist-
                  value_data = this_ui_component.ItemsData(find(ismember(this_ui_component.Items,value)));
                  if ~isempty(value_data)
                    value = value_data;
                  end
                  if iscell(value) % special case when ItemsData is a cell rather than numeric
                    value = value{:};
                  end
                end
%                 key
%                 value
                try
                  this_ui_component.Value = value;
                catch ME
                  if ~iscell(value)  
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',value, key, plugin_pretty_name, tab_name);
                  elseif iscell(value)
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',strjoin(value,','), key, plugin_pretty_name, tab_name);  
                  end
                  title_ = 'User Error - Bad Parameter Value';
                  throw_application_error(app,msg,title_)
                end
                value_set = true;
                finishNow = true;
                app.segment{seg_num}.(ui_values{uid}){idx} = this_ui_component;
                break % continue to next parameter key/value pair
              end
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters

        if ~value_set
          msg = sprintf('Could not set the parameter with name "%s" because it doesn''t exist as an option in the available parameter names for the "%s" segmentation plugin. Please correct the name "%s" in the "%s" section of your plate map spreadsheet. You can check the available paramater names by clicking ''Add Segment'' and choosing the "%s" segmentation plugin.', key, plugin_pretty_name, key, plugin.name, plugin_pretty_name);
          title_ = 'User Error - Bad Parameter Name';
          throw_application_error(app,msg,title_)
        end

      end % end looping over keys
      changed_SegmentName(app);
    end % end if this plugin type=='segmentation'

    % Load measurement plugins and parameters
    if strcmp(plugin.type,'measurement')
      % Create new measure Tab and select the correct plugin by it's indentifier
      add_measure(app, createCallbackFcn, plugin.identifier);
      meas_num = length(app.measure);
      tab_name = app.measure{meas_num}.tab.Title;
      plugin_pretty_name = app.measure{meas_num}.AlgorithmDropDown.Items{find(strcmp(app.measure{meas_num}.AlgorithmDropDown.ItemsData,app.measure{meas_num}.AlgorithmDropDown.Value))};

      if isnan(plugin.name)
        plugin.name = '';
      end
      

      % Load measurement Parameters
      for key=plugin.parameters.keys
        finishNow = false;
        value_set = false;
        key=key{:};
        value = plugin.parameters(key);
        ui_labels = { ... % order matters, must corrospond with ui_values
          'labels', ...
          'ChannelDropDownLabel', ...
          'ChannelListboxLabel', ...
          'SegmentListboxLabel', ...
          'SegmentDropDownLabel', ...
        };

        ui_values = { ... % order matters, must corrospond with ui_labels
          'fields', ...
          'ChannelDropDown', ...
          'ChannelListbox', ...
          'SegmentListbox', ...
          'SegmentDropDown', ...
        };
        if isstr(value) && strcmp(value,'Inf')
          value = Inf;
        end
        if isstr(value)
          value=strtrim(strsplit(value,',')); % convert 'Nuc, Cell, Pero' to {'Nuc'},{'Cell'},{'Pero'}.
        end
        if iscell(value) && length(value) == 1
          value=value{:};
        end
 
        for uid=1:length(ui_labels)
          ui_label = ui_labels{uid};
          if isfield(app.measure{meas_num}, ui_label)
            for idx=1:length(app.measure{meas_num}.(ui_label))
              if strcmp(app.measure{meas_num}.(ui_label){idx}.Text, key)
                this_ui_component = app.measure{meas_num}.(ui_values{uid}){idx};
                this_ui_component.Enable = true;
                if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                  this_ui_component.UserData.ParamOptionalCheck.Value = true;
                  if isequal(value, false) || isstr(value) && strcmpi(value,'FALSE')
                    this_ui_component.Enable = false;
                    this_ui_component.UserData.ParamOptionalCheck.Value = false;
                    finishNow = true;
                    value_set = true;
                    break
                  elseif isequal(value, true) || isstr(value) && strcmpi(value,'TRUE')
                    finishNow = true;
                    value_set = true;
                    break
                  end
                end
                if isprop(this_ui_component,'ItemsData') && ~isempty(this_ui_component.ItemsData) % special case when ItemsData exist-
                  value_data = this_ui_component.ItemsData(find(ismember(this_ui_component.Items,value)));
                  if ~isempty(value_data)
                    value = value_data;
                  end
                  if iscell(value) % special case when ItemsData is a cell rather than numeric
                    value = value{:};
                  end
                end
                try
                  this_ui_component.Value = value;
                catch ME   
                  if ~iscell(value)  
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',value, key, plugin_pretty_name, tab_name);
                  elseif iscell(value)
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',strjoin(value,','), key, plugin_pretty_name, tab_name);  
                  end
                  title_ = 'User Error - Bad Parameter Value';
                  throw_application_error(app,msg,title_)
                end
                value_set = true;
                finishNow = true;
                app.measure{meas_num}.(ui_values{uid}){idx} = this_ui_component;
                break % continue to next parameter key/value pair
              end
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters

        if ~value_set
          msg = sprintf('Could not set the parameter with name "%s" because it doesn''t exist as an option in the available parameter names for the "%s" measure plugin. Please correct the name "%s" in the "%s" section of your plate map spreadsheet. You can check the available paramater names by clicking ''Add Measure'' and choosing the "%s" measure plugin.', key, plugin_pretty_name, key, plugin.name, plugin_pretty_name); 
          title_ = 'User Error - Bad Parameter Name';
          throw_application_error(app,msg,title_)
        end

      end % end looping over keys
      changed_MeasurementNames(app);
    end % end if this plugin type=='measurement'
  end % end looping over segment and measure plugins

  % Handle Special App Settings
  for key = settings.keys
    key = key{:};
    value = settings(key);
    if strcmp(key,'Primary Segment')
      app.PrimarySegmentDropDown.Value = app.PrimarySegmentDropDown.ItemsData(find(strcmp(app.PrimarySegmentDropDown.Items,value)));
    elseif strcmp(key,'Remove primary outside')
      app.RemovePrimarySegmentsOutside.Value = app.RemovePrimarySegmentsOutside.ItemsData(find(strcmp(app.RemovePrimarySegmentsOutside.Items,value)));
      if ~isequal(value,false)
        app.RemovePrimarySegments_CheckBox.Value = true;
      end
    elseif strcmp(key,'Remove segments outside primary')
      app.RemoveSecondarySegments_CheckBox.Value = value;
    elseif strcmp(key,'Only One')
      app.CheckBox_TestRun.Value = value;
    elseif strcmp(key,'Parallelize')
      app.CheckBox_Parallel.Value = false;
      if ~isequal(value,false)
        app.CheckBox_Parallel.Value = true;
        app.ParallelWorkersField.Value = value;
      end
    elseif strcmp(key,'Save Snapshots')
      app.measure_snapshot_selection = value;
    elseif strcmpi(key,'SavetoEditField')
      app.SavetoEditField.Value = value;  
    elseif strcmpi(key,'CheckBox_AnalyzeImmediately')
      app.CheckBox_AnalyzeImmediately.Value = str2bool(value);
    end
  end
  changed_primary_segment(app);
  
  start_processing_of_one_image(app); % without this, the app.ResultTable will not exist or have the measurement names available that analyze plugins need
  update_figure(app);

  for plugin=plugins'
    % Load analyze plugins and parameters
    if strcmp(plugin.type,'analysis')
      % Create new measure Tab and select the correct plugin by it's indentifier
      add_analyze(app, createCallbackFcn, plugin.identifier);
      an_num = length(app.analyze);
      tab_name = app.analyze{an_num}.tab.Title;
      plugin_pretty_name = app.analyze{an_num}.AlgorithmDropDown.Items{find(strcmp(app.analyze{an_num}.AlgorithmDropDown.ItemsData,app.analyze{an_num}.AlgorithmDropDown.Value))};

      if isnan(plugin.name)
        plugin.name = '';
      end
      app.analyze{an_num}.Name.Value = plugin.name;

      % Load Segmentation Parameters
      for key=plugin.parameters.keys
        finishNow = false;
        value_set = false;
        key=key{:};
        value = plugin.parameters(key);
        ui_labels = { ... % order matters, must corrospond with ui_values
          'labels', ...
          'MeasurementLabel', ...
          'ResultTableLabel'...
          'ResultTableDispLabel'...
          'MeasurementListLabel'...
          'SegmentDropDownLabel', ...
          'ChannelDropDownLabel', ...
          'WellConditionListBoxLabel',...
          'InputUITableLabel',...
        };

        ui_values = { ... % order matters, must corrospond with ui_labels
          'fields', ...
          'MeasurementDropDown', ...
          'ResultTableBox'...
          'ResultTableDisp'...
          'MeasurementListBox'...
          'SegmentDropDown', ...
          'ChannelDropDown', ...
          'WellConditionListBox',...
          'InputUITable',...
        };
        if isstr(value) && strcmp(value,'Inf')
          value = Inf;
        end
        if isstr(value)
          value=strtrim(strsplit(value,',')); % convert 'Nuc, Cell, Pero' to {'Nuc'},{'Cell'},{'Pero'}.
        end
        if iscell(value) && length(value) == 1
          value=value{:};
        end
        for uid=1:length(ui_labels)
          ui_label = ui_labels{uid};
          if isfield(app.analyze{an_num}, ui_label)
            for idx=1:length(app.analyze{an_num}.(ui_label))
              if strcmp(app.analyze{an_num}.(ui_label){idx}.Text, key)
                this_ui_component = app.analyze{an_num}.(ui_values{uid}){idx};
                this_ui_component.Enable = true;
                if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                  this_ui_component.UserData.ParamOptionalCheck.Value = true;
                  if isequal(value, false) || isstr(value) && strcmpi(value,'FALSE')
                    this_ui_component.Enable = false;
                    this_ui_component.UserData.ParamOptionalCheck.Value = false;
                    finishNow = true;
                    value_set = true;
                    break
                  elseif isequal(value, true) || isstr(value) && strcmpi(value,'TRUE')
                    finishNow = true;
                    value_set = true;
                    break
                  end
                end
                if isprop(this_ui_component,'ItemsData') && ~isempty(this_ui_component.ItemsData) % special case when ItemsData exist-
                  value_data = this_ui_component.ItemsData(find(ismember(this_ui_component.Items,value)));
                  if ~isempty(value_data)
                    value = value_data;
                  end
                  if iscell(value) % special case when ItemsData is a cell rather than numeric
                    value = value{:};
                  end
                end
                try
                  this_ui_component.Value = value;
                catch ME
                  if ~iscell(value)  
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',value, key, plugin_pretty_name, tab_name);
                  elseif iscell(value)
                    msg = sprintf('It is not allowed to specify the value "%s" to the parameter "%s" for the "%s" algorithm named "%s". Change this value in your plate map spreadsheet to an allowed value. Find what is allowed by clicking ''Add Measure'' and testing what can be entered.',strjoin(value,','), key, plugin_pretty_name, tab_name);  
                  endtitle_ = 'User Error - Bad Parameter Value';
                  throw_application_error(app,msg,title_)
                end
                value_set = true;
                finishNow = true;
                app.analyze{an_num}.(ui_values{uid}){idx} = this_ui_component;
                break % continue to next parameter key/value pair
              end
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters

        if ~value_set
          msg = sprintf('Could not set the parameter with name "%s" because it doesn''t exist as an option in the available parameter names for the "%s" analyze plugin. Please correct the name "%s" in the "%s" section of your plate map spreadsheet. You can check the available paramater names by clicking ''Add Analysis'' and choosing the "%s" analyze plugin.', key, plugin_pretty_name, key, plugin.name, plugin_pretty_name);
          title_ = 'User Error - Bad Parameter Name';
          throw_application_error(app,msg,title_)
        end
      end % end looping over keys
    end % end if this plugin type=='analyze'

  end % end looping over analyze plugins


end

