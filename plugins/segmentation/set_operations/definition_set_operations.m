function [params, algorithm] = fun()

  algorithm.name = 'Set Operations Union, Intersect, Difference';
  algorithm.help = 'Combine two segments using set operations: union, intersection, symmetric difference, and subtraction.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D_and_2D = true;

  n = 0;

  n = n + 1;
  params(n).name = 'Segment A';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Segment B';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Set Operation (A, B) ';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'dropdown';
  params(n).options = {'Union','Intersect','Symmetric Difference', 'Subtraction'};
end
