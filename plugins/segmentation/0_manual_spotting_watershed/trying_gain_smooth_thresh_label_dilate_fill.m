function result = fun(plugin_name, plugin_num, img, seeds, threshold_smooth_param, gain_thresh, connect_dist, watershed_smooth_param, thresh_param, min_area, max_area, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end


  % % Intensity Gain
  img_gain = img>gain_thresh;
  if ismember(debug_level,{'All'})
    f = figure(8888); clf; set(f,'name','intensity gain','NumberTitle', 'off');
    imshow(img_gain,[]);
  end

  % Smooth
  img_smooth = imgaussfilt(double(img_gain),threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end
  
  f = figure
  imshow(img_smooth,[]);
  [x,y] = ginput();
  seeds = img_smooth;
  seeds(:) = 0;
  idx = sub2ind(size(seeds), y, x);
  seeds(idx) = max(img_smooth)*3;
  seeds = imgaussfilt(seeds,50);
  figure
  imshow(seeds,[])

  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end

  % % remove seeds outside of our img mask
  % if ~isequal(seeds,false)
  %   seeds(img_thresh==0)=0;

  %   % Debug with plot
  %   if ismember(debug_level,{'All'})
  %     [X Y] = find(seeds);
  %     f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
  %     imshow(img,[]);
  %     hold on;
  %     plot(Y,X,'or','markersize',2,'markerfacecolor','r')
  %   end
  % end

  % if isequal(watershed_smooth_param,false)
  %   img_smooth2 = img;
  % else
  %   img_smooth2 = imgaussfilt(img,watershed_smooth_param);
  % end
  % if ismember(debug_level,{'All'})
  %   f = figure(889); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
  %   imshow(img_smooth2,[]);
  % end


  % %% Watershed
  % if ~isequal(seeds,false)
  %   img_min = imimposemin(max(img_smooth2(:))-img_smooth2,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
  % else
  %   img_min = max(img_smooth2(:))-img_smooth2;
  % end

  % if ismember(debug_level,{'All'})
  %   f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
  %   imshow(img_min,[]);
  % end
  
  % img_ws = watershed(img_min);
  % if ismember(debug_level,{'All'})
  %   f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
  %   imshow(img_ws,[]);
  % end

  % img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  % if ismember(debug_level,{'All'})
  %   f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
  %   imshow(img_ws,[]);
  % end

  % Clear cells touching the boarder
  % bordercleared_img = img_ws;
  % bordercleared_img = imclearborder(img_ws);
  % if ismember(debug_level,{'All'})
  %   f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
  %   imshow(bordercleared_img,[]);
  % end


  % Remove objects that are too small or too large
  img_thresh = bwareafilt(img_thresh,[min_area max_area]);
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','min max size','NumberTitle', 'off')
    imshow(img_thresh,[]);
  end

  % Label
  labelled_img = bwlabel(img_thresh);
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','labelled','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end

  % Dilate
  labelled_img = imdilate(labelled_img,strel('disk',17));
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','dilate','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end

  % Fill holes
  labelled_img = imfill(labelled_img,'holes');
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','filed holes','NumberTitle', 'off')
    imshow(labelled_img,[]);
  end

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
    hold off
  end
  
end