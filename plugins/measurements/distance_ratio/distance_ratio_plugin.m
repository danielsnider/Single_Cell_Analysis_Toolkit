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

  %% Get points in XY format for distance measuruments
  % Get points for measuring distances to start
  if strcmp(start_point_type, 'Edge')
    [Y X] = find(bwperim(start_seg));
    start_pointsXY = [X Y];
  elseif strcmp(start_point_type, 'Center')
    stats = regionprops(start_seg,'Centroid');
    start_pointsXY = round(cat(1,stats.Centroid));
  end
  start_pointsXY = start_pointsXY';
  % Get points for measuring distances to intersect
  stats = regionprops(intersect_seg,'Centroid');
  intersect_pointsXY = round(cat(1,stats.Centroid));
  intersect_pointsXY = intersect_pointsXY';
  % Get points for measuring distances to end
  [Y X] = find(bwperim(end_seg));
  end_pointsXY = [X Y];
  end_pointsXY = end_pointsXY';


  %% Calc Distance to Nearest Start
  NearestStartInd = nearestneighbour(intersect_pointsXY, start_pointsXY);
  TranslationX = start_pointsXY(1,NearestStartInd) - intersect_pointsXY(1, :);
  TranslationY = start_pointsXY(2, NearestStartInd) - intersect_pointsXY(2, :);
  [theta,rho] = cart2pol(TranslationX,TranslationY);
  start_distances = rho;

  % Debug
  if ismember(debug_level,{'On'})
    f = figure(8186); clf; set(f,'name','dist_ratio','NumberTitle', 'off');
    scatter(start_pointsXY(1,:), start_pointsXY(2,:), 'b')
    hold on
    scatter(intersect_pointsXY(1,:), intersect_pointsXY(2,:), 'r')
    quiver(intersect_pointsXY(1, :), intersect_pointsXY(2, :), start_pointsXY(1,NearestStartInd) - intersect_pointsXY(1, :), start_pointsXY(2, NearestStartInd) - intersect_pointsXY(2, :), 0, 'k');
    hold off
    set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
  end

  %% Calc Distance to Nearest End
  NearestEndInd = nearestneighbour(intersect_pointsXY, end_pointsXY);
  TranslationX = end_pointsXY(1,NearestEndInd) - intersect_pointsXY(1, :);
  TranslationY = end_pointsXY(2, NearestEndInd) - intersect_pointsXY(2, :);
  [theta,rho] = cart2pol(TranslationX,TranslationY);
  end_distances = rho;

  % Debug
  if ismember(debug_level,{'On'})
    f = figure(8286); clf; set(f,'name','dist_ratio','NumberTitle', 'off');
    scatter(end_pointsXY(1,:), end_pointsXY(2,:), 'b')
    hold on
    scatter(intersect_pointsXY(1,:), intersect_pointsXY(2,:), 'r')
    quiver(intersect_pointsXY(1, :), intersect_pointsXY(2, :), end_pointsXY(1,NearestEndInd) - intersect_pointsXY(1, :), end_pointsXY(2, NearestEndInd) - intersect_pointsXY(2, :), 0, 'k');
    hold off
    set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
  end

  dist_ratio = start_distances ./ end_distances;

  if ismember(debug_level,{'On'})
    f = figure(8386); clf; set(f,'name','dist_ratio','NumberTitle', 'off');
    % Red Start
    hold on
    red = cat(3, zeros(size(end_seg)), zeros(size(end_seg)), zeros(size(end_seg))); 
    red(:,:,1) = bwperim(end_seg);
    imshow(red,[])

    % Green intersect
    hold on
    green = cat(3, zeros(size(intersect_seg)), zeros(size(intersect_seg)), zeros(size(intersect_seg))); 
    green(:,:,2) = bwperim(intersect_seg);
    h = imshow(green,[])
    set(h, 'AlphaData', bwperim(intersect_seg));

    % Blue End
    hold on
    blue = cat(3, zeros(size(start_seg)), zeros(size(start_seg)), zeros(size(start_seg))); 
    blue(:,:,3) = bwperim(start_seg);
    h = imshow(blue,[])
    set(h, 'AlphaData', bwperim(start_seg));

    % Arrows to nearest points
    % quiver(intersect_pointsXY(1, :), intersect_pointsXY(2, :), start_pointsXY(1,NearestStartInd) - intersect_pointsXY(1, :), start_pointsXY(2, NearestStartInd) - intersect_pointsXY(2, :), 0, 'white');
    % quiver(intersect_pointsXY(1, :), intersect_pointsXY(2, :), end_pointsXY(1,NearestEndInd) - intersect_pointsXY(1, :), end_pointsXY(2, NearestEndInd) - intersect_pointsXY(2, :), 0, 'white');
    for idx=1:size(intersect_pointsXY,2)
      h=plot([intersect_pointsXY(1, idx) start_pointsXY(1,NearestStartInd(idx))], [intersect_pointsXY(2, idx) start_pointsXY(2,NearestStartInd(idx))],'w-');
      h.Color =[1 1 1 .35];
      h=plot([intersect_pointsXY(1, idx) end_pointsXY(1,NearestEndInd(idx))], [intersect_pointsXY(2, idx) end_pointsXY(2,NearestEndInd(idx))],'w-');
      h.Color =[1 1 1 .35];
      h=text(intersect_pointsXY(1, idx), intersect_pointsXY(2, idx), sprintf('%.2f',dist_ratio(idx)),'Color','white');
    end
  end

  % set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');

  % Store
  MeasureTable{:,'Distance_Ratio'}=dist_ratio';
  MeasureTable{:,['Distance_' matlab.lang.makeValidName(intersect_seg_name) '_' start_point_type '_to_' matlab.lang.makeValidName(start_seg_name) '_Edge']}=start_distances';
  MeasureTable{:,['Distance_' matlab.lang.makeValidName(intersect_seg_name) '_' start_point_type '_to_' matlab.lang.makeValidName(end_seg_name) '_Edge']}=end_distances';

end