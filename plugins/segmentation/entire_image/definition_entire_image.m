function [params, algorithm] = fun()

  algorithm.name = 'Entire Image';
  algorithm.help = 'Whole image is used as one segment. Used when you want to measure an entire image.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D_and_2D = true;

  n = 0;
  n = n + 1;
  params(n).name = 'Pick One';
  params(n).default = '';
  params(n).help = 'Only required so that the result matches the size of this input.';
  params(n).type = 'image_channel_dropdown';

end
