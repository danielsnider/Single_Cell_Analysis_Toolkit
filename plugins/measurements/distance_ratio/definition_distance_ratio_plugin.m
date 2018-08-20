function [params, algorithm] = fun()

  algorithm.name = 'Distance Ratio Between Objects';
  algorithm.help = 'This plugin calculates whether objects are closer to type of segment or another. A value of 0 means the object is touching the start point, and a value of 1 means the object is tocuhing the end point. A value of 0.5 means that the object is located half way between the start and end points.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Start Point Type';
  params(n).default = 'Edge';
  params(n).help = 'Control whether distances are measured from the objects center or from the edge of the object''s surface.';
  params(n).type = 'dropdown';
  params(n).options = {'Edge', 'Center'};

  n = n + 1;
  params(n).name = 'Start Point Segment';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Intersect Primary Segment';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'End Point Segment (Edge)';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).default = 'Off';
  params(n).options = {'On','Off'};

end
