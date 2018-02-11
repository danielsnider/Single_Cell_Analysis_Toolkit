function [params, algorithm_name, algorithm_help] = fun()

  algorithm_name = 'Watershed Segmentation';
  algorithm_help = 'Watershed segmentation is used to separate touching objects in an image. The watershed transform finds "catchment basins" and "watershed ridge lines" in an image by treating it as a surface where light pixels are high and dark pixels are low. Segmentation using the watershed transform works better if you can identify, or "mark", objects with seeds. ';

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

  n = n + 1;
  params(n).name = 'Gaussian Blur (for threshold)';
  params(n).default = 0.3;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Gaussian Blur (for watershed)';
  params(n).default = 5;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];
  params(n).optional = true;
  params(n).optional_default_state = false;

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 275;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 200;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = 100000;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Debug Level';
  params(n).default = 'Result With Seeds';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result With Seeds','Result Only','Off'};

end