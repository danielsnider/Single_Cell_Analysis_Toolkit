%%% This function is used to reorder a row-wise vector list, given another
%%% vector list that are vectors contained in the first input vector.


function [reordered_list] = auto_reorderlist(group,list_order)
group = strtrim(group);
reordered_list = cell(size(group));
count = 1;
while any(cellfun('isempty',reordered_list))
    
    for i = 1:size(list_order,1)
        current_item = char(list_order(i));
        boolstr = reshape(dec2bin(current_item, 8).'-'0',1,[]);
        len_boolstr = length(boolstr);
        for k = 1:size(group,1)
            current_group = reshape(dec2bin(char(group(k)), 8).'-'0',1,[]);
            if all((current_group(end-len_boolstr+1:end))==boolstr) && ~any(strcmp(reordered_list,group(k)))
                
                reordered_list(count,1) = group(k);
                count = count + 1;
                break
            end
        end
    end
end