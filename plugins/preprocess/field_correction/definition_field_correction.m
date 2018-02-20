function [params, algorithm] = fun()

  algorithm.name = 'Flat-Field Correction';
  algorithm.help = 'Correct uneven illumination using a Matlab ''.mat'' file that contains a matrix (the flat-field) the same shape as your image set. The matrix should contain the values that will be used to do correction. Each image will be substracted by the correction matrix.';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';

  n = 0;
  n = n + 1;
  params(n).name = 'Path to Correction Matrix (.mat)';
  params(n).default = '';
  params(n).help = 'A Matlab ''.mat'' file that contains a matrix the same shape as your image set. The matrix should contain the values that will be used to do correction.';
  params(n).type = 'text';

end
