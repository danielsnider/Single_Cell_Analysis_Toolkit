function [params, algorithm] = fun()

  algorithm.name = 'Visualize Distance 2D';
  algorithm.help = 'Use arrows to visualize the distance between two types of objects.';
  algorithm.image = 'visualize_distance_2D_plugin.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Distance Measurement';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'From Segment';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';
  
  n = n + 1;
  params(n).name = 'From Image Channel';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'To Segment';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'To Image Channel';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Arrow Start Locations';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Arrow End Locations';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  % n = n + 1;
  % params(n).name = 'Caption Text';
  % params(n).default = '';
  % params(n).help = '';
  % params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Max Dynamic Range (%)';
  params(n).default = 95;
  params(n).help = 'Choose to brighten the image for viewing only so that pixels above the value set here become full brightness.';
  params(n).type = 'numeric';
  params(n).limits = [0.001 100];

  n = n + 1;
  params(n).name = 'Font Size';
  params(n).default = 10;
  params(n).help = 'Sets the font size for the informational text.';
  params(n).type = 'numeric';
  params(n).limits = [1 Inf];

  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = 'Additional information is added if available in the current measurements table. This includes coloring according to tracked traces.';
  params(n).type = 'ResultTable_for_current_display';

end
