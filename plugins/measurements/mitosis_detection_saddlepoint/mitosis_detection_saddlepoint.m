function [T]=Collecting_Morphological_Data(O,BW,NumberOfCells)

Nucleus_ch=find(cell2mat(strfind(O.General_Thresholds.Label,'Nucleus')));
Cell_ch=find(cell2mat(strfind(O.General_Thresholds.Label,'Cell')));
Total_num_of_cells=max(O.BW{Cell_ch}(:));

[fx,fy]=gradient(imgaussfilt(O.IM{Cell_ch},2));
[fxx,fxy]=gradient(fx);
[fyx,fyy]=gradient(fy);
D=fyy.*fxx-fxy.*fyx;

CellSymmetryImage=imgaussfilt(fxx-fyy,10);
SaddlePointImage=imgaussfilt(D,10);
SaddlePointImageNormalized = normalize0to1(SaddlePointImage);
stats=regionprops(O.BW{Nucleus_ch},SaddlePointImageNormalized,'area','MeanIntensity','Centroid');

NumberOfCells = max(O.BW{Nucleus_ch}(:));
SaddlePoint = zeros(1,NumberOfCells)'; 
CellSymmetry = zeros(1,NumberOfCells)'; 


Centroid_=cat(1,stats.Centroid);
cyt = O.Original_IM{1};
saddleOverlayImage = SaddlePointImage;
for a=1:2
    for n=1:size(Centroid_,1)
        x = round(Centroid_(n,1));
        y = round(Centroid_(n,2));
        if a==1
            value = SaddlePointImage(y,x); 
            SaddlePoint(n:NumberOfCells,1)=round(value,2);
        else
            value = abs(CellSymmetryImage(y,x));
            CellSymmetry(n:NumberOfCells,1)=round(value,2);
        end
    end
end

T = table(SaddlePoint,CellSymmetry);

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


