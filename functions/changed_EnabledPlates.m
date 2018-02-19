function changed_EnabledPlates(app)
  % Currently selected plate number
  cur_plate_num = app.PlateDropDown.Value;
  new_plate_num = false;

  %% Change plate if the current plate is disabled
  if ~app.plates(cur_plate_num).checkbox.Value % if currenty plate is disabled
    % choose a new plate number by looping to find the first enabled one
    for plate_num=1:length(app.plates) % loop over plates
      if app.plates(plate_num).checkbox.Value % find an enabled plate
        new_plate_num = plate_num;
        cur_plate_num = new_plate_num;
        app.PlateDropDown.Value = new_plate_num; % set new plate number
        changed_PlateDropDown(app); % tigger plate change function
        break
      end
    end
    % If no other plate is enabled keep plate the same
    if ~new_plate_num % if no new plate number was found keep the same plate
      app.plates(cur_plate_num).checkbox.Value = true; % re-check the checkbox
      uialert(app.UIFigure, 'Sorry, this plate cannot be disabled because it is the only plate. You must have one enabled plate.','Cannot Disable Plate', 'Icon','warn');
      return
    end
  end

  % Preprocess Tab Update Lists
  component_names = { ...
    'ChannelDropDown', ...
    'ChannelListbox', ...
  };
  for n=1:length(app.preprocess)
    for comp_name=component_names
      if isfield(app.preprocess{n},comp_name)
        % Set dropdown data
        app.preprocess{n}.(comp_name{:}).Items = get_enabled_channel_names(app);
      end
    end
  end

  % Measure Tab Update Lists
  component_names = { ...
    'ChannelDropDown', ...
    'ChannelListbox', ...
  };
  for n=1:length(app.measure)
    for comp_name=component_names
      if isfield(app.measure{n},comp_name)
        for drop_num=1:length(app.measure{n}.(comp_name{:}))
          % Set dropdown data
          app.measure{n}.(comp_name{:}){drop_num}.Items = get_enabled_channel_names(app);
        end
      end
    end
  end

  % Display Tab Redraw
  draw_display_image_selection(app);

end