function seeds = spotA(smooth_param, debug_level, img)
  img_smooth = imgaussfilt(img,smooth_param);
  seeds = imregionalmax(img_smooth);

  if ismember(debug_level,{'Result Only'})
    [X Y] = find(seeds);
    f = figure(222); clf; set(f, 'name','seeds','NumberTitle', 'off')
    imshow(img,[]);
    hold on;
    plot(Y,X,'or','markersize',2,'markerfacecolor','r')
    hold off;
  end

end