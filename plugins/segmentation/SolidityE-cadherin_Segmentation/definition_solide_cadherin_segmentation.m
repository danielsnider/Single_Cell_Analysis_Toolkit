function [params, algorithm] = fun()

  algorithm.name = 'E-cadherin Watershed Segmentation_Solidity';
  algorithm.help = 'This plugin was designed for images of E-caderin stains in tissue sections. Watershed segmentation is used to separate touching objects in an image. The watershed transform finds "catchment basins" and "watershed ridge lines" in an image by treating it as a surface where light pixels are high and dark pixels are low.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;

  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image channel to segment.';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Gaussian Blur (for threshold)';
  params(n).default = 3;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Gaussian Blur (for watershed)';
  params(n).default = 7;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 2750;
  params(n).help = 'Remove segments of the image that are less than the threshold.';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = false;

  n = n + 1;
  params(n).name = 'Suppresses Minima';
  params(n).default = 2;
  params(n).help = 'This suppresses all minima in the intensity image I whose depth is less than the given value. Read more in the ''imhmin'' Matlab documentation: https://www.mathworks.com/help/images/ref/imhmin.html';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 10;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = 100000;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Solidity';
  params(n).default = 0;
  params(n).help = 'Remove segments that are lower than the set solidity threshold. Must be within 0 and 1.';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = false;
  params(n).limits = [0 1];

  
  n = n + 1;
  params(n).name = 'Eccentricity';
  params(n).default = 0;
  params(n).help = 'Remove segments that are higher than the set eccentricity threshold. Must be within 0 and 1.';
  params(n).type = 'numeric';
  params(n).optional = true;
  params(n).optional_default_state = false;
  params(n).limits = [0 1];
  
  n = n + 1;
  params(n).name = 'Debug Level';
  params(n).default = 'Result With Seeds';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result With Seeds','Result Only','Off'};

end