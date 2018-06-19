function func(app, app_parameters, createCallbackFcn)
  plugins = app_parameters.plugins;

  % Loop over plugins, creating the plugin tab and setting the parameters
  for plugin=plugins'

    % Load segmentation plugins and parameters
    if strcmp(plugin.type,'segmentation')

      % Create new segment Tab and select the correct plugin by it's indentifier
      add_segment(app, createCallbackFcn, plugin.identifier);
      seg_num = length(app.segment);
      app.segment{seg_num}.Name.Value = plugin.name;

      % Load Segmentation Parameters
      for key=plugin.parameters.keys
        finishNow = false;
        key = key{:};
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
        for uid=length(ui_labels)
          ui_label = ui_labels{uid};
          for idx=1:length(app.segment{seg_num}.(ui_label))
            if strcmp(app.segment{seg_num}.(ui_label){idx}.Text, key)
              this_ui_component = app.segment{seg_num}.(ui_values{uid}){idx};
              if isstr(value) && strcmp(value,'disabled')
                this_ui_component.Enable = false;
              else
                this_ui_component.Value = value;
              end
              if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                enable_state_bool = strcmp(this_ui_component.Enable, 'on');
                this_ui_component.UserData.ParamOptionalCheck.Value = enable_state_bool;
              end
              app.segment{seg_num}.(ui_values{uid}){idx} = this_ui_component;
              finishNow = true;
              break % continue to next parameter key/value pair
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters
      end % end looping over keys
      changed_SegmentName(app);
    end % end if this plugin type=='segmentation'

    % Load measurement plugins and parameters
    if strcmp(plugin.type,'measurement')

      % Create new measure Tab and select the correct plugin by it's indentifier
      add_measure(app, createCallbackFcn, plugin.identifier);
      seg_num = length(app.measure);
      app.measure{seg_num}.Name.Value = plugin.name;

      % Load Segmentation Parameters
      for key=plugin.parameters.keys
        finishNow = false;
        key = key{:};
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
        for uid=length(ui_labels)
          ui_label = ui_labels{uid};
          for idx=1:length(app.measure{seg_num}.(ui_label))
            if strcmp(app.measure{seg_num}.(ui_label){idx}.Text, key)
              this_ui_component = app.measure{seg_num}.(ui_values{uid}){idx};
              if isstr(value) && strcmp(value,'disabled')
                this_ui_component.Enable = false;
              else
                this_ui_component.Value = value;
              end
              if isfield(this_ui_component.UserData,'ParamOptionalCheck')
                enable_state_bool = strcmp(this_ui_component.Enable, 'on');
                this_ui_component.UserData.ParamOptionalCheck.Value = enable_state_bool;
              end
              app.measure{seg_num}.(ui_values{uid}){idx} = this_ui_component;
              finishNow = true;
              break % continue to next parameter key/value pair
            end
          end
          if finishNow
            break % continue to next parameter key/value pair
          end
        end % end looping over parameters
      end % end looping over keys
      changed_MeasurementNames(app);
    end % end if this plugin type=='measurement'

  end % end looping over plugins

end

