function result = fun(img, smooth_param, thresh_param, seeds)

  % threshold
  img_thresh = img > thresh_param;
  figure('name','img_thresh','NumberTitle', 'off'); imshow(img_thresh,[])

  % clear small objects
  % img_nuc_cleared = bwareaopen(img_thresh, 2000);
  % figure('name','nuc_mask_cleared','NumberTitle', 'off'); imshow(img_nuc_cleared,[])

  % img_mask = img_nuc_cleared; % set a better variable name


  %% Find seeds
  seeds(img_thresh==0)=0; % remove seeds outside of our img mask
  % Debug with plot
  [X Y] = find(seeds);
  figure('name','seeds','NumberTitle', 'off')
  imshow(img,[]);
  hold on;
  plot(Y,X,'or','markersize',2,'markerfacecolor','r')


  %% Watershed
  img_smooth = imgaussfilt(img,smooth_param); % don't smooth too much for watersheding
  img_min = imimposemin(-img_smooth,seeds); % set locations of seeds to be -Inf (cause matlab watershed)
  %figure('name','img_min','NumberTitle', 'off')
  %imshow(img_min,[]);
  img_ws = watershed(img_min);
  img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  figure('name','img_ws','NumberTitle', 'off')
  imshow(img_ws,[]);

  labelled_img = img_ws; % set a better variable name

  % Clear cells touching the boarder
  labelled_img = imclearborder(labelled_img);

  % Fill holes
  labelled_img = imfill(labelled_img,'holes');
  figure('name','labelled_img','NumberTitle', 'off')
  imshow(labelled_img,[]);

  % Return result
  result = labelled_img;
end