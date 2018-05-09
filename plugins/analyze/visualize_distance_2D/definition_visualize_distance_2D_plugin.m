function [params, algorithm] = fun()

  algorithm.name = 'Visualize Distance 2D';
  algorithm.help = 'Use arrows to visualize the distance between two types of objects.';
  algorithm.image = 'visualize_distance_2D_plugin.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Channel 1 Image';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Channel 2 Image';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Channel 1 Segments';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Channel 2 Segments';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Distance Measurement';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Arrow Start Point';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Arrow End Point';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Figure Title';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Z Slice';
  params(n).default = 1;
  params(n).help = 'Choose a slice in the Z dimension to plot.';
  params(n).type = 'numeric';
  params(n).limits = [1 Inf];

  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = 'Additional information is added if available in the current measurements table. This includes coloring according to tracked traces.';
  params(n).type = 'ResultTable_for_current_display';

end
