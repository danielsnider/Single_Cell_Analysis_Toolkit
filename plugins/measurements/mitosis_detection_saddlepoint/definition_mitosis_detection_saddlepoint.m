function [params, algorithm_name, algorithm_help] = fun()

  algorithm_name = 'Mitosis Detection with Saddle Points';
  algorithm_help = 'See: https://en.wikipedia.org/wiki/Saddle_point';

  n = 0;
  n = n + 1;
  params(n).name = 'Channels to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_listbox';

  n = n + 1;
  params(n).name = 'Segments to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';

end
