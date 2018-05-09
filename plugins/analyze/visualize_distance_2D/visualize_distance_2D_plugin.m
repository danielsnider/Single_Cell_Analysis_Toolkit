function fun(plugin_name, plugin_num, img1, img2, seg1, seg2, Distances, start_points, end_points, title_param, zslice_num, ObjectsInFrame)
  Distances = Distances.data;
  title_param = sprintf('%s: %s' title_param.name, title_param.data);
  start_points = start_points.data;
  end_points = end_points.data;
  num_chans = 2;
  min_dyn_range_percent = 0;
  max_dyn_range_percent = .95;
  img1_ch_color = [0 1 0];
  img2_ch_color = [1 0 0];
  img2_perim_color = [1 .5 .5];
  x_res = size(img1,1);
  y_res = size(img1,2);
  any_objects = ~isempty(Distance);

  % Create figure
  f = figure(plugin_num+4211); clf; set(f,'name',plugin_name,'NumberTitle', 'off');

  % Scale image (img1)
  im_norm = normalize0to1(double(img1));
  im_adj = imadjust(im_norm,[min_dyn_range_percent max_dyn_range_percent], [0 1]); % limit intensites for better viewing 
  img1_scaled = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
  img1_scaled = img1_scaled./length(num_chans); % reduce intensity so not to go overbounds of uint16

  % Scale image (img2)
  im_norm = normalize0to1(double(img2));
  im_adj = imadjust(im_norm,[min_dyn_range_percent max_dyn_range_percent], [0 1]); % limit intensites for better viewing 
  img2_scaled = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
  img2_scaled = img2_scaled./length(num_chans); % reduce intensity so not to go overbounds of uint16

  % Create color composite of img2 and img1
  color_img2 = uint16(zeros(x_res,y_res));
  color_img2(:,:,1) = img2_scaled .* img2_ch_color(1);
  color_img2(:,:,2) = img2_scaled .* img2_ch_color(2);
  color_img2(:,:,3) = img2_scaled .* img2_ch_color(3);

  color_img1 = uint16(zeros(x_res,y_res));
  color_img1(:,:,1) = img1_scaled .* img1_ch_color(1);
  color_img1(:,:,2) = img1_scaled .* img1_ch_color(2);
  color_img1(:,:,3) = img1_scaled .* img1_ch_color(3);
  
  composite_img = color_img1 + color_img2;

  % Display original image
  figure('Position',[1 1 2560 1276])
  imshow(composite_img,[]);
  set(gca,'Ydir','normal')
  hold on

  % Display color overlay (img2)
  seg2_perim = imdilate(bwperim(seg2),strel('disk',1));
  seg2_rgb = label2rgb(uint32(seg2_perim), img2_perim_color, [1 1 1], 'shuffle');
  himage = imshow(im2uint8(seg2_rgb),[]);
  himage.AlphaData = seg2_perim*.6;

  % Display color overlay (img1)
  if any_objects
    seg1_perim = imdilate(bwperim(seg1),strel('disk',1));
    if ismember('Trace', ObjectsInFrame.Properties.VariableNames)
      cmap = [0 0 0; 0 0 0; ObjectsInFrame.TraceColor]; % weird working cmap for traces
      all_trace_ids_short= ObjectsInFrame.TraceShort;
      seg1_perim=bwlabel(seg1_perim);
      seg1 = seg1+2; % weird working cmap for traces
      seg1(seg1==2)=0; % weird working cmap for traces
      seg1(seg1_perim==0)=0; % weird working cmap for traces
      seg1(1)=1;
      seg1_rgb = label2rgb(seg1, cmap, [1 1 1]); % Coloured by TraceID
    else
      seg1_rgb = label2rgb(uint32(seg1_perim), [1 1 1], [1 1 1], 'shuffle'); % Coloured white
    end
    himage = imshow(im2uint8(seg1_rgb),[]);
    himage.AlphaData = logical(seg1)*1;

    % Display distance lines
    quiver(start_points(1, :), start_points(2, :), end_points(1,:) - start_points(1, :), end_points(2, :) - start_points(2, :), 0, 'c');

    %% Display amount of distances as text
    h = text(start_points(1,:)'+3,start_points(2,:)'-1,cellstr(num2str(round(Distances'))),'Color','cyan','FontSize',12,'Clipping','on','Interpreter','none');

    %% Display trace ID
    for i=1:height(ObjectsInFrame)
      h = text(start_points(1,i)'-13,start_points(2,i)'-1,all_trace_ids_short{i},'Color',ObjectsInFrame.TraceColor(i,:),'FontSize',12,'Clipping','on','Interpreter','none');
    end
  end

  % Information Box
  txt = sprintf('Slice: %s\nimg1xisomes Count: %d\nConvex Area: %.0f px\n%s',USE_SLICE,length(start_points), ConvexAreaPX,stack_name); % '%.1f um^2',ConvexAreaSqrUM
  h = text(10,y_res-45,txt,'Color','white','FontSize',12,'Clipping','on','HorizontalAlignment','left','Interpreter','none');

  frame_txt = sprintf('Frame: %d', tid);
  t_val = 5.203*(tid-1);
  t_unit = 's';
  txt = sprintf('+%.3f %s\n%s', t_val, t_unit, frame_txt);
  h = text(10,30,txt,'Color','white','FontSize',16,'Clipping','on','HorizontalAlignment','left','Interpreter','none');

end