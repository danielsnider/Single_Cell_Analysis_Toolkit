function result = fun(plugin_name, plugin_num, img, threshold_smooth_param, thresh_param, watershed_smooth_strength, watershed_smooth_size, min_area, max_area, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  % Smooth for threshold
  img_smooth = imgaussfilt(img,threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow3D(img_smooth,[]);
  end

  %% Threshold
  % handle percentile threshold
  if contains(thresh_param,'%') 
    percent_location = strfind(thresh_param,'%');
    thresh_param = thresh_param(1:percent_location-1); % remove '%' sign
    thresh_param = str2num(thresh_param); % convert to number
    thresh_param = thresh_param / 100; % convert 95 to 0.95, needed for prctile
    img_thresh = img_smooth > prctile(img_smooth(:), thresh_param);
  % handle fixed intensity threshold
  else 
    img_thresh = img_smooth > thresh_param;
  end
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow3D(img_thresh,[]);
  end

  % Smooth for watershed segmentation
  watershed_smooth_strength = str2num(watershed_smooth_strength); % example: convert '2 2 3' to [2 2 3]. Needed because GUI doesn't have a nice way to enter multiple numbers except as a string.
  watershed_smooth_size = str2num(watershed_smooth_size); % example: convert '2 2 3' to [2 2 3]. Needed because GUI doesn't have a nice way to enter multiple numbers except as a string.
  img_smooth = imgaussfilt3(img, watershed_smooth_strength, 'FilterSize', watershed_smooth_size);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow3D(img_smooth,[]);
  end

  %% Seed
  seeds = imregionalmax(img_smooth);
  seeds(img_thresh==0)=0;
  if ismember(debug_level,{'All'})
    [X Y] = find(seeds);
    f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
    imshow3D(img,[]);
    hold on;
    plot(Y,X,'or','markersize',2,'markerfacecolor','r')
  end

  %% Watershed
  img_min = imimposemin(max(img_smooth(:))-img_smooth,seeds); 
  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    imshow3D(img_min,[]);
  end
  
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow3D(img_ws,[]);
  end

  img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  filled_img = imfill(img_ws,'holes');
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow3D(img_ws,[]);
  end

  % % Clear cells touching the boarder
  % bordercleared_img = imclearborder(img_ws);
  % if ismember(debug_level,{'All'})
  %   f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
  %   imshow3D(bordercleared_img,[]);
  % end


  %% Remove objects that are too small or too large
  labelled_img = bwlabeln(filled_img);
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;
  labelled_img = bwlabeln(labelled_img);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','obj size threshold','NumberTitle', 'off');
    imshow3D(labelled_img,[]);
  end

  % Return result
  result = {};
  result.matrix = labelled_img;
% 
%   if ismember(debug_level,{'All','Result Only','Result With Seeds'})
%     f = figure(743); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
%     % Display original image
%     % Cast img as double, had issues with 32bit
%     img8 = im2uint8(double(img));
%     if min(img8(:)) < prctile(img8(:),99.5)
%         min_max = [min(img8(:)) prctile(img8(:),99.5)];
%     else
%         min_max = [];
%     end
%     imshow3D(img8,[min_max]);
%     
%     figure(7801) % hold on
% 
%     % Display color overlay
%     labelled_perim = imdilate(bwlabel(bwperim(labelled_img)),strel('disk',0));
%     labelled_rgb = label2rgb(uint32(labelled_perim), 'jet', [1 1 1], 'shuffle');
%     himage = imshow3D(im2uint8(labelled_rgb),[min_max]);
%     himage.AlphaData = labelled_perim*1;
%     % if ismember(debug_level,{'All','Result With Seeds'})
%     %   if ~isequal(seeds,false)
%     %     seeds(labelled_img<1)=0;
%     %     % Display red dots for seeds
%     %     [xm,ym]=find(seeds);
%     %     hold on
%     %     plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
%     %   end
%     % end
%     hold off
%   end
%   
end