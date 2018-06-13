function seeds = spot(plugin_name, plugin_num, img, thresh_param, smooth_param, debug_level)
  new_imshow = @imshow;
  is_3D = false;
  if ndims(img) == 3
    middle_zslice = floor(size(img,3)/2);
    is_3D = true;
    preview_img = img(:,:,middle_zslice);
    new_imshow = @imshow3D;
  end


  % Smooth
  if is_3D
    z_smooth_param = sqrt(smooth_param);
    img_smooth = imgaussfilt3(img, [smooth_param smooth_param z_smooth_param]);
  else
    img_smooth = imgaussfilt(img,smooth_param);
  end

  if ismember(debug_level,{'All'})
    f = figure(223); clf; set(f, 'name','smooth','NumberTitle', 'off')
    new_imshow(img_smooth,[]);
  end

  % Remove area outside of mask
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(224); clf; set(f, 'name','threshold','NumberTitle', 'off')
    new_imshow(img_thresh,[]);
  end

  seeds = imregionalmax(img_smooth);
  seeds(img_thresh==0)=0;

  if is_3D
    colored_img = cat(4, img, img, img);
    max_intensity = max(img(:));
    eroded_seeds = imdilate(seeds,strel('sphere',3)); % make seeds big enough to see
    colored_img(find(eroded_seeds)) = max_intensity;
    f = figure(222); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    new_imshow(normalize0to1(colored_img),[]);

  else
    if ismember(debug_level,{'Result Only','All'})
      [X Y] = find(seeds);
      f = figure(222); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
      new_imshow(img,[]);
      hold on;
      plot(Y,X,'or','markersize',2,'markerfacecolor','r')
      hold off;
    end
  end

end