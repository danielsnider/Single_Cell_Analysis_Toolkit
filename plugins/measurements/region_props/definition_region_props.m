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

  n = n + 1;
  params(n).name = 'Measurements per Segment';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'listbox';
  params(n).options = { ...
    'Area', ...
    'BoundingBox', ...
    'Centroid', ...
    'ConvexArea', ...
    'ConvexHull', ...
    'Eccentricity', ...
    'EquivDiameter', ...
    'EulerNumber', ...
    'Extent', ...
    'MajorAxisLength', ...
    'MinorAxisLength', ...
    'Orientation', ...
    'Perimeter', ...
    'Solidity', ...
  };

  n = n + 1;
  params(n).name = 'Measurements per Channel';
  params(n).default = '';
  params(n).help = 'The image to segment';
  params(n).type = 'listbox';
  params(n).options = { ...
    'TotalIntensity', ...
    'MeanIntensity', ...
    'MaxIntensity', ...
    'MinIntensity', ...
    'WeightedCentroid', ...
    'GradientMeanIntensity', ...
    'GradientTotalIntensity', ...
    'PixelValues', ...
  };


end