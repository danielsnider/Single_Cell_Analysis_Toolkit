function MeasureTable=func(plugin_name, plugin_num, seg_from, seg_to, measure_from_place)
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
  seg_from = seg_from.(seg_from_name); % expecting only a matrix of the segmented objects

  seg_to_name = fields(seg_to);
  seg_to_name = seg_to_name{1}; % expecting only one segment as defined by the plugin definition
  seg_to = seg_to.(seg_to_name); % expecting only a matrix of the segmented objects

  % Check if there are any objects, return if not
  if max(seg_from(:))==0
    return
  end
  if max(seg_to(:))==0
    Distances = ones(max(seg_from(:)),1)*Inf;
    MeasureTable{:,['Distance_' matlab.lang.makeValidName(seg_from_name) '_to_' matlab.lang.makeValidName(seg_to_name)]}=Distances';
    % TODO: Add these measures with NaN values
    % MeasureTable{:,['Nearest_' matlab.lang.makeValidName(seg_to_name) '_Point']}=ToLocationsXY;
    % MeasureTable{:,[matlab.lang.makeValidName(seg_from_name) '_Centroid']}=FromCentroidsXY;
    return
  end

  %% Get X Y Locations (To Seg)
  [Y X] = find(seg_to);
  ToLocationsXY = [X Y];
  %% Calc X Y Centroids (From Seg)
  from_stats = regionprops(bwlabel(seg_from),'Centroid');
  if length(from_stats)
    FromCentroidsXY = round(cat(1,from_stats.Centroid));
    FromCentroidsXYInd = sub2ind(size(seg_from), FromCentroidsXY(:,2),FromCentroidsXY(:,1));
    
    %% Calc Distance to Nearest To from From
    FromCentroidsXY = FromCentroidsXY';
    ToLocationsXY = ToLocationsXY';
    NearestToInd = nearestneighbour(FromCentroidsXY, ToLocationsXY);
    TranslationX = ToLocationsXY(1,NearestToInd) - FromCentroidsXY(1, :);
    TranslationY = ToLocationsXY(2, NearestToInd) - FromCentroidsXY(2, :);
    NearestToLocationXY = [ToLocationsXY(1,NearestToInd); ToLocationsXY(2, NearestToInd)]';
    [theta,rho] = cart2pol(TranslationX,TranslationY);
    Distances = rho;

    if strcmp(lower(measure_from_place),'edge')
      %% Measure not from center but edge
      % This could be done with linear algebra
      from_boundaries = regionprops(bwlabel(bwperim(seg_from)),'Image');
      for idx=1:length(from_boundaries)
        from_boundary = from_boundaries(idx).Image;
        [Y,X]=find(from_boundary);
        % Find 
        X2=X-size(from_boundary,2)/2-0.5;
        Y2=Y-size(from_boundary,1)/2-0.5;
        this_segment_theta = theta(idx);
        [theta_,rho_] = cart2pol(X2,Y2);
        [min_val, min_idx] = min(abs(theta_-this_segment_theta));
        Distances(idx) = Distances(idx) - rho_(min_idx);
      end
      Distances(Distances<0)=0;
    end
  end

  MeasureTable{:,['Distance_' matlab.lang.makeValidName(seg_from_name) '_to_' matlab.lang.makeValidName(seg_to_name)]}=Distances'; % Scalar
  MeasureTable{:,['Nearest_' matlab.lang.makeValidName(seg_to_name) '_Point']}=NearestToLocationXY;
  MeasureTable{:,[matlab.lang.makeValidName(seg_from_name) '_Centroid']}=FromCentroidsXY';

end