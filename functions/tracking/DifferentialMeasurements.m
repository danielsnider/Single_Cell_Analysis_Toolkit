function [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(SubsetTable, weights, time_column_name)
  %% Calc Differetial Measurements between T and T+1 
  % 
  %
  % EXPLAINATION OF THE DIFFERENCES DATA STRUCTURE
  %
  % Example:
  %
  %    raw_differences =
  %    
  %      1×4 cell array
  %    
  %        [3×2 double]    [3×3 double]    [3×3 double]    [3×3 double]
  %
  % Example Explained:
  %
  %    raw_differences =
  %    
  %      1×4 cell array
  %     
  %      -In this example there are 5 timepoints, T1 to T5, there are four differeneces and thus four items in the cell array.
  %      -Differences between timepoints are stored as a matrix in the cell array.
  %      -The matrix size is large enough to compare all cells at timepoint T to all cells at T+1.
  %      -Each value in the matrix contains the difference between one cell at timepoint T and one cell at T+1.
  %      -Each cell at timepoint T is represented as a has a column in the matrix and each value 
  %       in the cell's column is the observed difference to a cell at timepoint T+1.
  %
  %           T1-->T2        T2-->T3         T3-->T4         T4-->T5
  %        [3×2 double]    [3×3 double]    [3×3 double]    [3×3 double]
  %        /  \                            /  \
  %       /   number of cells at T1       /   number of cells at T3
  %    number of cells at T2           number of cells at T4

  %% METRIC WEIGHTS
  % Importance of each metric for when calculating composite distances.
  % Higher value is more important.
  % Metrics that don't have a weight setting will be ignored.

  %% SANITY CHECK THAT METRICS EXIST IN TABLE
  % Loop over weights, checking that they exist
  fields = fieldnames(weights);
  for idx = 1:length(fields)
    metric_name = fields{idx};
    if ~ismember(metric_name, SubsetTable.Properties.VariableNames)
      error(['Can''t find metric in Table: ' metric_name]);
      weights = rmfield(weights, metric_name);
    end
  end

  %% RAW DIFFERENCES (Raw meaning within the value ranges for the metrics)
  raw_differences = {};
  count = 1; % this is needed because "t" time in the loop may not start at 1
  % this way we can start processing timepoints in the middle of the sequence
  for t=min(SubsetTable{:,time_column_name}):max(SubsetTable{:,time_column_name})-1
    % fprintf('Calculating differences between frames %d and %d...\n', t, t+1)

    % Get only cells (ie. table rows) at T and T+1
    T1 = SubsetTable(SubsetTable{:,time_column_name}==t,:);
    T2 = SubsetTable(SubsetTable{:,time_column_name}==t+1,:);

    % Loop over weights, calculating differences for each
    fields = fieldnames(weights);
    for idx = 1:length(fields)
      metric_name = fields{idx};

      % Handle centroids measurements differently because they contain two values, X and Y
      if strfind(metric_name, 'Centroid')
        % Tranlation distances between T and T+1
        X_translation = squareform(pdist([T1.(metric_name)(:,1);T2.(metric_name)(:,1)]));
        X_translation=X_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
        Y_translation = squareform(pdist([T1.(metric_name)(:,2);T2.(metric_name)(:,2)]));
        Y_translation=Y_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
        [theta,rho] = cart2pol(X_translation,Y_translation);
        raw_differences{count}.(metric_name) = rho;
        continue
      end

      % Default case, straight up difference calculation
      difference = squareform(pdist([T1.(metric_name);T2.(metric_name)]));
      raw_differences{count}.(metric_name) = difference(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences
    end
    count = count+1;
  end

  %% NORMALIZED DIFFERENCES (Scale all metric value ranges to between 0 and 1)
  normalized_differences = {};
  for t=1:length(raw_differences)
    % Loop over weights, calculating normalized differences for each
    fields = fieldnames(weights);
    for idx = 1:length(fields)
      metric_name = fields{idx};
      normalized_differences{t}.(metric_name) = normalize0to1(raw_differences{t}.(metric_name));
    end
  end

  %% COMPOSITE DIFFERENCES (Combine differences of many metrics into one)
  composite_differences = {};
  for t=1:length(normalized_differences)
    composite_differences{t} = zeros(size(normalized_differences{t}.(metric_name)));
    % Loop over weights, totalling weighted metrics
    fields = fieldnames(weights);
    for idx = 1:length(fields)
      metric_name = fields{idx};
      composite_differences{t} = composite_differences{t} + ...
          normalized_differences{t}.(metric_name) .* weights.(metric_name);
    end
  end

end