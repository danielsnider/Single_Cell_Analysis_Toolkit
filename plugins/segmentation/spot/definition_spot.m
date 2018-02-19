function [params, algorithm] = fun()

  algorithm.name = 'Spot';
  algorithm.help = 'Spotting objects using gaussian blurring then finding all maximum intensity peaks.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 500;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Gaussian Blur';
  params(n).default = 6;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result Only';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'Result Only','All','Off'};


end
