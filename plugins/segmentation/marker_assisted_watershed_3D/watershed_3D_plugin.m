function result = fun(plugin_name, plugin_num, img, threshold_smooth_param, thresh_param, watershed_smooth_strength, watershed_smooth_size, min_area, max_area, hmax_height, debug_level)
  % result = img;
  % return
  
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
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
    img_thresh = img_smooth > thresh_param;
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
  
  %% Seed
  seeds(img_thresh==0)=0;
  % 3D seeds don't show correctly
%   if ismember(debug_level,{'All'})
%     [X Y] = find(seeds);
%     f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
%     imshow3D(img,[]);
%     hold on;
%     plot(Y,X,'or','markersize',2,'markerfacecolor','r')
%   end

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
  filled_img = imfill(img_ws,'holes');
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow3D(img_ws,[]);
  end

  % % Clear cells touching the boarder
  % bordercleared_img = imclearborder(img_ws);
  % if ismember(debug_level,{'All'})
  %   f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
  %   imshow3D(bordercleared_img,[]);
  % end

  %% Remove objects that are too small or too large
  labelled_img = bwlabeln(filled_img);
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
    if prctile(seg_colored_img(:),97.8) > 255
        imshow3D(uint16(seg_colored_img),[])
    else
        imshow3D(uint8(seg_colored_img),[])
    end
  end

end