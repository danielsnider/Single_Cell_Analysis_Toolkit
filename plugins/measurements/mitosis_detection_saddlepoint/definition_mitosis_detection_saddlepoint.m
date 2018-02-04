function params = fun()
  n = 0;
  n = n + 1;
  params(n).name = 'Input Image Channel';
  params(n).default = '';
  params(n).help = 'The image to detect mitosis in';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Debug Level';
  params(n).default = 'Result Only';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'Debug','Off'};


end
