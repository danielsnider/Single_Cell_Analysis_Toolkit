function result = fun(plugin_name, plugin_num, img, threshold_smooth_param, thresh_param, watershed_smooth_param, min_area, max_area, boarder_clear, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  is_3D = false;
  preview_img = img;
  imshow_2d = @imshow;
  new_imshow = @imshow;
  new_bwlabel = @bwlabel;
  if ndims(img) == 3
    middle_zslice = floor(size(img,3)/2);
    is_3D = true;
    preview_img = img(:,:,middle_zslice);
    new_imshow = @imshow3D;
    new_bwlabel = @bwlabeln;
  end

  % Get user input
  min_im = min(img(:));
  upper_limit = prctile(img(:), 95);
  disp_limits = [min_im upper_limit];

  f = figure;imshow_2d(preview_img,disp_limits);
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
  if is_3D
    seeds_3D = zeros(size(img,1),size(img,2),size(img,3));
    seeds_3D(:,:,middle_zslice) = seeds;
    seeds = seeds_3D;
  end

  % Smooth
  img_smooth = imgaussfilt(double(img),threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    new_imshow(img_smooth,disp_limits);
  end
  
  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    new_imshow(img_thresh,[]);
  end

  % holes
  for zid=1:size(img,3)
    img_thresh(:,:,zid) = imfill(img_thresh(:,:,zid),'holes');
  end
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','filled holes','NumberTitle', 'off')
    new_imshow(img_thresh,[]);
  end

  % Remove objects that are too small or too large
  for zid=1:size(img,3)
    img_thresh(:,:,zid) = bwareafilt(img_thresh(:,:,zid),[min_area max_area]);
  end
  if ismember(debug_level,{'All'})
    f = figure(513); clf; set(f,'name','min max size','NumberTitle', 'off')
    new_imshow(img_thresh,[]);
  end


  % Smooth for watershed segmentation
  img_smooth2 = imgaussfilt(img,watershed_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(889); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
    new_imshow(img_smooth2,disp_limits);
  end

  % Watershed preprocessing
  img_min = imimposemin(max(img_smooth2(:))-img_smooth2,seeds);
  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    new_imshow(img_min,[prctile(img_min(:),5) prctile(img_min(:),95)]);
  end
  
  % Watershed
  img_ws = watershed(img_min);
  bwlabel_limits = [min(img_ws(:)) max(img_ws(:))];
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    new_imshow(img_ws,bwlabel_limits);
  end

  % Cemove areas that aren't in our img mask
  img_ws(img_thresh==0)=0; 
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    new_imshow(img_ws,bwlabel_limits);
  end

  % Remove segments that don't have a seed
  reconstruct_img = imreconstruct(logical(seeds),logical(img_ws));
  labelled_img = new_bwlabel(reconstruct_img);
  if ismember(debug_level,{'All'})
    f = figure(514); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
    new_imshow(reconstruct_img,bwlabel_limits);
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
    new_imshow(labelled_img,bwlabel_limits);
  end
  labelled_img = new_bwlabel(labelled_img);


  % Clear objects touching boarder too much (too much=1/4 of perimeter)
  if isnumeric(boarder_clear)
    if isequal(boarder_clear,0)
      labelled_img = imclearborder(labelled_img);
    else
      for idx=1:max(img_ws(:))
        single_object = labelled_img == idx;
        ind = find(single_object);
        [x y z] = ind2sub(size(single_object), ind);
        count_edge_touches = ismember([x; y], [1 size(single_object,1), size(single_object,2)]);
        count_perim = bwperim(single_object);
        % If the object touches the edge for more than 1/5 the length of the perimeter, delete it
        if sum(count_edge_touches) > sum(count_perim(:)) / (100 / boarder_clear)
          labelled_img(labelled_img==idx)=0; % delete this object
          idx
        end
      end
    end
    if ismember(debug_level,{'All'})
      f = figure(5112); clf; set(f,'name','imclearborder','NumberTitle', 'off')
      new_imshow(labelled_img,bwlabel_limits);
    end
  end
  labelled_img = new_bwlabel(labelled_img);

  % Return result
  result = labelled_img;

  if is_3D
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
      f = figure(7439); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
      imshow3D(normalize0to1(seg_colored_img),[])
    end
  else
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
      labelled_perim = imdilate(new_bwlabel(bwperim(labelled_img)),strel('disk',0));
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


end