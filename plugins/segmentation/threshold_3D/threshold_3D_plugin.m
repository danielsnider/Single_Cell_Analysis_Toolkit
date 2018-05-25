function result = fun(plugin_name, plugin_num, img, smooth_param, thresh_param, min_area, max_area, z_res_multiplier, debug_level)
    
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
    imshow3D(img_smooth,[]);
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
    img_thresh = img_smooth > thresh_param;
  end
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow3D(img_thresh,[]);
  end
  
  % Remove objects that are too small or too large
  labelled_img = bwlabeln(img_thresh);
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;
  img_thresh = labelled_img > 0;
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','obj size threshold','NumberTitle', 'off');
    imshow3D(img_thresh,[]);
  end

  %% Calculate 3D shape
  XYZ = [];
  all_faces = {};
  all_vertices = {};
  z_depth = size(img,3);
  fig_3d = figure(9762); clf; set(fig_3d,'name','3D','NumberTitle', 'off');
  hold on
  % Render 2D Slices. Needed because 3D render makes a single 2D slice disappear
  for zid=1:z_depth
    % Collect 3D points into XYZ for later 3D rendering
    [Y X] = find(img_thresh(:,:,zid));
    Z = zeros(length(X),1)+zid;
    if isempty(Z)
      continue
    end
    XYZ = [XYZ; X Y Z];

    % Draw 2D slice
    shp2d = alphaShape(X,Y); % the default behaviour of a 2d render with alphaShape is to draw green slices at z=0, the next line disables this
    h2d = plot(shp2d); % hide the green 2d slices
    h2d.Visible='off';
    faces = h2d.Faces;
    vertices = [h2d.Vertices Z .* z_res_multiplier]; % we created a two 2D but want to put it in 3D and scale it up by how many times larger is one discrete step in the Z dimension than one step in the X dimension.
    p = patch('Faces',faces,'Vertices',vertices);
    p.FaceColor = 'red';
    p.EdgeColor = 'none';

    all_faces{zid} = faces;
    all_vertices{zid} = vertices;
  end

  if ~isempty(XYZ)
    % Render 3D mito
    shp = alphaShape(XYZ,4);
    h = plot(shp);
    h.FaceColor = 'red';
    h.EdgeColor = 'none';
    h.Vertices(:,3) = h.Vertices(:,3) .* z_res_multiplier; % z depth scale factor. How many times larger is one discrete step in the Z dimension than one step in the X dimension.
    all_faces{zid+1} = h.Faces;
    all_vertices{zid+1} = h.Vertices;
  end

  if ismember(debug_level,{'All','Result Only'})
    axis tight
    view(3)
    rotate3d on
    axis vis3d % disable strech-to-fill
    set(gca, 'color','none')
    set(gcf, 'color',[1 1 1])
    camlight 
    lighting gouraud
    h.AmbientStrength = 0.3;
    h.DiffuseStrength = 0.8;
    h.SpecularStrength = 0.9;
    h.SpecularExponent = 25;
  else
    delete(fig_3d);
  end

  % Return result
  result = {};
  result.matrix = labelled_img;
  result.faces = all_faces;
  result.vertices = all_vertices;

  % Debug segmentation with color overlay
  if ismember(debug_level,{'All','Result Only'})
    num_objects = max(labelled_img(:));
    max_intensity = max(img(:));
    %colors = get_n_length_colormap('hsv',num_objects,'shuffle');
    colors = [1 0 0];
    seg_colored_img = cat(4, img, img, img);

    % Make perimeter image
    perim_labelled_img = [];
    for zid = 1:size(labelled_img,3)
      perim_labelled_img(:,:,zid) = bwperim(labelled_img(:,:,zid));
    end
    % perim_labelled_img = perim_labelled_img .* labelled_img; % reapply labels

    % Burn in color segmentation lines
    for idx=1:num_objects
      object = perim_labelled_img == idx;
      seg_colored_img(find(object)) = colors(1) * max_intensity;
      seg_colored_img(find(object)+size(img,1)*size(img,2)*size(img,3)) = colors(2) * max_intensity;
      seg_colored_img(find(object)+size(img,1)*size(img,2)*size(img,3)*2) = colors(3) * max_intensity;
    end

    % Display
    f = figure(7409); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    if max(seg_colored_img(:)) > 255
        imshow3D(uint16(seg_colored_img),[])
    else
        imshow3D(uint8(seg_colored_img),[])
    end
  end

end