%{
This function counts the number of sub-segments/child objects that are within
a primary-segment/parent object.
The Following function takes in two arguments:
1. primary_seg - The main parent segment
2. sub_seg - Child segments within the parent segment
%}
function MeasureTable = subsegments_count(plugin_name, plugin_num, primary_seg, sub_seg)

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
    tmp=unique(p);
    single_cell_ID=tmp(unique(p)~=0);
    
    for sub_field = fields(sub_seg)'
        disp(['Current Count Object:' char(prim_field) '_Sub' char(sub_field) '_ObjectCount' ])
        s = sub_seg.(char(sub_field));
%         unique(s)
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


TESTING="NO";
if TESTING=="YES"
    test=primary_seg.Cell;
    sub_stuff = sub_seg.NukeSpots;
    figure(5);imshow(test)
    figure(6);imshow(sub_stuff)
    figure(7);imshow(test | sub_stuff)
    
    image1 = bwperim(test);
    figure(8);imshow(image1)
    image2 = sub_stuff;
    figure(9);imshow(image2)
    image4 = image1 | image2;
    figure(10);imshow(image4)
    
    [B,L,N,A] = bwboundaries(image4);
    figure(100);hold on;
    pause()
    % Loop through object boundaries
    for k = 1:N
        % Boundary k is the parent of a hole if the k-th column
        % of the adjacency matrix A contains a non-zero element
        disp("Parent Object")
        if (nnz(A(:,k)) > 0)
            % Boundary of parent object
            boundary = B{k};
            plot(boundary(:,2),...
                boundary(:,1),'r','LineWidth',2);
            % Loop through the children of boundary k
            for l = find(A(:,k))'
                disp("Child Object For-Loop")
                % Boundary of child object
                boundary = B{l};
                
                plot(boundary(:,2),...
                    boundary(:,1),'g','LineWidth',2);
            end
            
        end
        pause()
    end
    hold off;
end
end