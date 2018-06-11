function [params, algorithm] = fun()

  algorithm.name = 'Object Dispersion';
  algorithm.help = 'A measure of how spread out objects are in a parent segment. Calculated as the sum of pixel values after a euclidian distance transform (EDT) of a boolean image of the parent segment and sub-segments combined where true marks the prescence of any segment. A value of 0 indicates that sub-segments are so spread out that they cover the entire parent segment. A high value indicates a lot of distance between the sub-segments to eachother as well as the boundry of the parent segment.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Primary Segments to Measure';
  params(n).default = '';
  params(n).help = 'The primary segment you wish to measure. Also known as the parent segment.';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Dispersion of Sub-Segments';
  params(n).default = '';
  params(n).help = 'The sub-segments to count in primary segment.';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).default = 'Off';
  params(n).options = {'On','Off'};

end
