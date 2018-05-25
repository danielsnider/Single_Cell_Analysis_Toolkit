function fun(plugin_name, plugin_num, Distances, seg1, img1, seg2, img2, start_points, end_points, zslice_num, font_size, ObjectsInFrame)
  Distances = Distances.data;
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
  timepoint = unique(ObjectsInFrame.timepoint);

  % This plugin visualizes only 2D so take only one slice from our 3D stacks
  img1 = img1(:,:,zslice_num);
  seg1 = bwlabel(seg1(:,:,zslice_num));
  img2 = img2(:,:,zslice_num);
  seg2 = seg2(:,:,zslice_num);
  
  % Keep only the arrow start point that are for objects that can be seen
  % in this slice 
  keepers = unique(seg1(:));
  keepers(keepers==0)=[]; % remove zeros
  start_points = start_points(keepers,1:2);
  end_points = end_points(keepers,1:2);
  ObjectsInFrame = ObjectsInFrame(keepers,:);
  Distances = Distances(keepers);
  any_objects = ~isempty(Distances);

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
    quiver(start_points(:,1), start_points(:,2), end_points(:,1) - start_points(:,1), end_points(:,2) - start_points(:,2), 0, 'c');

    %% Display amount of distances as text
    h = text(start_points(:,1)'+3,start_points(:,2)'-1,cellstr(num2str(round(Distances)))','Color','cyan','FontSize',font_size,'Clipping','on','Interpreter','none');

    %% Display trace ID
    for i=1:height(ObjectsInFrame)
      h = text(start_points(i,1)'-10,start_points(i,2)'-1,all_trace_ids_short{i},'Color',ObjectsInFrame.TraceColor(i,:),'FontSize',font_size,'Clipping','on','Interpreter','none','HorizontalAlignment','right');
    end
  end

  % Information Box
  %txt = sprintf('Slice: %s\nPeroxisomes Count: %d\nConvex Area: %.0f px\n%s',USE_SLICE,length(start_points), ConvexAreaPX,stack_name); % '%.1f um^2',ConvexAreaSqrUM
  slice_txt = sprintf('Slice: %d',zslice_num);
  %h = text(15,y_res-45,txt,'Color','white','FontSize',font_size,'Clipping','on','HorizontalAlignment','left','Interpreter','none');
  % Frame Info
  frame_txt = sprintf('Timepoint: %d', timepoint);
  t_val = 5.203*(timepoint-1);
  t_unit = 's';
  txt = sprintf('+%.3f %s\n%s\n%s', t_val, t_unit, frame_txt, slice_txt);
  h = text(20,20,txt,'Color','white','FontSize',font_size+4,'Clipping','on','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');

end