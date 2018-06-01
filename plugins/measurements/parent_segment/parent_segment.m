function MeasureTable = func(plugin_name, plugin_num, primary_seg, sub_seg)
  MeasureTable = table();

  % Nothing to do if no segments are given
  if isempty(primary_seg)
      return;
  end
  if isempty(sub_seg)
      return;
  end

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  sub_seg_name = fields(sub_seg);
  sub_seg_name = sub_seg_name{1}; % expecting only one segment as defined by the plugin definition
  sub_seg = sub_seg.(sub_seg_name); % expecting only a matrix of the segmented objects

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  primary_seg_name = fields(primary_seg);
  primary_seg_name = primary_seg_name{1}; % expecting only one segment as defined by the plugin definition
  primary_seg = primary_seg.(primary_seg_name); % expecting only a matrix of the segmented objects

  is_3D = false;
  if ndims(primary_seg) == 3
    is_3D = true;
  end

  % Get centroid locations of subsegments in linear index form
  if is_3D
    sub_seg_stats = regionprops3(bwlabeln(sub_seg),'Centroid');
  else
    sub_seg_stats = regionprops('table',bwlabel(sub_seg),'Centroid');
  end
  sub_seg_centroid_x = round(sub_seg_stats.Centroid(:,2));
  sub_seg_centroid_y = round(sub_seg_stats.Centroid(:,1));
  if is_3D
    sub_seg_centroid_z = floor(sub_seg_stats.Centroid(:,3));
    sub_seg_centroid_indices = sub2ind(size(sub_seg), sub_seg_centroid_x, sub_seg_centroid_y, sub_seg_centroid_z);
  else
    sub_seg_centroid_indices = sub2ind(size(sub_seg), sub_seg_centroid_x, sub_seg_centroid_y);
  end

  % Get parent ids using centriods
  parent_ids = primary_seg(sub_seg_centroid_indices);

  % Convert IDs (1,2,3,etc) to UUIDs
  parent_UUIDs = {};
  % loop over each unique parent id, saving a UUID for each occurance of it
  for id=unique(parent_ids)'
    uuid_str = uuid();
    if id==0
      % zero means that no parent was found so store 'None'
      uuid_str='None';
    end
    locs = find(parent_ids==id); % find the objects with this parent id
    uuid_array = cell(length(locs),1); % make a cell with the length of how many of this parent id there are
    uuid_array(:) = {uuid_str};
    parent_UUIDs(locs)=uuid_array;
  end

  % Save Output
  MeasureTable.([primary_seg_name '_Num']) = parent_ids;
  MeasureTable.([primary_seg_name '_UUID']) = parent_UUIDs';
end