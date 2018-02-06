function params = fun()
  n = 0;
  n = n + 1;
  params(n).name = 'Channels to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'image_channel_listbox';

  n = n + 1;
  params(n).name = 'Segments to Measure';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'segment_listbox';
  % n = n + 1;
  % params(n).name = 'Debug Level';
  % params(n).default = 'Result Only';
  % params(n).help = '';
  % params(n).type = 'dropdown';
  % params(n).options = {'Debug','Off'};


end
