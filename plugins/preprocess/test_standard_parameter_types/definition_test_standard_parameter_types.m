function [params, algorithm] = fun()

  algorithm.name = 'Test Standard Plugin Types';
  algorithm.help = 'Not for actual consumption.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'numeric';
  params(n).default = 0;
  params(n).help = 'numeric';
  params(n).type = 'numeric';

  n = n + 1;
  params(n).name = 'text';
  params(n).default = 'text';
  params(n).help = 'text';
  params(n).type = 'text';

  n = n + 1;
  params(n).name = 'slider';
  params(n).default = 50;
  params(n).help = 'slider';
  params(n).type = 'slider';

  n = n + 1;
  params(n).name = 'listbox';
  params(n).default = 'example1';
  params(n).help = 'listbox';
  params(n).type = 'listbox';
  params(n).options = {'example1','example2'};

  n = n + 1;
  params(n).name = 'dropdown';
  params(n).default = 'example1';
  params(n).help = 'dropdown';
  params(n).type = 'dropdown';
  params(n).options = {'example1','example2'};

  n = n + 1;
  params(n).name = 'checkbox';
  params(n).default = true;
  params(n).help = 'checkbox';
  params(n).type = 'checkbox';

end
