function [params, algorithm] = fun()

  algorithm.name = 'Example Measurement Plugin';
  algorithm.help = 'This example measurement computes MeanIntensity for each segment in an image.';
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
