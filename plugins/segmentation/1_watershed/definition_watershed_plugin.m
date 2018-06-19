function [params, algorithm] = fun()

  algorithm.name = 'Watershed Segmentation';
  algorithm.help = 'Watershed segmentation is used to separate touching objects in an image. The watershed transform finds "catchment basins" and "watershed ridge lines" in an image by treating it as a surface where light pixels are high and dark pixels are low. Segmentation using the watershed transform works better if you can identify, or "mark", objects with seeds. ';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Input Seeds';
  params(n).default = '';
  params(n).help = 'The seeds to use when watersheding. They will allow the algorithm to seperate touching objects.';
  params(n).type = 'segment_dropdown';
  params(n).optional = true;
  params(n).optional_default_state = false;

  n = n + 1;
  params(n).name = 'Gaussian Blur for Threshold';
  params(n).default = 1.3;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Gaussian Blur for Segmentation';
  params(n).default = 0.75;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 150;
  params(n).help = 'Remove segments of the image that are less than the threshold.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 5;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = Inf;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Remove Objects Touching Boarder';
  params(n).default = 0;
  params(n).help = 'Remove segments that are touching the boarder of the image. If you specify a value of 25 (or any value between 0 and 100), then objects will be removed if 25% or more of their perimeter is touching the boarder. If you specify 0, any boarder touch will reject the object.';
  params(n).type = 'numeric';
  params(n).limits = [0 100];
  params(n).optional = true;
  params(n).optional_default_state = true;

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result With Seeds';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result With Seeds','Result Only','Off'};

end