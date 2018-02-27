function MeasureTable=func(plugin_name, plugin_num, img, seg)

  % Nothing to do if no segments are given
  if isempty(img)
    return;
  end
  if isempty(seg)
    return;
  end
  
  % Pull out image data from struct. Example struct could be 'img.DAPI = [1024 x 1360]'
  img_name = fields(img);
  img_name = img_name{1}; % expecting only one image as defined by the plugin definition
  img_data = img.(img_name);
  
  % Pull out segment data from struct. Example struct could be 'seg.Nucleus = [1024 x 1360]'
  seg_name = fields(seg);
  seg_name = seg_name{1}; % expecting only one sement as defined by the plugin definition
  seg_data = seg.(seg_name);

  % Do mearument
  stats=regionprops(seg_data,img_data,'MeanIntensity');
  MeanIntensity = cat(1,stats.MeanIntensity);

  % Store
  MeasureTable = table();
  MeasureTable{:,[matlab.lang.makeValidName(seg_name) '_' matlab.lang.makeValidName(img_name) '_MeanIntensity']}=MeanIntensity;

end