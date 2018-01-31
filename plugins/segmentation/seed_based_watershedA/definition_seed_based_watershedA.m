function params = fun()
  params(1).name = 'Gaussian Smooth Factor';
  params(1).default = 12;
  params(1).help = 'The amount to gaussian smooth the image. Greater values will smooth things together. Lower values will allow for more seeds.';
  params(1).type = 'Numeric';
end