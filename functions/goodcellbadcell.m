function goodcellbadcell(src,event)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Justin Sing
% Maintainer: Justin Sing
% Modified: July 31, 2019
%
% Description:
%
% Function callback for Keyboard input for annotating good cell segmentation 
% vs bad cell segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

keypress = event.Key;
set(src, 'UserData', event.Key)
if keypress == 'g'
    disp('Note: You have annotated the current image as a GOOD segmented cell/image!')
elseif keypress =='b'
    disp('Note: You have annotated the current image as a BAD segmented cell/image!')
else
    disp(['You did not enter a correct keystroke for annotation!!\n You entered: ', keypress, '... Ignoring this...\n Options are: "g" or "b"'])
end
end

