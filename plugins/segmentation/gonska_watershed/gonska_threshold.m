function result = fun(plugin_name, plugin_num, img, smooth_param, thresh_param, neighborhood_param, min_area, max_area, mean_intensity_threshold, solidity_threshold, eccentricity_threshold, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  % Smooth
  im_smooth = imgaussfilt(img,smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(2886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow(im_smooth,[]);
  end

  % Threshold
  % median_val = double(median(img(:)));
  % adaptive_sensitivity = 30;
  % adaptive_factor = adaptive_sensitivity*median_val*.001+thresh_param;
  % if adaptive_factor > 0.5
  %   adaptive_factor = 0.5;
  % end
  % if adaptive_factor < 0
  %   adaptive_factor = 0;
  % end
  % T = adaptthresh(im_smooth, adaptive_factor);

  if mod(neighborhood_param,2)==0
    neighborhood_param = neighborhood_param + 1;
  end
  T = adaptthresh(im_smooth, thresh_param, 'NeighborhoodSize', neighborhood_param);
  im_thresh = imbinarize(im_smooth,T);
  if ismember(debug_level,{'All'})
    f = figure(2885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(im_thresh,[]);
  end

  im_bordercleared = imclearborder(im_thresh);
  if ismember(debug_level,{'All'})
    f = figure(2883); clf; set(f,'name','clearborder','NumberTitle', 'off');
    imshow(im_bordercleared,[]);
  end

  im_filled = imfill(im_bordercleared,'holes');
  if ismember(debug_level,{'All'})
    f = figure(2882); clf; set(f,'name','fill holes','NumberTitle', 'off');
    imshow(im_filled,[]);
  end

  % Remove large regions with low entropy 
  im_smooth = imgaussfilt(img,5,'filtersize',55);
  im_stdev = stdfilt(im_smooth);
  im_stdev_thresh = im_stdev<.6;
  im_stdev_open = imopen(im_stdev_thresh,strel('disk',55));
  if ismember(debug_level,{'All'})
    f = figure(2881); clf; set(f,'name','low entropy mask','NumberTitle', 'off');
    imshow(im_stdev_open,[]);
  end
  im_filled(im_stdev_open==1)=0;
  if ismember(debug_level,{'All'})
    f = figure(2881); clf; set(f,'name','low entropy removed','NumberTitle', 'off');
    imshow(im_filled,[]);
  end

  % Min size (2D)
  im_areafilt = bwareafilt(im_filled,[min_area max_area]);
  if ismember(debug_level,{'All'})
    f = figure(2880); clf; set(f,'name','min max size filter','NumberTitle', 'off');
    imshow(im_areafilt,[]);
  end

  im_labelled = bwlabel(im_areafilt);

  if ~isequal(mean_intensity_threshold,false)      
      stats = regionprops(im_labelled, img, 'MeanIntensity');
      mean_intensity = cat(1,stats.MeanIntensity); % double check this

      if contains(mean_intensity_threshold,'%')
        % handle percentile threshold
        percent_location = strfind(mean_intensity_threshold,'%');
        mean_intensity_threshold = mean_intensity_threshold(1:percent_location-1); % remove '%' sign
        mean_intensity_threshold = str2num(mean_intensity_threshold); % convert to number
        im_labelled(ismember(im_labelled,find(mean_intensity < prctile(mean_intensity(:), mean_intensity_threshold))))=0;
      else 
        % handle fixed intensity threshold
        im_labelled(ismember(im_labelled,find(mean_intensity < str2num(mean_intensity_threshold))))=0;
      end

      if ismember(debug_level,{'All'})
        f = figure(66280); clf; set(f,'name','mean intensity filter','NumberTitle', 'off');
        imshow(im_labelled,[]);
      end
  end
  
  im_labelled = bwlabel(im_labelled);

  if ~isequal(solidity_threshold,false)      
      stats = regionprops(im_labelled,'solidity');
      solidity = cat(1,stats.Solidity); % double check this
      im_labelled(ismember(im_labelled,find(solidity < solidity_threshold)))=0;
      if ismember(debug_level,{'All'})
        f = figure(6680); clf; set(f,'name','solidity filter','NumberTitle', 'off');
        imshow(im_labelled,[]);
      end
  end
  
  im_labelled = bwlabel(im_labelled);

  if ~isequal(eccentricity_threshold,false)      
      stats = regionprops(im_labelled,'eccentricity');
      eccentricity = cat(1,stats.Eccentricity); % double check this
      im_labelled(ismember(im_labelled,find(eccentricity > eccentricity_threshold)))=0;
      if ismember(debug_level,{'All'})
        f = figure(6610); clf; set(f,'name','eccentricity filter','NumberTitle', 'off');
        imshow(im_labelled,[]);
      end
  end

  % Return result
  result = im_labelled;

  % Visualize
  if ismember(debug_level,{'All','Result Only'})
    f = figure(17883); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    if min(img(:)) < prctile(img(:),99.5)
        min_max = [min(img(:)) prctile(img(:),99.5)];
    else
        min_max = [];
    end
    imshow(img,[min_max]);
    hold on
    % Display color overlay
    im_perim = imdilate(bwperim(result),strel('disk',0));
    labelled_rgb = label2rgb(uint32(im_perim), [0 1 0], [1 1 1]);
    himage = imshow(im2uint8(labelled_rgb),[min_max]);
    himage.AlphaData = im_perim*1;
  end
end
