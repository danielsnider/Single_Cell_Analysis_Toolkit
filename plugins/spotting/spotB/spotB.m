function [X Y] = spotA(img, smooth_param, markersize)
  img_smooth = imgaussfilt(img,smooth_param); % more smoothing to join close seeds
  seeds = imregionalmax(img_smooth);
  % seeds(img_mask==0)=0; % remove seeds outside of our img mask
  % Debug with plot
  [X Y] = find(seeds);
  %figure('name','seeds','NumberTitle', 'off')
  figure(2)
  imshow(img,[]);
  hold on;
  plot(Y,X,'or','markersize',markersize*2,'markerfacecolor','r')

end