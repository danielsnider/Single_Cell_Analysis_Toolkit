function [params, algorithm] = fun()

  algorithm.name = 'Visualize Distance 3D';
  algorithm.help = 'Use lines to visualize the distance between two types of objects.';
  algorithm.image = 'visualize_distance_3D_plugin.png';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D = true;

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
  params(n).name = 'Line Start Locations';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Line End Locations';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'measurement_dropdown';

  % n = n + 1;
  % params(n).name = 'Caption Text';
  % params(n).default = '';
  % params(n).help = '';
  % params(n).type = 'measurement_dropdown';

  n = n + 1;
  params(n).name = 'Distance Font Size';
  params(n).default = 10;
  params(n).help = 'Sets the font size for informational text.';
  params(n).type = 'numeric';
  params(n).limits = [1 Inf];
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Tracking ID Font Size';
  params(n).default = 10;
  params(n).help = 'Sets the font size for informational text.';
  params(n).type = 'numeric';
  params(n).limits = [1 Inf];
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Color by Tracking IDs';
  params(n).default = false;
  params(n).help = 'Set unique colors based on the tracking ID of objects. If unchecked all "from" objects are colored green.';
  params(n).type = 'checkbox';

  n = n + 1;
  params(n).name = 'ResultTable';
  params(n).default = '';
  params(n).help = 'Additional information is added if available in the current measurements table. This includes coloring according to tracked traces.';
  params(n).type = 'ResultTable_for_current_display';

end
