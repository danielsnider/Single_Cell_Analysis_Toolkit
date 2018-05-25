function fun(plugin_name, plugin_num, x, y, marker_size, title_param, fontsize_param, trend_line, correlation_type)

  % Check that data is numeric
  if ~isnumeric(x.data)
    msg = sprintf('Cannot plot with incorrect data type. You have given non-numeric data given in ''%s''.',x.name);
    msgbox(msg, 'Cannot Plot','error');
    return
  end
  if ~isnumeric(y.data)
    msg = sprintf('Cannot plot with incorrect data type. You have given non-numeric data given in ''%s''.',y.name);
    msgbox(msg, 'Cannot Plot','error');
    return
  end

  % Remove NaNs
  x_data = x.data;
  y_data = y.data;
  x.data(isnan(x.data)) = [];
  x.data(isnan(y.data)) = [];
  y.data(isnan(x.data)) = [];
  y.data(isnan(y.data)) = [];

  f = figure(plugin_num+344); clf; set(f,'name',plugin_name,'NumberTitle', 'off');

  plot(x.data,y.data, 'o', 'Color', [.6 .6 .6],'MarkerSize', marker_size,'MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor','w');
  
  set(gca,'FontSize',fontsize_param);
  set(gca,'Color',[1 1 1 ]);
  set(gcf,'Color',[1 1 1 ]);

  xlabel(x.name, 'Interpreter','none');
  ylabel(y.name, 'Interpreter','none');

  box off

  if trend_line
    lsline
  end

  if ~isequal(correlation_type,false)
    [r,p] = corr(x.data,y.data,'type',correlation_type);
    if isempty(title_param)
      title_param = sprintf('r=%.2f, p=%.2f',r,p);
    else
      title_param = sprintf('%s (r=%.2f, p=%.2f)',title_param,r,p);
    end
  end

  title(title_param);

end