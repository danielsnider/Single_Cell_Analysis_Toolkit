function result = fun(threshold_smooth_param, watershed_smooth_param, thresh_param, imhmin_param, min_area, max_area, debug_level, img)

  % Smooth
  img_smooth = imgaussfilt(img,watershed_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(681); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end

  % Imhmin
  img_hmin = imhmin(img_smooth,imhmin_param);
  if ismember(debug_level,{'All'})
    f = figure(682); clf; set(f,'name','hmin','NumberTitle', 'off');
    imshow(img_hmin,[]);
  end

  % Seeds
  [seeds]=imregionalmin(img_hmin);
  if ismember(debug_level,{'All'})
    f = figure(683); clf; set(f,'name','seeds','NumberTitle', 'off');
    imshow(seeds,[]);
  end

  % imimposemin
  img_min = imimposemin(img,seeds);
  if ismember(debug_level,{'All'})
    f = figure(684); clf; set(f,'name','imposemin','NumberTitle', 'off');
    imshow(img_min,[]);
  end

  %% Watershed
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(665); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  if ~isequal(thresh_param,false)
    % Smooth
    img_smooth = imgaussfilt(img,threshold_smooth_param);
    if ismember(debug_level,{'All'})
      f = figure(680); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
      imshow(img_smooth,[]);
    end

    % Threshold
    img_thresh = img_smooth < thresh_param;
    img_ws(img_thresh)=0;
    seeds(img_thresh)=0;
    if ismember(debug_level,{'All'})
      f = figure(679); clf; set(f,'name','threshold','NumberTitle', 'off');
      imshow(img_ws,[]);
    end
  end

  % Clear cells touching the boarder
  bordercleared_img = imclearborder(img_ws);
  if ismember(debug_level,{'All'})
    f = figure(616); clf; set(f,'name','imclearborder','NumberTitle', 'off')
    imshow(bordercleared_img,[]);
  end

  labelled_img = bwlabel(bordercleared_img);
  seeds(labelled_img<1)=0;

  % Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);  
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

  % Return result
  result = labelled_img;

  if ismember(debug_level,{'All','Result Only','Result With Seeds'})
    f = figure(643); clf; set(f,'name','watershed result','NumberTitle', 'off')
    % Display original image
    img8 = im2uint8(img);
    imshow(img8,[min(img8(:)) prctile(img8(:),99.5)]);
    hold on
    % Display color overlay
    labelled_perim = imdilate(bwlabel(bwperim(labelled_img)),strel('disk',0));
    labelled_rgb = label2rgb(uint32(labelled_perim), 'jet', [1 1 1], 'shuffle');
    himage = imshow(uint8(labelled_rgb),[min(img8(:)) prctile(img8(:),99.5)]);
    himage.AlphaData = labelled_perim*1;
    if ismember(debug_level,{'All','Result With Seeds'})
      % Display red dots for seeds
      [xm,ym]=find(seeds);
      hold on
      plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
    end
    hold off
  end
  
end