function result = fun(plugin_name, plugin_num, img, smooth_param, thresh_param, close_size, open_size, min_area, max_area, debug_level)
    
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
  T = adaptthresh(im_smooth, thresh_param);
  im_thresh = imbinarize(im_smooth,T);
  if ismember(debug_level,{'All'})
    f = figure(2885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(im_thresh,[]);
  end

  % Shrink white objects to remove small dots and thin lines
  im_close = imclose(im_thresh,strel('disk',close_size));
  if ismember(debug_level,{'All'})
    f = figure(2884); clf; set(f,'name','imclose','NumberTitle', 'off');
    imshow(im_thresh,[]);
  end

  im_bordercleared = imclearborder(im_close);
  if ismember(debug_level,{'All'})
    f = figure(2883); clf; set(f,'name','clearborder','NumberTitle', 'off');
    imshow(im_bordercleared,[]);
  end

  im_filled = imfill(im_bordercleared,'holes');
  if ismember(debug_level,{'All'})
    f = figure(2882); clf; set(f,'name','fill holes','NumberTitle', 'off');
    imshow(im_filled,[]);
  end
    
  im_open = imopen(im_filled,strel('disk',open_size));
  if ismember(debug_level,{'All'})
    f = figure(2881); clf; set(f,'name','imopen','NumberTitle', 'off');
    imshow(im_open,[]);
  end

  % MAGIC
  im_smooth = imgaussfilt(img,5,'filtersize',55);
  im_stdev = stdfilt(im_smooth);
  im_stdev_thresh = im_stdev<.6;
  im_stdev_open = imopen(im_stdev_thresh,strel('disk',55));
  if ismember(debug_level,{'All'})
    figure; imshow(im_stdev_open,[]);
  end
  im_open(im_stdev_open==1)=0;
  if ismember(debug_level,{'All'})
    figure; imshow(im_open,[]);
  end
  filled_img = imfill(im_open,'holes');
  if ismember(debug_level,{'All'})
    figure; imshow(filled_img,[]);
  end

  % Min size
  im_areafilt = bwareafilt(filled_img,[min_area max_area]);
  if ismember(debug_level,{'All'})
    f = figure(2880); clf; set(f,'name','min max size filter','NumberTitle', 'off');
    imshow(im_areafilt,[]);
  end

  result = im_areafilt;

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
