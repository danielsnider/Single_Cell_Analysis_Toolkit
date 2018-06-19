function [params, algorithm] = fun()

  algorithm.name = 'Open Close Tophat Illumination Correction';
  algorithm.help = 'Correct uneven illumination using morphological open and close operations.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Close';
  params(n).default = 10;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Open';
  params(n).default = 100;
  params(n).help = '';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];
  params(n).optional = true;

  n = n + 1;
  params(n).name = 'Line Scan';
  params(n).default = 50;
  params(n).help = 'Plot one vertical section of pixel intensities from the input image. The plotted black line shows the original pixel intenties. The plotted red line shows the pixel intensities after the effect of this algorithm.';
  params(n).type = 'slider';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'On';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'On','Off'};


end
