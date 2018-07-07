function result = fun(plugin_name, plugin_num, img, threshold_smooth_param, watershed_smooth_param, thresh_param, imhmin_param, min_area, max_area, solidity_threshold, eccentricity_threshold, debug_level)

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

  % Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);  
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

  if ~isequal(solidity_threshold,false)
      % Remove objects less than specified solidity
      if solidity_threshold > 1 || solidity_threshold < 0
          solidity_threshold = 0.75;
          fprintf('Using default solidity threshold: %f',solidity_threshold)
      end
      
      stats = regionprops(labelled_img,'solidity');
      solidity = cat(1,stats.Solidity); % double check this
      labelled_img(ismember(labelled_img,find(solidity < solidity_threshold)))=0;
  end
  
  if ~isequal(eccentricity_threshold,false)
      % Remove objects less than specified solidity
      if eccentricity_threshold > 1 || eccentricity_threshold < 0
          eccentricity_threshold = 0.95;
          fprintf('Using default eccentricity threshold: %f',eccentricity_threshold)
      end
      
      stats = regionprops(labelled_img,'eccentricity');
      eccentricity = cat(1,stats.Eccentricity); % double check this
      labelled_img(ismember(labelled_img,find(eccentricity > eccentricity_threshold)))=0;
  end
  
  % Return result
  result = bwlabel(labelled_img);

  if ismember(debug_level,{'All','Result Only','Result With Seeds'})
    f = figure(643); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    % Display original image
    img8 = im2uint8(img);
    if min(img8(:)) < prctile(img8(:),99.5)
        min_max = [min(img8(:)) prctile(img8(:),99.5)];
    else
        min_max = [];
    end
    imshow(img8,[min_max]);
    hold on
    % Display color overlay
    labelled_perim = imdilate(bwlabel(bwperim(labelled_img)),strel('disk',0));
    labelled_rgb = label2rgb(uint32(labelled_perim), 'jet', [1 1 1], 'shuffle');
    himage = imshow(im2uint8(labelled_rgb),[min_max]);
    himage.AlphaData = labelled_perim*1;
    if ismember(debug_level,{'All','Result With Seeds'})
      seeds(labelled_img<1)=0;
      % Display red dots for seeds
      [xm,ym]=find(seeds);
      hold on
      plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
    end
    hold off
  end
  
end