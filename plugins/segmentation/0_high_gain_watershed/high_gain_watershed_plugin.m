function result = fun(plugin_name, plugin_num, img, gain_thresh, threshold_smooth_param, thresh_param, watershed_smooth_param, min_area, max_area, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  % Get user input
  min_im = min(img(:));
  f = figure;imshow(img,[min_im min_im+50]);
  [y x button] = ginput();
  delete(f);
  x = floor(x);
  y = floor(y);

  % Delete out of bounds clicks
  to_delete = zeros(size(x));
  to_delete = to_delete | x<1;
  to_delete = to_delete | y<1;
  to_delete = to_delete | x>size(img,1);
  to_delete = to_delete | y>size(img,2);
  x(find(to_delete)) = [];
  y(find(to_delete)) = [];
  button(find(to_delete)) = [];

  % Convert x and y to an image with dots in it
  seeds = zeros(size(img,1),size(img,2));
  for i=1:length(x)
    seeds(x(i),y(i)) = 1;
  end
  seeds = seeds;

  % Intensity Gain
  img_gain = img>gain_thresh;
  if ismember(debug_level,{'All'})
    f = figure(8888); clf; set(f,'name','intensity gain','NumberTitle', 'off');
    imshow(img_gain,[]);
  end

  % Smooth
  img_smooth = imgaussfilt(double(img),threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end
  
  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end

  % holes
  img_thresh = imfill(img_thresh,'holes');
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','filled holes','NumberTitle', 'off')
    imshow(img_thresh,[]);
  end

  % Remove objects that are too small or too large
  img_thresh = bwareafilt(img_thresh,[min_area max_area]);
  if ismember(debug_level,{'All'})
    f = figure(513); clf; set(f,'name','min max size','NumberTitle', 'off')
    imshow(img_thresh,[]);
  end


  % Smooth for watershed segmentation
  img_smooth2 = imgaussfilt(img,watershed_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(889); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
    imshow(img_smooth2,[]);
  end

  % Watershed preprocessing
  img_min = imimposemin(max(img_smooth2(:))-img_smooth2,seeds);
  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    imshow(img_min,[]);
  end
  
  % Watershed
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  % Cemove areas that aren't in our img mask
  img_ws(img_thresh==0)=0; 
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  % Remove segments that don't have a seed
  reconstruct_img = imreconstruct(logical(seeds),logical(img_ws));
  labelled_img = bwlabel(reconstruct_img);
  if ismember(debug_level,{'All'})
    f = figure(514); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
    imshow(reconstruct_img,[]);
  end

  % Delete objects that user selected
  for idx=1:length(button)
    button_code = button(idx);
    if button_code==100 % 'd' for delete
      object_id = labelled_img(x(idx),y(idx));
      labelled_img(labelled_img == object_id)=0; % delete this object
    end
  end
  if ismember(debug_level,{'All'})
    f = figure(511); clf; set(f,'name','user deletes','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end
  labelled_img = bwlabel(labelled_img);


  % Clear objects touching boarder too much (too much=1/4 of perimeter)  
  % bordercleared_img = img_ws;
  for idx=1:max(img_ws(:))
    single_object = labelled_img == idx;
    [x y] = find(single_object);
    count_edge_touches = ismember([x; y], [1 size(single_object,1), size(single_object,2)]);
    count_perim = bwperim(single_object);
    % If the object touches the edge for more than 1/5 the length of the perimeter, delete it
    if sum(count_edge_touches) > sum(sum(count_perim)) /4
      labelled_img(labelled_img==idx)=0; % delete this object
      idx
    end
  end
  % bordercleared_img = imclearborder(labelled_img);
  if ismember(debug_level,{'All'})
    f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end
  labelled_img = bwlabel(labelled_img);

  % Return result
  result = labelled_img;

  if ismember(debug_level,{'All','Result Only','Result With Seeds'})
    f = figure(743); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    % Display original image
    % Cast img as double, had issues with 32bit
    img8 = im2uint8(double(img));
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
      % seeds(labelled_img<1)=0;
      % Display red dots for seeds
      [xm,ym]=find(seeds);
      hold on
      plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
    end
    hold off
  end

end