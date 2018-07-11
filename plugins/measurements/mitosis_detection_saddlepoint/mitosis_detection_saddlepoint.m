function MeasureTable=func(plugin_name, plugin_num, img, seg)

  % Nothing to do if no segments are given
  if isempty(img)
    return;
  end
  if isempty(seg)
    return;
  end
  
  % Pull out image data
  img_name = fields(img);
  img_name = img_name{1}; % expecting only one
  img_data = img.(img_name);
  % Pull out segment data
  seg_name = fields(seg);
  seg_name = seg_name{1}; % expecting only one
  seg_data = bwlabel(seg.(seg_name));

  [fx,fy]=imgradient(imgaussfilt(img_data,2));
  [fxx,fxy]=gradient(fx);
  [fyx,fyy]=gradient(fy);
  D=fyy.*fxx-fxy.*fyx;

  SaddlePointImage=imgaussfilt(D,2.5);
  SaddlePointImageNormalized = normalize0to1(SaddlePointImage);
  stats=regionprops(seg_data,SaddlePointImageNormalized,'area','MeanIntensity','Centroid');
  NumberOfCells = max(seg_data(:));
  SaddlePoint = zeros(1,NumberOfCells)'; 
  Centroid_=cat(1,stats.Centroid);

  for n=1:size(Centroid_,1)
    x = round(Centroid_(n,1));
    y = round(Centroid_(n,2));
    value = SaddlePointImage(y,x);
    SaddlePoint(n)=value;
  end

  % Store
  MeasureTable = table();
  MeasureTable{:,[matlab.lang.makeValidName(seg_name) '_' matlab.lang.makeValidName(img_name) '_SaddlePointMitosis']}=SaddlePoint;

end