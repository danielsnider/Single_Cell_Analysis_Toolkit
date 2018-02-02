function params = fun()
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

  n = n + 1;
  params(n).name = 'Gaussian Smooth Factor';
  params(n).default = 2;
  params(n).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Threshold';
  params(n).default = 1000;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Min Area';
  params(n).default = 200;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Max Area';
  params(n).default = 10000;
  params(n).help = '';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'Debug Level';
  params(n).default = 'Result Only';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'All','Result Only','Off'};

end