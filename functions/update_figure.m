function fun(app)
  try
    if no_images_loaded(app)
        return
    end

    % Currently selected plate number
    plate_num = app.PlateDropDown.Value;

    if isstruct(app.StartupLogTextArea)
      msg = sprintf('Displaying image.');
      app.log_processing_message(app, msg);
    end

    %% Display Images
    % Initialize image of a composite of one or more channels
    first_chan_num = app.plates(plate_num).channels(1); % may not always be 1 in position 1, it's a crazy world out there
    first_chan_2D_data = app.image(first_chan_num).data(:,:,1); % force 2D because update_figure only supports 2D slices
    composite_img = uint16(zeros([size(first_chan_2D_data),3])); % 2D RGB image

    % Build composite image from enabled channels
    channel_nums = app.plates(plate_num).channels;
    enabled_channels = app.plates(plate_num).enabled_channels;
    enabled_channel_nums = channel_nums(enabled_channels);
    for chan_num=[enabled_channel_nums]
      img = app.image(chan_num).data;

      % Handle 3D by choosing one 2D slice
      if size(img,3) > 1
        z_slice = app.ZSliceDropDown.Value;
        img = img(:,:,z_slice);
      end

      % Scale image values according to the min max display sliders
      min_dyn_range_percent = app.plates(plate_num).channel_min(chan_num)/100;
      max_dyn_range_percent = app.plates(plate_num).channel_max(chan_num)/100;
      im_norm = normalize0to1(double(img));
      im_adj = imadjust(im_norm(:),[min_dyn_range_percent max_dyn_range_percent], [0 1]);
      im_adj = reshape(im_adj,size(im_norm)); % imadjust doesn't support more than 2D so we are reshaping now back to 2D or 3D
      scaled_img = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
      scaled_img = scaled_img./length(enabled_channels); % reduce intensity so not to go overbounds of uint16

      % Set color
      colour = app.plates(plate_num).channel_colors(chan_num,:);
      colour_img = uint16(zeros(size(composite_img)));
      otherdims=repmat({':'},1,ndims(composite_img)-1);
      colour_img(otherdims{:},1) = scaled_img .* colour(1);
      colour_img(otherdims{:},2) = scaled_img .* colour(2);
      colour_img(otherdims{:},3) = scaled_img .* colour(3);

      % Composite
      composite_img = composite_img + colour_img;
    end
    % Increase image brightness to use full range of unit16 values
    scale_factor = 2^16/max(composite_img(:));
    composite_img = composite_img .* scale_factor;

    if app.display.channel_override
      chan_num = app.display.channel_override;
      img = app.image(chan_num).data;

      % Handle 3D by choosing one 2D slice
      if size(img,3) > 1
        z_slice = app.ZSliceDropDown.Value;
        img = img(:,:,z_slice);
      end

      % Scale image values according to the min max display sliders
      min_dyn_range_percent = app.plates(plate_num).channel_min(chan_num);
      max_dyn_range_percent = app.plates(plate_num).channel_max(chan_num);
      min_dyn_range_value = prctile(img(:), min_dyn_range_percent);
      max_dyn_range_value = prctile(img(:), max_dyn_range_percent);
      im_norm = normalize0to1(double(img));
      im_adj = imadjust(im_norm(:),[min_dyn_range_percent/100 max_dyn_range_percent/100], [0 1]);
      im_adj = reshape(im_adj,size(im_norm)); % imadjust doesn't support more than 2D so we are reshaping now back to 2D or 3D
      denormalized_im_adj = im_adj.*double(max_dyn_range_value-min_dyn_range_value);
      denormalized_im_adj = denormalized_im_adj + double(min_dyn_range_value);

      % Override composite image
      composite_img = uint16(denormalized_im_adj);
    end

    % Need to add something here for parallel, change figure number to random available number and then delete
    
    % Display
    f = figure(111); clf; set(f, 'name','Display','NumberTitle', 'off');
    if ndims(composite_img) <= 3
      imshow(composite_img,[]);
    elseif ndims(composite_img) == 4
      imshow3D(composite_img,[]);
    end
    hold on

    % Display segments as colorized layers
    for seg_num=1:length(app.segment)
      if ~app.display.segment{seg_num}.checkbox.Value
        continue
      end
      if ~isfield(app.segment{seg_num},'result') || isempty(app.segment{seg_num}.result)
        continue
      end
      seg = app.segment{seg_num}.result.matrix;
      % Handle 3D by choosing one 2D slice
      if size(seg,3) > 1
        z_slice = app.ZSliceDropDown.Value;
        seg = seg(:,:,z_slice);
      end
      gain = app.display.segment{seg_num}.gain_slider.Value/100;
      perimeter = app.display.segment{seg_num}.perimeter_toggle.Value;
      thickness = app.display.segment{seg_num}.perimeter_thickness.Value;
      if perimeter
        seg = bwperim(seg);
        seg = bwlabel(seg);
      end
      seg = imdilate(seg,strel('disk',thickness-1));
      colour = app.segment{seg_num}.display_color;
      if any(colour)
        seg_colors = uint8(zeros(size(composite_img)));
        otherdims=repmat({':'},1,2);
        seg_colors(otherdims{:},1) = logical(seg) .* colour(1) .* 255;
        seg_colors(otherdims{:},2) = logical(seg) .* colour(2) .* 255;
        seg_colors(otherdims{:},3) = logical(seg) .* colour(3) .* 255;
      else
        seg_colors = label2rgb(uint16(seg), 'jet', [0 0 0], 'shuffle'); % outputs uint8
      end
      if min(composite_img(:))==max(composite_img(:)) % imshow doesn't allow this. It must be that the composite_img is totally empty, no channels enabled, black.
          layer = imshow(seg_colors,[]);
      else
          layer = imshow(seg_colors,[min(composite_img(:)) max(composite_img(:))]);
      end
      layer.AlphaData = logical(seg)*gain;
    end

    %% Display measure overlay
    if app.DisplayMeasureCheckBox.Value
      PlateName = app.plates(plate_num).metadata.Name;
      if any(ismember(fields(app),'ResultTable_for_display')) && istable(app.ResultTable_for_display)
        measure_name = app.DisplayMeasureDropDown.Value;
        if ismember('x_coord',app.ResultTable_for_display.Properties.VariableNames)
          if ismember(measure_name,app.ResultTable_for_display.Properties.VariableNames)
            subsetTable = get_current_displayed_resultTable(app);
            data = subsetTable(:,{measure_name,'x_coord','y_coord'});
            fontsize = app.DisplayMeasureFontSize.Value;
            fontcolor = app.measure_overlay_color;
            
            if isnumeric(data.(measure_name))
              text(data.x_coord,data.y_coord,num2cellstr(data.(measure_name),'%g'),'Color',fontcolor,'FontSize',fontsize, 'HorizontalAlignment','center');
            else
              text(data.x_coord,data.y_coord,data.(measure_name),'Color',fontcolor,'FontSize',fontsize, 'HorizontalAlignment','center');
            end
          end
        else
          msg = sprintf('Cannot overlay measurements because a primary segment was not used. Please remeasure with a primary segment');
          uialert(app.UIFigure,msg,'Sorry', 'Icon','warn');
        end
      end
    end

    hold off 

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end
end
