function result = fun(plugin_name, plugin_num, img, smooth_param, thresh_param, min_area, max_area, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  % Smooth
  img_smooth = imgaussfilt(img,smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end

  %% Threshold
  % handle percentile threshold
  if contains(thresh_param,'%')
    percent_location = strfind(thresh_param,'%');
    thresh_param = thresh_param(1:percent_location-1); % remove '%' sign
    thresh_param = str2num(thresh_param); % convert to number
    img_thresh = img_smooth > prctile(img_smooth(:), thresh_param);
  % handle fixed intensity threshold
  else 
    img_thresh = img_smooth > str2num(thresh_param);
  end
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end
  
  % Remove objects that are too small or too large
  labelled_img = bwlabeln(img_thresh);
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;
  img_thresh = labelled_img > 0;
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','obj size threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end

  % Return result
  result = labelled_img;

  % Debug segmentation with color overlay
  if ismember(debug_level,{'All','Result Only'})
    f = figure(1422); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    % Display original image
    % Cast img as double, had issues with 32bit
    img8 =  img; %im2uint8(double(img));
    if min(img8(:)) < prctile(img8(:),99.5)
        min_max = [min(img8(:)) prctile(img8(:),99.5)];
    else
        min_max = [];
    end
    imshow(img8,[min_max]);
    hold on
    % Display color overlay
    labelled_perim = bwperim(labelled_img);
    labelled_rgb = label2rgb(uint32(labelled_perim), [1 0 0]);
    himage = imshow(im2uint8(labelled_rgb),[min_max]);
    himage.AlphaData = labelled_perim*1;
    if ismember(debug_level,{'All','Result With Seeds'})
      if ~isequal(seeds,false)
        seeds(labelled_img<1)=0;
        % Display red dots for seeds
        [xm,ym]=find(seeds);
        hold on
        plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
      end
    end
    hold off
  end

end