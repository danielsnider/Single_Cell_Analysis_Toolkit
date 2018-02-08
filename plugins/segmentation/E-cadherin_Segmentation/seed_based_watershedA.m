function result = fun(threshold_smooth_param, watershed_smooth_param, thresh_param, min_area, max_area, debug_level, seeds, img)

  % Smooth
  img_smooth = imgaussfilt(img,threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','imgaussfilt','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end


  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end

  % remove seeds outside of our img mask
  if ~isequal(seeds,false)
    seeds(img_thresh==0)=0;

    % Debug with plot
    if ismember(debug_level,{'All'})
      [X Y] = find(seeds);
      f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
      imshow(img,[]);
      hold on;
      plot(Y,X,'or','markersize',2,'markerfacecolor','r')
    end
  end

  if isequal(watershed_smooth_param,true)
    img_smooth2 = imgaussfilt(img,watershed_smooth_param);
  else
    img_smooth2 = img;
  end
  if ismember(debug_level,{'All'})
    f = figure(889); clf; set(f,'name','imgaussfilt2','NumberTitle', 'off');
    imshow(img_smooth2,[]);
  end


  %% Watershed
  if ~isequal(seeds,false)
    img_min = imimposemin(max(img_smooth2(:))-img_smooth2,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
  else
    img_min = max(img_smooth2(:))-img_smooth2;
  end

  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    imshow(img_min,[]);
  end
  
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  % Clear cells touching the boarder
  bordercleared_img = imclearborder(img_ws);
  if ismember(debug_level,{'All'})
    f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
    imshow(bordercleared_img,[]);
  end

  % Fill holes
  filled_img = imfill(bordercleared_img,'holes');
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','imfill','NumberTitle', 'off')
    imshow(filled_img,[]);
  end

  % Remove segments that don't have a seed
  if ~isequal(seeds,false)
    reconstruct_img = imreconstruct(seeds,logical(filled_img));
    labelled_img = bwlabel(reconstruct_img);
    if ismember(debug_level,{'All'})
      f = figure(514); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
      imshow(reconstruct_img,[]);
    end
  else
    labelled_img = bwlabel(filled_img);
  end

  % Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);  
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

  % Return result
  result = labelled_img;

  if ismember(debug_level,{'All','Result Only'})
    f = figure(743); clf; set(f,'name','watersed result','NumberTitle', 'off')
    % Display original image
    imshow(uint8(img./8),[]);
    hold on
    % Display color overlay
    labelled_perim = imdilate(bwlabel(bwperim(labelled_img)),strel('disk',0));
    labelled_rgb = label2rgb(uint32(labelled_perim), 'jet', [1 1 1], 'shuffle');
    himage = imshow(uint8(labelled_rgb),[]);
    himage.AlphaData = labelled_perim*1;
    if ~isequal(seeds,false)
      % Display red dots for seeds
      [xm,ym]=find(seeds);
      hold on
      plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
    end
  end
  
end