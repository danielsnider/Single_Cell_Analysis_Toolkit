function seeds = spot(plugin_name, plugin_num, img, thresh_param, smooth_param, debug_level)
  % Smooth
  img_smooth = imgaussfilt(img,smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(223); clf; set(f, 'name','smooth','NumberTitle', 'off')
    imshow(img_smooth,[]);
  end

  % Remove area outside of mask
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(224); clf; set(f, 'name','threshold','NumberTitle', 'off')
    imshow(img_thresh,[]);
  end

  seeds = imregionalmax(img_smooth);
  seeds(img_thresh==0)=0;

  if ismember(debug_level,{'Result Only','All'})
    [X Y] = find(seeds);
    f = figure(222); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    imshow(img,[]);
    hold on;
    plot(Y,X,'or','markersize',2,'markerfacecolor','r')
    hold off;
  end

end