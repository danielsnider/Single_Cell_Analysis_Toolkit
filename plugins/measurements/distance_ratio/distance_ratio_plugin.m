function MeasureTable=func(plugin_name, plugin_num, start_point_type, start_seg, intersect_seg, end_seg, debug_level)
  MeasureTable = table();

  % Nothing to do if no segments are given
  if isempty(start_seg)
    return;
  end
  if isempty(intersect_seg)
    return;
  end
  if isempty(end_seg)
    return;
  end

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  start_seg_name = fields(start_seg);
  start_seg_name = start_seg_name{1}; % expecting only one segment as defined by the plugin definition
  start_seg = start_seg.(start_seg_name); % expecting only a matrix of the segmented objects

  intersect_seg_name = fields(intersect_seg);
  intersect_seg_name = intersect_seg_name{1}; % expecting only one segment as defined by the plugin definition
  intersect_seg = intersect_seg.(intersect_seg_name); % expecting only a matrix of the segmented objects

  end_seg_name = fields(end_seg);
  end_seg_name = end_seg_name{1}; % expecting only one segment as defined by the plugin definition
  end_seg = end_seg.(end_seg_name); % expecting only a matrix of the segmented objects

  % Check if there are any objects, return if not
  if max(start_seg(:))==0 || max(intersect_seg(:))==0 || max(end_seg(:))==0
    return
  end

  %% Do distance measurement
  % Get centers of from objects
  from_stats = regionprops3(from_matrix, 'Centroid', 'Volume', 'EquivDiameter');
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
  end

  if ~isempty(all_surface_points)
    % Get lowest distances
    [min_dist,min_dist_type_id]=min(all_distances');
    Distances = min_dist;

    % Get the correct surface points (there are multiple types 2D z=1,z=2,3D)
    surface_points = [];
    for pid=1:size(points,1)
      surface_points(pid,:) = all_surface_points(pid,:,min_dist_type_id(pid));
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