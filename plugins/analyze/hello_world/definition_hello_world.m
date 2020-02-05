function [params, algorithm] = plugin_definition()

  algorithm.name = 'Hello World';
  algorithm.help = 'A hello world example plugin.';
  algorithm.image = 'image.png';
  algorithm.maintainer = 'Full Name <email@address.com>';

  params(1).name = 'Print "Hello World" n times';
  params(1).type = 'numeric';
  params(1).default = 10;
  params(1).limits = [0 Inf];
  params(1).help = 'Set the number of times hello world is printed.';

  params(2).name = 'Exclamation';
  params(2).default = '!';
  params(2).help = 'Choose a trailing character.';
  params(2).type = 'dropdown';
  params(2).options = {'!', '?', '.'};
  params(2).optional = true;
