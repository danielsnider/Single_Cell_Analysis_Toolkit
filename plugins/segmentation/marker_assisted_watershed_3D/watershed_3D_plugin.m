function result = fun(plugin_name, plugin_num, img, seeds, threshold_smooth_param, thresh_param, watershed_smooth_strength, watershed_smooth_size, min_area, max_area, hmax_height, boarder_clear, debug_level)
  % result = img;
  % return
  
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  user_supplied_seeds = true;
  if isequal(seeds,false)
    user_supplied_seeds = false;
  end

  % Smooth for threshold
  img_smooth = imgaussfilt(img,threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow3D(img_smooth,[]);
  end

  %% Threshold
  % handle percentile threshold
  if contains(thresh_param,'%') 
    percent_location = strfind(thresh_param,'%');
    thresh_param = thresh_param(1:percent_location-1); % remove '%' sign
    thresh_param = str2num(thresh_param); % convert to number
    img_thresh = img_smooth > prctile(img_smooth(:), thresh_param);
  % handle fixed intensity threshold
  else 
    img_thresh = img_smooth > str2num(thresh_param);
  end
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow3D(img_thresh,[]);
  end

  % Smooth for watershed segmentation
  watershed_smooth_strength = str2num(watershed_smooth_strength); % example: convert '2 2 3' to [2 2 3]. Needed because GUI doesn't have a nice way to enter multiple numbers except as a string.
  watershed_smooth_size = str2num(watershed_smooth_size); % example: convert '2 2 3' to [2 2 3]. Needed because GUI doesn't have a nice way to enter multiple numbers except as a string.
  img_smooth = imgaussfilt3(img, watershed_smooth_strength, 'FilterSize', watershed_smooth_size);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow3D(img_smooth,[]);
  end

  %% Supress small maxima
  if ~user_supplied_seeds
    % Auto calculate seeds because user didn't supply any
    if ~isequal(hmax_height, false)
      img_hmax = imhmax(img_smooth,hmax_height);
      if ismember(debug_level,{'All'})
        f = figure(8260); clf; set(f,'name','h-max','NumberTitle', 'off')
        imshow3D(img_hmax,[]);
      end
      seeds = imregionalmax(img_hmax);
    else
      seeds = imregionalmax(img_smooth);
    end
  else
    % seeds have been supplied by user
    if isstruct(seeds)
      seeds = seeds.matrix;
    end
  end
  % remove seeds outside of our img mask
  seeds(img_thresh==0)=0;

  %% Watershed
  img_min = imimposemin(max(img_smooth(:))-img_smooth,seeds);
  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    imshow3D(img_min,[]);
  end
  
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow3D(img_ws,[]);
  end

  img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow3D(img_ws,[]);
  end

  % Clear cells touching the boarder
  if isnumeric(boarder_clear)
    if isequal(boarder_clear,0)
      bordercleared_img = imclearborder(img_ws);
    else
      % Clear objects touching boarder too much (ex. too much could be 1/4 of perimeter)
      bordercleared_img = img_ws;
      for idx=1:max(img_ws(:))
        single_object = img_ws == idx;
        ind = find(single_object);
        [x y z] = ind2sub(size(single_object), ind);
        count_edge_touches = ismember([x; y], [1 size(single_object,1), size(single_object,2)]);
        count_perim = bwperim(single_object);
        % If the object touches the edge for more than 1/5 the length of the perimeter, delete it
        if sum(count_edge_touches) > sum(count_perim(:)) / (100 / boarder_clear)
          bordercleared_img(bordercleared_img==idx)=0; % delete this object
        end
      end
    end
    if ismember(debug_level,{'All'})
      f = figure(5221); clf; set(f,'name','imclearborder','NumberTitle', 'off')
      imshow(bordercleared_img,[]);
    end
  else
    bordercleared_img = img_ws;
  end

  % Fill holes
  filled_img = imfill(bordercleared_img,'holes');
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','fill holes','NumberTitle', 'off')
    imshow3D(filled_img,[]);
  end

  % Remove segments that don't have a seed (only if user supplied seeds)
  if user_supplied_seeds
    reconstruct_img = imreconstruct(logical(seeds),logical(filled_img));
    labelled_img = bwlabeln(reconstruct_img);
    if ismember(debug_level,{'All'})
      f = figure(5114); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
      imshow3D(reconstruct_img,[]);
    end
  else
    labelled_img = bwlabeln(filled_img);
  end

  %% Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;
  labelled_img = bwlabeln(labelled_img);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','obj size threshold','NumberTitle', 'off');
    imshow3D(labelled_img,[]);
  end

  % Return result
  result = labelled_img;

  % Debug segmentation with color overlay
  if ismember(debug_level,{'All','Result Only','Result With Seeds'})
    num_objects = max(labelled_img(:));
    max_intensity = max(img(:));
    colors = get_n_length_colormap('hsv',num_objects,'shuffle');
    seg_colored_img = cat(4, img, img, img);

    % Make labelled perimeters
    perim_labelled_img = [];
    for zid = 1:size(labelled_img,3)
      perim_labelled_img(:,:,zid) = bwperim(labelled_img(:,:,zid));
    end
    perim_labelled_img = perim_labelled_img .* labelled_img; % reapply labels

    % Burn in color segmentation lines
    for idx=1:num_objects
      object = perim_labelled_img == idx;
      seg_colored_img(find(object)) = colors(idx,1) * max_intensity;
      seg_colored_img(find(object)+size(img,1)*size(img,2)*size(img,3)) = colors(idx,2) * max_intensity ;
      seg_colored_img(find(object)+size(img,1)*size(img,2)*size(img,3)*2) = colors(idx,3) * max_intensity;
    end

    % Display
    f = figure(7943); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    imshow3D(normalize0to1(seg_colored_img),[])
  end

end