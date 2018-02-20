function [params, algorithm] = fun()

  algorithm.name = 'Mitosis Detection with Saddle Points';
  algorithm.help = 'See: https://en.wikipedia.org/wiki/Saddle_point';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Channel to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Segment to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_dropdown';

end
