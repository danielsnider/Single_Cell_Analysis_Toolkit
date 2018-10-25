function [params, algorithm] = fun()

  algorithm.name = 'Gonska Segmentation';
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
  params(n).default = .1;
  params(n).help = 'Determine which pixels get thresholded as foreground pixels, specified as a real, nonnegative numeric scalar in the range [0,1]. High sensitivity values lead to thresholding more pixels as foreground, at the risk of including some background pixels. The type of thresholding performed is: Adaptive image threshold using local first-order statistics. More info: https://www.mathworks.com/help/images/ref/adaptthresh.html';
  params(n).type = 'numeric';
  params(n).limits = [0 1];

  n = n + 1;
  params(n).name = 'Adaptive Threshold Neighbourhood';
  params(n).default = 100;
  params(n).help = 'Size of neighborhood used to compute local statistic around each pixel. The type of thresholding performed is: Adaptive image threshold using local first-order statistics. More info: https://www.mathworks.com/help/images/ref/adaptthresh.html';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 500;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = Inf;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Mean Intensity';
  params(n).default = '10%';
  params(n).help = 'Remove segments that have a mean pixel intensity lower than the set level. Enter between 0% and 100% to threshold dynamically using the percentile at the given level as the threshold. Omit the % to hard code the threshold to an intensity value.';
  params(n).type = 'text';
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Solidity';
  params(n).default = 0.8;
  params(n).help = 'Remove segments that are lower than the set solidity threshold. Must be within 0 and 1.';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = true;
  params(n).limits = [0 1];

  n = n + 1;
  params(n).name = 'Eccentricity';
  params(n).default = 0.7;
  params(n).help = 'Remove segments that are higher than the set eccentricity threshold. Must be within 0 and 1.';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = false;
  params(n).limits = [0 1];

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result Only';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result Only','Off'};

end