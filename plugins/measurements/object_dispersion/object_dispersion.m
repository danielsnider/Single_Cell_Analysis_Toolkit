function MeasureTable = subsegments_count(plugin_name, plugin_num, primary_seg, sub_seg, debug_level)

  MeasureTable = table();

  % Nothing to do if no segments are given
  if isempty(primary_seg)
      return;
  end

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  primary_seg_name = fields(primary_seg);
  primary_seg_name = primary_seg_name{1}; % expecting only one segment as defined by the plugin definition
  primary_seg = primary_seg.(primary_seg_name); % expecting only a matrix of the segmented objects

  % Pull out segment data from struct. Example struct could be 'seg.Pero = [1024 x 1360 x 5]'
  sub_seg_name = fields(sub_seg);
  sub_seg_name = sub_seg_name{1}; % expecting only one segment as defined by the plugin definition
  sub_seg = sub_seg.(sub_seg_name); % expecting only a matrix of the segmented objects

  % Check if there are any objects, return if not
  if max(primary_seg(:))==0
    return
  end

  composite_seg = logical(bwperim(primary_seg)) | logical(sub_seg);
  bwdist_seg = bwdist(composite_seg);
  % figure; imshow(composite_seg)
  % figure; imshow(bwdist_seg)


  stats = regionprops('table',primary_seg,bwdist_seg,'Area','MeanIntensity');
  total_bwdist = stats.Area .* stats.MeanIntensity;
  total_bwdist_norm_by_area = total_bwdist ./ stats.Area ;
  mean_bwdist_norm_by_area = stats.MeanIntensity ./ stats.Area ;

  % Draw Density Heat Map
  if ismember(debug_level,{'On'})
    f = figure(4416); clf; set(f,'name','object_dispersion','NumberTitle', 'off');
    bwdist_seg2=bwdist_seg;
    bwdist_seg2(primary_seg==0)=-2;
    bwdist_seg2(sub_seg>0)=-2;
    cmap = fliplr(jet);
    cmap(1,:) = [0 0 0]
    h1 = imshow(bwdist_seg2,[])
    colormap(gca,cmap)
    hold on
    
    cen = regionprops('table',primary_seg,'Centroid');
    for idx=1:max(primary_seg(:))
      txt = sprintf('total_bwdist=%.2g\ntotal_bwdist_norm_by_area=%.2g\nmean_bwdist_norm_by_area=%.2g',total_bwdist(idx), total_bwdist_norm_by_area(idx), mean_bwdist_norm_by_area(idx));
      text(cen.Centroid(idx,1),cen.Centroid(idx,2),txt,'Color','white','Clipping','on','Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle');
    end
  end

  MeasureTable{:,['Dispersion_' matlab.lang.makeValidName(sub_seg_name) '_in_' matlab.lang.makeValidName(primary_seg_name) '_total_bwdist']}=total_bwdist;
  MeasureTable{:,['Dispersion_' matlab.lang.makeValidName(sub_seg_name) '_in_' matlab.lang.makeValidName(primary_seg_name) '_total_bwdist_norm_by_area']}=total_bwdist_norm_by_area;
  MeasureTable{:,['Dispersion_' matlab.lang.makeValidName(sub_seg_name) '_in_' matlab.lang.makeValidName(primary_seg_name) '_mean_bwdist_norm_by_area']}=mean_bwdist_norm_by_area;

end