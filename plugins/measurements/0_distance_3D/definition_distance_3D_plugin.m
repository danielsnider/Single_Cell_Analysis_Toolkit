function [params, algorithm] = fun()

  algorithm.name = 'Distance Between Objects';
  algorithm.help = 'This plugin computes the distance from each segment of a given type to a the nearest segment of another type.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D = true;

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

  n = n + 1;
  params(n).name = 'Distance Z unit / X unit';
  params(n).default = 1;
  params(n).help = 'How many times larger is one pixel in the Z dimension than the X dimension.';
  params(n).type = 'numeric';

end
