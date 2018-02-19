function fun(fig_name, fig_num, marker_size, title_param, fontsize_param, trend_line, correlation_type, x_data, x_label, y_data, y_label)

  f = figure(fig_num); clf; set(f,'name',fig_name,'NumberTitle', 'off');

  plot(x_data,y_data, 'o', 'Color', [.6 .6 .6],'MarkerSize', marker_size,'MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor','w');
  
  set(gca,'FontSize',fontsize_param);
  set(gca,'Color',[1 1 1 ]);
  set(gcf,'Color',[1 1 1 ]);

  xlabel(x_label, 'Interpreter','none');
  ylabel(y_label, 'Interpreter','none');

  box off

  if trend_line
    lsline
  end

  if ~isequal(correlation_type,false)
    [r,p] = corr(x_data,y_data,'type',correlation_type);
    if isempty(title_param)
      title_param = sprintf('r=%.2f, p=%.2f',r,p);
    else
      title_param = sprintf('%s (r=%.2f, p=%.2f)',title_param,r,p);
    end
  end

  title(title_param);

end