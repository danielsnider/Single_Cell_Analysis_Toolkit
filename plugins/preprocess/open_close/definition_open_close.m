function [params, algorithm_name, algorithm_help] = fun()

  algorithm_name = 'Open Close Illumination Correction';
  algorithm_help = 'Correct uneven illumination using morphological open and close operations.';

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Open';
  params(n).default = 20;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Close';
  params(n).default = 50;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Debug Figures';
  params(n).default = 'On';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'On','Off'};


end
