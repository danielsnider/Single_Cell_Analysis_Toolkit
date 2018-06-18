function [params, algorithm] = fun()
  
  algorithm.name = 'Mander''s Colocation of Signal';
  algorithm.help = 'The purpose of Mander''s colocalization coefficient is to characterize the degree of overlap between two channels in a microscopy image. For more information see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3074624/ or https://svi.nl/ColocalizationTheory';
  algorithm.maintainer = 'Daniel Snider <danielsnider12@gmail.com>';
  algorithm.supports_3D_and_2D = true;

  n = 0;

  n = n + 1;
  params(n).name = 'Channel 1';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Channel 2';
  params(n).default = '';
  params(n).help = '';
  params(n).type = 'image_channel_dropdown';

  n = n + 1;
  params(n).name = 'Measure only in segment';
  params(n).default = '';
  params(n).help = 'Colocation measurement will only be performed on pixels in the given segment region of interest (ROI) that you choose.';
  params(n).type = 'segment_dropdown';

  n = n + 1;
  params(n).name = 'Type of Coefficient';
  params(n).default = '';
  params(n).type = 'dropdown';
  params(n).help = '';
  % params(n).help = 'Choose ''Mander''s Overlap Coefficient (MOC)'' unless you are interested only in knowing how well the red pixels colocalize with the green ones, or vice versa. It may happen, for example, that all the red pixels overlap with green pixels but many of the green ones are "alone", in regions where no red signal is present. Then choose ''Mander''s Coefficient of channel 1 on 2'' or ''channel 2 on 1''';
  params(n).options = { ...
    'Mander''s Overlap Coefficient (MOC)', ...
    % 'Mander''s Coefficient of channel 1 on 2', ...
    % 'Mander''s Coefficient of channel 2 on 1', ...
  };

end
