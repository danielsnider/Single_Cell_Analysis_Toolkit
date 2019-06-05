function MeasureTable=func(plugin_name, plugin_num, seg_from, seg_to, measure_from_place, z_res_multiplier)
  MeasureTable = table();

  % Nothing to do if no segments are given
  if isempty(seg_from)
    return;
  end
  if isempty(seg_to)
    return;
  end

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  seg_from_name = fields(seg_from);
  seg_from_name = seg_from_name{1}; % expecting only one segment as defined by the plugin definition
  from_matrix = seg_from.(seg_from_name).matrix; % expecting only a matrix of the segmented objects

  % Check if there are any objects, return if not
  if max(from_matrix(:))==0
    return
  end

  % Pull out segment data from struct. Example struct could be 'seg.Pero =   struct with fields:
      %   matrix: [1024×1024×5 double]
      %    faces: {[115014×3 double]  [103044×3 double]  [109009×3 double]  [87644×3 double]  [68396×3 double]  [283104×3 double]}
      % vertices: {[57940×3 double]  [53421×3 double]  [59312×3 double]  [45550×3 double]  [34391×3 double]  [141649×3 double]}'
  seg_to_name = fields(seg_to);
  seg_to_name = seg_to_name{1}; % expecting only one segment as defined by the plugin definition
  seg_to = seg_to.(seg_to_name);


  if ~isfield(seg_to,'faces') | ~isfield(seg_to,'vertices')
    title_ = 'User Input Error';
    msg = sprintf('User caused an error in ''%s'' plugin. The input segment ''%s'' that the user has chosen is not in the correct 3D format. Please double check the algorithm choice in the settings for the ''%s'' segment. Nothing to do.', plugin_name, seg_to_name, seg_to_name);
    f = errordlg(msg,title_);
    err = MException('PLUGIN:input_error_3D',msg);
    throw(err);
  end

  to_matrix = seg_to.matrix; % expecting this to be available
  to_faces = seg_to.faces; % expecting this to be available 
  to_vertices = seg_to.vertices; % expecting this to be available

  %% Do distance measurement
  % Get centers of from objects
  from_stats = regionprops3(from_matrix, 'Centroid', 'Volume', 'EquivDiameter');
  from_stats(from_stats.Volume==0, :) = [];
  from_stats.Centroid(:,3) = from_stats.Centroid(:,3) .* z_res_multiplier;  % z depth scale factor. How many times larger is one discrete step in the Z dimension than one step in the X dimension.
  points = from_stats.Centroid;
  % points = points(54:60,:); % limit pero for debugging
  
  %% Do distance measurements
  % NOTE: There are 6 distance types, the closest mito could be found in a 2D slice or the 3D render, because...
  % NOTE: We had to measure each 2D slice and the 3D render seperately because I couldn't find a way to make them all one 3D object that could be measured by point2trimesh.
  % Example:
  % all_distances =
  %                z=1           z=2          z=3          z=4            z=5        3D     <----- Distance to nearest mito in z=1,2,3,4,5 or 3D
  % Pero 1        14.137      -13.609          -26      -39.002            0       13.609
  % Pero 2        22.876       -20.52      -29.065      -40.768            0        20.52
  % Pero 3        88.551      -86.332      -86.129      -91.243            0        86.03
  all_distances = []; % distance to each 
  all_surface_points = [];
  for i=1:length(to_vertices)
    try
      FV.faces = to_faces{i};
      FV.vertices = to_vertices{i};
      if isempty(FV.faces)
        all_distances(:,i) = NaN;
        all_surface_points(:,:,i) = NaN;
        continue
      end
      [distances,surface_points] = point2trimesh(FV, 'QueryPoints', points);
      all_distances(:,i) = abs(distances);
      all_surface_points(:,:,i) = surface_points;
    catch ME
      error_msg = getReport(ME,'extended','hyperlinks','off');
      disp('[NOTE] Unhandled error in distance_3D_plugin');
      disp(error_msg);
      disp('[NOTE] Continuing...!');
      continue
    end
  end

  if ~isempty(all_surface_points)
    % Get lowest distances
    [min_dist,min_dist_type_id]=min(all_distances');
    Distances = min_dist;

    % Get the correct surface points (there are multiple types 2D z=1,z=2,3D)
    surface_points = [];
    for pid=1:size(points,1)
      try
        surface_points(pid,:) = all_surface_points(pid,:,min_dist_type_id(pid));
      catch ME
        error_msg = getReport(ME,'extended','hyperlinks','off');
        disp('[NOTE] Unhandled error in distance_3D_plugin');
        disp(error_msg);
        disp('[NOTE] Continuing...!');
        continue
      end
    end

    if strcmp(lower(measure_from_place),'edge')
      Distances = Distances - from_stats.EquivDiameter' ./ 2;
      Distances(Distances<0) = 0;
    end
  else
    Distances = zeros(1,length(points));
    Distances(:) = Inf;
    surface_points = points;
    surface_points(:) = NaN;
  end

  % Store
  MeasureTable{:,['Distance_' matlab.lang.makeValidName(seg_from_name) '_to_' matlab.lang.makeValidName(seg_to_name)]}=Distances'; % Scalar
  MeasureTable{:,['Nearest_' matlab.lang.makeValidName(seg_to_name) '_Point']}=surface_points; % XYZ
  MeasureTable{:,[matlab.lang.makeValidName(seg_from_name) '_Centroid']}=points; % XYZ
  MeasureTable{:,[matlab.lang.makeValidName(seg_from_name) '_Volume']}=from_stats.Volume; % Count of the actual number of 'on' voxels in the region.
  MeasureTable{:,[matlab.lang.makeValidName(seg_from_name) '_EquivDiameter']}=from_stats.EquivDiameter; % Diameter of a sphere with the same volume as the region, returned as a scalar. Computed as (6*Volume/pi)^(1/3).

end