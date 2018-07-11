function moveitem(hlist,increment)
% %         % Get the existing items and the current item
% %         items = get(hlist, 'string');
% %         current = get(hlist, 'value');

        % Get the existing items and the current item
        items = get(hlist, 'items');
        current = get(hlist, 'value');
        
        %get index of selected values
        [~, index] = ismember(current, items);

        toswap = index - increment;

        % Ensure that we aren't already at the top/bottom
        if toswap < 1 || toswap > numel(items)
            return
        end

        % Swap the two entries that need to be swapped
        inds = [index, toswap];
        items(inds) = flipud(items(inds)')';

        % Update the order and the selected item
%         set(hlist, 'string', items);
%         set(hlist, 'value', toswap)
        set(hlist, 'items', items)
        set(hlist, 'value', current)
    end