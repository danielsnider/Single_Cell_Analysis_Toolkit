function fun(plugin_name, plugin_num, Distances, seg1, img1, seg2, img2, start_points, end_points, dist_font_size, id_font_size, color_by_tracking_ids, ObjectsInFrame)

  if isstruct(seg1)
    seg1 = seg1.data;
  end

  if isstruct(seg2)
    seg2 = seg2.data;
  end


  Distances = ObjectsInFrame.(Distances.name);
  start_points = ObjectsInFrame.(start_points.name);
  end_points = ObjectsInFrame.(end_points.name);
  num_chans = 2;
  timepoint = unique(ObjectsInFrame.timepoint);
  any_objects = ~isempty(Distances);
  num_3D_chans = length(seg2.faces); % there is a 2D slice for each z slice and a 3d volume that misses pure 2d slices
  EquivDiameter_col_name = ObjectsInFrame.Properties.VariableNames{find(contains(ObjectsInFrame.Properties.VariableNames,'EquivDiameter'))};

  if ~any_objects
    return
  end

  % Create figure
  f = figure(plugin_num+9222); clf; set(f,'name',plugin_name,'NumberTitle', 'off');
  hold on
  
  % Render 3D "to" objects
  for idx = 1:num_3D_chans
    faces = seg2.faces{idx};
    vertices = seg2.vertices{idx};
    p = patch('Faces',faces,'Vertices',vertices);
    p.FaceColor = 'red';
    p.EdgeColor = 'none';
  end

  %% Plot each "from" object one at a time 
  for idx=1:height(ObjectsInFrame)
    % Draw scatter points instead of rendering with surfaces
    cent_x = start_points(idx,1);
    cent_y = start_points(idx,2);
    cent_z = start_points(idx,3);
    diameter = ObjectsInFrame{idx, EquivDiameter_col_name};

    if color_by_tracking_ids && any(ismember(ObjectsInFrame.Properties.VariableNames,'TraceColor'))
      scatter3(cent_x, cent_y, cent_z, diameter*10,ObjectsInFrame.TraceColor(idx,:),'filled')
    else
      scatter3(cent_x, cent_y, cent_z, diameter*10,'green','filled')
    end
  end

  % Plot distance lines
  plot3M = @(XYZ,varargin) plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),varargin{:});
  plot3M(reshape([shiftdim(start_points,-1);shiftdim(end_points,-1);shiftdim(start_points,-1)*NaN],[],3),'k')

  % Style
  axis equal
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

  %% Display amount of distances as text
  h = text(start_points(:,1)'+20,start_points(:,2)'-20,start_points(:,3)',cellstr(num2str(round(Distances))),'Color','cyan','FontSize',dist_font_size,'Clipping','on','Interpreter','none','HorizontalAlignment','center');

  %% Display trace ID
  if ~isequal(id_font_size, false) && any(ismember(ObjectsInFrame.Properties.VariableNames,'TraceShort')) && any(ismember(ObjectsInFrame.Properties.VariableNames,'TraceColor'))
    for i=1:height(ObjectsInFrame)
      h = text(start_points(i,1)'-20,start_points(i,2)'+20,start_points(i,3)',ObjectsInFrame.TraceShort(i,:),'Color',ObjectsInFrame.TraceColor(i,:),'FontSize',id_font_size,'Clipping','on','Interpreter','none','HorizontalAlignment','center');
    end
  end

  % Information Box
  frame_txt = sprintf('Timepoint: %d', timepoint);
  dim = [.67 .67 .1 .1]; % four-element vector of the form [x y w h]
  annotation('textbox',dim,'String',frame_txt)

end