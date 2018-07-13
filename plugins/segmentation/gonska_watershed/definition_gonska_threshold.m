function [params, algorithm] = fun()

  algorithm.name = 'Threshold Segmentation (Gonska)';
  algorithm.help = 'This plugin is tailored to the needs of the Gonska Lab.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Gaussian Blur';
  params(n).default = 0.5;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Adaptive Threshold Sensitivity';
  params(n).default = 0.4;
  params(n).help = 'Determine which pixels get thresholded as foreground pixels, specified as a real, nonnegative numeric scalar in the range [0,1]. High sensitivity values lead to thresholding more pixels as foreground, at the risk of including some background pixels. The type of thresholding performed is: Adaptive image threshold using local first-order statistics. More info: https://www.mathworks.com/help/images/ref/adaptthresh.html';
  params(n).type = 'numeric';
  params(n).limits = [0 1];

  n = n + 1;
  params(n).name = 'Close Morph Size';
  params(n).default = 0;
  params(n).help = 'Remove small dots and thin lines of this size. A setting of 0 effectively disables this step.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Open Morph Size';
  params(n).default = 0;
  params(n).help = 'Connect nearby objects within this amount. A setting of 0 effectively disables this step.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 400;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = Inf;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result Only';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result Only','Off'};

end