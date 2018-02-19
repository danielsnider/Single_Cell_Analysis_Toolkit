function img = fun(plugin_name, plugin_num, img, close_param, open_param, line_scan, debug_level)

  line_scan = uint16((line_scan/100)*size(img,2)); % convert 0-100% to number of pixels for this image

  if ismember(debug_level,{'On'})
    f = figure(21); clf; set(f,'name','input','NumberTitle', 'off');
    imshow(img,[])
    hold on
    plot([line_scan line_scan],[0 size(img,1)],'-r')
  end

  if ~isequal(close_param,false)
    % Close
    imc=imclose(img,strel('disk',close_param));

    if ismember(debug_level,{'On'})
      f = figure(22); clf; set(f,'name','close','NumberTitle', 'off');
      imshow(imc,[])
      hold on
      plot([line_scan line_scan],[0 size(img,1)],'-r')
    end
  else
    imc = img;
  end

  if ~isequal(open_param,false)
    % Open
    imo=imopen(imc,strel('disk',open_param));

    if ismember(debug_level,{'On'})
      f = figure(23); clf; set(f,'name','open','NumberTitle', 'off');
      imshow(imo,[])
      hold on
      plot([line_scan line_scan],[0 size(img,1)],'-r')
    end
  else
    imo = img;
  end

  % Correct Image
  im_corrected=img-imo;

  if ismember(debug_level,{'On'})
    f = figure(24); clf; set(f,'name','corrected','NumberTitle', 'off');
    imshow(im_corrected,[])
    hold on
    plot([line_scan line_scan],[0 size(img,1)],'-r')
  end

  if ismember(debug_level,{'On'})
    f = figure(25); clf; set(f,'name','line scan','NumberTitle', 'off');
    plot(img(:,line_scan),'k')
    hold on
    plot(imo(:,line_scan),'r')
    plot(im_corrected(:,line_scan),'b')
    legend('Original','Reduction','Corrected')
    hold off
  end

  % Return Result
  img = im_corrected;
end