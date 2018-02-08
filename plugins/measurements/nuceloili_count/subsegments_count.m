%{
This function counts the number of sub-segments/child objects that are within 
a primary-segment/parent object.
The Following function takes in two arguments: 
1. primary_seg - The main parent segment
2. sub_seg - Child segments within the parent segment
%}
function MeasureTable = subsegments_count(primary_seg, sub_seg)

MeasureTable = table();

% Nothing to do if no segments are given
if isempty(primary_seg)
    return;
end
if isempty(sub_seg)
    return;
end

for prim_field = fields(primary_seg)'
    
   p = primary_seg.(char(prim_field));
   single_cell_ID=unique(p);
      
   for sub_field = fields(sub_seg)'
       disp(['Current Count Object:' char(prim_field) '_Sub' char(sub_field) '_ObjectCount' ])
       s = sub_seg.(char(sub_field));
       unique(s)
       list_idx=1;
       for i = single_cell_ID'          
           single_subsegment=s;
           single_subsegment(p~=i)=0;
           single_subsegment=bwlabel(single_subsegment);        
           MeasureTable{list_idx,[char(prim_field) '_Sub' char(sub_field) '_ObjectCount' ]}=max(single_subsegment(:));
           list_idx=list_idx+1;
       end       
   end
end
end