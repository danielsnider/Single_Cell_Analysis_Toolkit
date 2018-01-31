function result = fun(img, seeds, smooth_param)
  cyto = img;
  %% Remove extreme pixel values (this also scales values between 0 and 1)
  bot = double(prctile(cyto(:),1));
  top = double(prctile(cyto(:),99));
  cyto = (double(cyto)-bot) / (top - bot);
  cyto(cyto>1) = 1; % do the removing
  cyto(cyto<0) = 0; % do the removing
  figure('name','cyto','NumberTitle', 'off'); imshow(cyto,[])

  % threshold
  cyto_thresh = cyto > .18;
  %cyto_thresh = cyto > graythresh(cyto); % otsu
  figure('name','cyto_thresh','NumberTitle', 'off'); imshow(cyto_thresh,[])

  % clear small objects
  cyto_nuc_cleared = bwareaopen(cyto_thresh, 2000);
  figure('name','nuc_mask_cleared','NumberTitle', 'off'); imshow(cyto_nuc_cleared,[])
  % % Finding the best number manually :-(, could use Otsu! :-)
  % for x=800:100:2000
  %     nuc_mask_cleared = bwareaopen(cyto_thresh, x);
  %     %nuc_mask = imopen(cyto_thresh,strel('disk',x)); 
  %     figure('name',num2str(x),'NumberTitle', 'off'); imshow(nuc_mask_cleared,[])
  % end

  cyto_mask = cyto_nuc_cleared; % set a better variable name


  %% Find seeds
  % cyto_smooth = imgaussfilt(cyto,12); % more smoothing to join close seeds
  % seeds = imregionalmax(cyto_smooth);
  seeds(cyto_mask==0)=0; % remove seeds outside of our cyto mask
  % Debug with plot
  [X Y] = find(seeds)
  figure('name','seeds','NumberTitle', 'off')
  imshow(cyto,[]);
  hold on;
  plot(Y,X,'or','markersize',2,'markerfacecolor','r')

  X = seeds(:,2);
  Y = seeds(:,1);

  % Finding the best number manually :-(, could use Otsu! :-)
  % for x=10:20
  %   cyto_smooth = imgaussfilt(cyto,x);
  %   seeds = imregionalmax(cyto_smooth);
  %   seeds(cyto_mask==0)=0;
  %   [X Y] = find(seeds)
  %  figure('name',num2str(x),'NumberTitle', 'off')
  %   imshow(cyto,[]);
  %   hold on;
  %   plot(Y,X,'or','markersize',2,'markerfacecolor','r')
  % end


  %% Watershed
  cyto_smooth = imgaussfilt(cyto,1); % don't smooth too much for watersheding
  cyto_min = imimposemin(-cyto_smooth,seeds); % set locations of seeds to be -Inf (cause matlab watershed)
  %figure('name','cyto_min','NumberTitle', 'off')
  %imshow(cyto_min,[]);
  cyto_ws = watershed(cyto_min);
  cyto_ws(cyto_mask==0)=0; % remove areas that aren't in our cyto mask
  figure('name','cyto_ws','NumberTitle', 'off')
  imshow(cyto_ws,[]);

  labelled_cyto = cyto_ws; % set a better variable name

  % Clear cells touching the boarder
  labelled_cyto = imclearborder(labelled_cyto);

  % Fill holes
  labelled_cyto = imfill(labelled_cyto,'holes');
  figure('name','labelled_cyto','NumberTitle', 'off')
  imshow(labelled_cyto,[]);

  % Return result
  result = labelled_cyto;
  done='B'
end