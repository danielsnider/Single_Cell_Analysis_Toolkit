function result = fun(threshold_smooth_param, thresh_param, min_area, max_area, debug_level, seeds, img)

  % Smooth
  img_smooth = imgaussfilt(img,threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','imgaussfilt','NumberTitle', 'off'); imshow(img_smooth,[])
    imshow(img_smooth,[]);
  end


  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off'); imshow(img_thresh,[])
    imshow(img_thresh,[]);
  end

  % remove seeds outside of our img mask
  seeds(img_thresh==0)=0;

  % Debug with plot
  if ismember(debug_level,{'All'})
    [X Y] = find(seeds);
    f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
    imshow(img,[]);
    hold on;
    plot(Y,X,'or','markersize',2,'markerfacecolor','r')
  end

  %% Watershed
  img_min = imimposemin(max(img(:))-img,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
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
  reconstruct_img = imreconstruct(seeds,logical(filled_img));
  if ismember(debug_level,{'All'})
    f = figure(514); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
    imshow(reconstruct_img,[]);
  end

  % Label image
  labelled_img = bwlabel(reconstruct_img);

  % Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);
  for idx=1:length(area)
    size = area(idx);
    if size>max_area | size<min_area
      labelled_img(labelled_img==idx)=0;
    end
  end
  if ismember(debug_level,{'All'})
    f = figure(513); clf; set(f,'name','limit area','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end


  % Return result
  result = labelled_img;

  if ismember(debug_level,{'All','Result Only'})
    f = figure(743); clf; set(f,'name','watersed result','NumberTitle', 'off')
    % Display original image
    imshow(uint8(img./8),[]);
    hold on
    % Display color overlay
    labelled_rgb = label2rgb(uint32(bwlabel(bwperim(labelled_img))), 'jet', [1 1 1], 'shuffle');
    himage = imshow(uint8(labelled_rgb),[]);
    himage.AlphaData = bwperim(labelled_img)*1;
    % Display red borders
    [xm,ym]=find(seeds);
    hold on
    plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
  end
  
end