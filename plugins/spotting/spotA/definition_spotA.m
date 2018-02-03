function params = fun()
  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Gaussian Smooth Factor';
  params(n).default = 12;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';
  params(n).limits = [0.001 Inf];

  n = n + 1;
  params(n).name = 'Debug Level';
  params(n).default = 'Result Only';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'Result Only','Off'};


end
