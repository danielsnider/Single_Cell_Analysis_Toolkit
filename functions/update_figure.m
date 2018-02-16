function fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Currently selected image
  row = app.RowDropDown.Value;
  column = app.ColumnDropDown.Value;
  field = app.FieldDropDown.Value;
  timepoint = app.TimepointDropDown.Value;

  %% Display Images
  % Initialize image of a composite of one or more channels
  first_chan_num = app.plates(plate_num).channels(1); % may not always be 1 in position 1, it's a crazy world out there
  composite_img = uint16(zeros([size(app.image(first_chan_num).data),3]));

  % Build composite image from enabled channels
  channel_nums = app.plates(plate_num).channels;
  enabled_channels = app.plates(plate_num).enabled_channels;
  enabled_channel_nums = channel_nums(enabled_channels);
  for chan_num=[enabled_channel_nums]
    img = app.image(chan_num).data;

    % Scale image values according to the min max display sliders
    min_dyn_range_percent = app.plates(plate_num).channel_min(chan_num)/100;
    max_dyn_range_percent = app.plates(plate_num).channel_max(chan_num)/100;
    im_norm = normalize0to1(double(img));
    im_adj = imadjust(im_norm,[min_dyn_range_percent max_dyn_range_percent], [0 1]);
    scaled_img = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
    scaled_img = scaled_img./length(enabled_channels); % reduce intensity so not to go overbounds of uint16

    % Set color
    colour = app.plates(plate_num).channel_colors(chan_num,:);
    colour_img = uint16(zeros(size(composite_img)));
    colour_img(:,:,1) = scaled_img .* colour(1);
    colour_img(:,:,2) = scaled_img .* colour(2);
    colour_img(:,:,3) = scaled_img .* colour(3);

    % Composite
    composite_img = composite_img + colour_img;
  end
  % Increase image brightness to use full range of unit16 values
  scale_factor = 2^16/max(composite_img(:));
  composite_img = composite_img .* scale_factor;

  if app.display.channel_override
    chan_num = app.display.channel_override;
    img = app.image(chan_num).data;

    % Scale image values according to the min max display sliders
    min_dyn_range_percent = app.plates(plate_num).channel_min(chan_num);
    max_dyn_range_percent = app.plates(plate_num).channel_max(chan_num);
    min_dyn_range_value = prctile(img(:), min_dyn_range_percent);
    max_dyn_range_value = prctile(img(:), max_dyn_range_percent);
    im_norm = normalize0to1(double(img));
    im_adj = imadjust(im_norm,[min_dyn_range_percent/100 max_dyn_range_percent/100], [0 1]);
    denormalized_im_adj = im_adj.*double(max_dyn_range_value-min_dyn_range_value);
    denormalized_im_adj = denormalized_im_adj + double(min_dyn_range_value);

    % Override composite image
    composite_img = uint16(denormalized_im_adj);
  end

  % Display
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off');
  imshow(composite_img,[]);
  hold on

  % Display segments as colorized layers
  for seg_num=1:length(app.segment)
    if ~app.display.segment{seg_num}.checkbox.Value
      continue
    end
    if ~isfield(app.segment{seg_num},'result') || isempty(app.segment{seg_num}.result)
      % app.segment{seg_num}.result = app.segment{seg_num}.do_segmentation(); % trigger if needed. Note(Dan): I disabled this because it trigger on first loading the GUI and a segment may not be configured correctly which will lead to uialert error on startup which is bad
      continue
    end
    seg = app.segment{seg_num}.result;
    gain = app.display.segment{seg_num}.gain_slider.Value/100;
    perimeter = app.display.segment{seg_num}.perimeter_toggle.Value;
    thickness = app.display.segment{seg_num}.perimeter_thickness.Value;
    if perimeter
      seg = bwperim(seg);
      seg = bwlabel(seg);
    end
    seg = imdilate(seg,strel('disk',thickness));
    colour = app.segment{seg_num}.display_color;
    if any(colour)
      seg_colors = uint8(zeros(size(composite_img)));
      seg_colors(:,:,1) = logical(seg) .* colour(1) .* 255;
      seg_colors(:,:,2) = logical(seg) .* colour(2) .* 255;
      seg_colors(:,:,3) = logical(seg) .* colour(3) .* 255;
    else
      seg_colors = label2rgb(uint16(seg), 'jet', [0 0 0], 'shuffle'); % outputs uint8
    end
    % NOPE% Scale colors so they are not 100% brightness but only the maximum value found in the composite image so they don't overpower the composite image
    % im_norm = normalize0to1(double(seg_colors));
    %scaled_seg_colors = im2uint16(im_norm.*double(max(composite_img(:))))/2;
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
    if any(ismember(fields(app),'ResultTable')) && istable(app.ResultTable)
      measure_name = app.DisplayMeasureDropDown.Value;
      if ismember(measure_name,app.ResultTable.Properties.VariableNames)
        selector = ismember(app.ResultTable.row,row) & ismember(app.ResultTable.column,column) & ismember(app.ResultTable.field,field) & ismember(app.ResultTable.timepoint,timepoint) & ismember(app.ResultTable.PlateName,PlateName);
        data = app.ResultTable(selector,{measure_name,'x_coord','y_coord'});
        fontsize = app.DisplayMeasureFontSize.Value;
        fontcolor = app.measure_overlay_color;
        text(data.x_coord,data.y_coord,num2cellstr(data.(measure_name),'%.2f'),'Color',fontcolor,'FontSize',fontsize);
      end
    end
  end

  hold off

end

