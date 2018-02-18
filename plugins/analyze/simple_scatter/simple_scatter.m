function fun(marker_size, title_param, x_data, x_label, y_data, y_label)

  f = figure(150); clf; set(f,'name','simple scatter','NumberTitle', 'off');

  plot(x_data,y_data, 'o', 'Color', [.6 .6 .6],'MarkerSize', marker_size,'MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor','w');
  
  set(gca,'FontSize',14);
  set(gca,'Color',[1 1 1 ]);
  set(gcf,'Color',[1 1 1 ]);

  xlabel(x_label, 'Interpreter','none');
  ylabel(y_label, 'Interpreter','none');
  title(title_param, 'Interpreter','none');

  box off

end