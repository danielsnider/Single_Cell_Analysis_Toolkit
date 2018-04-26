function [params, algorithm] = fun()

  algorithm.name = 'High Gain Watershed Segmentation';
  algorithm.help = 'High Gain Watershed segmentation is used to separate touching objects in an image with intensities turned brigher to see more shape definition. The watershed transform finds "catchment basins" and "watershed ridge lines" in an image by treating it as a surface where light pixels are high and dark pixels are low. Segmentation using the watershed transform works better if you can identify, or "mark", objects with seeds. ';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Gain Threshold';
  params(n).default = 43;
  params(n).help = 'Make the image brighter by setting a pixel value cut-off. Intensity values higher than the cut-off will be set to 100% brightness. Values less than the cut-off will be scaled between 0 to 255.';
  params(n).type = 'numeric';
  params(n).limits = [0 Inf];

  n = n + 1;
  params(n).name = 'Gaussian Blur for Threshold';
  params(n).default = 20;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 20;
  params(n).help = 'Remove segments of the image that are less than the threshold.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Gaussian Blur for Segmentation';
  params(n).default = 3;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 5000;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = Inf;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result With Seeds';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result With Seeds','Result Only','Off'};

end