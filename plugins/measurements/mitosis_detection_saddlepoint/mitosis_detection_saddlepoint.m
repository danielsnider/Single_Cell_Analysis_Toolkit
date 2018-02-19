function MeasureTable=func(plugin_name, plugin_num, segments, imgs)

  MeasureTable = table();

  % Nothing to do if no segments are given
  if isempty(segments)
    return;
  end
  seg_names = fields(segments);

  % Get channel names if there are any
  if ~isempty(imgs)
    chan_names = fields(imgs);
  end

  % Loop over segments
  for seg_num=1:length(segments)
    seg_name = seg_names{seg_num};
    seg_data = segments.(seg_name);

    % Loop over channels
    for chan_num=1:length(chan_names)
      chan_name = chan_names{chan_num};
      chan_data = imgs.(chan_name);

      [fx,fy]=imgradient(imgaussfilt(chan_data,2));
      [fxx,fxy]=gradient(fx);
      [fyx,fyy]=gradient(fy);
      D=fyy.*fxx-fxy.*fyx;

      SaddlePointImage=imgaussfilt(D,10);
      SaddlePointImageNormalized = normalize0to1(SaddlePointImage);
      stats=regionprops(seg_data,SaddlePointImageNormalized,'area','MeanIntensity','Centroid');
      NumberOfCells = max(seg_data(:));
      SaddlePoint = zeros(1,NumberOfCells)'; 
      Centroid_=cat(1,stats.Centroid);

      for n=1:size(Centroid_,1)
        x = round(Centroid_(n,1));
        y = round(Centroid_(n,2));
        value = SaddlePointImage(y,x);
        SaddlePoint(n:NumberOfCells,1)=round(value,2);
      end

      % Store
      MeasureTable{:,[seg_name '_' chan_name '_SaddlePointMitosis']}=SaddlePoint;

    end
  end


      % saddleOverlayImage = SaddlePointImage;
  %% Visualization
  % Centroid_=cat(1,stats.Centroid);
  % cyt = O.Original_IM{1};
  % saddleOverlayImage = SaddlePointImage;
  % for a=1:2
  %     nuc = O.Original_IM{3};
  %     if a==1
  %         figTitle = 'Saddle Point Metric';
  %     else
  %         figTitle = 'Cell Symmetry Metric';
  %     end 
      
  %     for n=1:size(Centroid_,1)
          
  %         x = round(Centroid_(n,1));
  %         y = round(Centroid_(n,2));
          
  %         if a==1
  %             value = SaddlePointImage(y,x); 
  %             SaddlePoint(n:NumberOfCells,1)=round(value,2);
  %         else
  %             value = abs(CellSymmetryImage(y,x));
  %             CellSymmetry(n:NumberOfCells,1)=round(value,2);
  %         end
          
  %         value = sprintf('%.2f', value);
  %         text = text2im(value);
  %         text = text.*double(max(nuc(:)));
  %         [sizeY,sizeX] = size(text);
         
  %         if x+1>=size(nuc,1)
  %             nuc(y:sizeY+y-1,x-sizeX:x-1)=text;
  %         else
  %             nuc(y:sizeY+y-1,x:sizeX+x-1)=text;
  %         end
          
  %     end
      
  %     figure
  %     imshow(nuc, [])
  %     title(figTitle);
  %     hold on
  %     plot(Centroid_(:,1),Centroid_(:,2),'.r')
  % end



  % figure
  % imshow(cyt, [])
  % hold on
  % plot(Centroid_(:,1),Centroid_(:,2),'.r')

  % figure
  % imshow(saddleOverlayImage, [])
  % hold on
  % plot(Centroid_(:,1),Centroid_(:,2),'.r')
   
   % pause;

  % close all;


end