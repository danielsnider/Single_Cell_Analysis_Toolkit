function [params, algorithm] = fun()

  algorithm.name = 'Distance Between Objects';
  algorithm.help = 'This plugin computes the 2D euclidean distance from each segment of a given type to a the nearest segment of another type.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Distance From Each';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Distance To Nearest';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Measure From';
  params(n).default = 'Edge';
  params(n).help = 'Control whether distances are measured from the objects center or from the edge of the object''s surface.';
  params(n).type = 'dropdown';
  params(n).options = {'Edge', 'Center'};

end
