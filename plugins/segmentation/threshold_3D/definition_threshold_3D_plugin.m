function [params, algorithm] = fun()

  algorithm.name = '3D Threshold Segmentation';
  algorithm.help = '';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D = true;

  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Gaussian Blur';
  params(n).default = 3;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Used to define the boundary shape of objects.';
  params(n).type = 'numeric';
  params(n).limits = [0.00001 Inf];

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = '95%';
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Enter between 0% and 100% to threshold dynamically using the percentile at the given level as the threshold. Omit the % to hard code the threshold to an intensity value.';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 100;
  params(n).help = 'Remove segments that are smaller than the min area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = Inf;
  params(n).help = 'Remove segments that are larger than the max area.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Distance Z unit / X unit';
  params(n).default = 1;
  params(n).help = 'How many times larger is one discrete step in the Z dimension than one step in the X dimension.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Display Figures';
  params(n).default = 'Result With Seeds';
  params(n).help = 'Control whether figures are displayed to show the steps of the algorithm and help you understand and debug it.';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result Only','Off'};

end