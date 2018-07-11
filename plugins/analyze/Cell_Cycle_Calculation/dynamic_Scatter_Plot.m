%% Inputs
% Figure_Name = string for figure to be named
% data_Map = data container variable that has data keys and values
% data_order_to_process = cell array of the order user wants data to be plotted
% num_Points = the total number of points that needs to be plotted
% num_Points_to_Group =  the number of points that you want to be colored as the same data/treatment group
% text_point_label = string to label textpoint
% plot_title = string array for plots title
% y_label = string array for y axis label
% x_label = string array for x axis label

function dynamic_Scatter_Plot(Figure_Name, data_Map, data_order_to_process, num_Points, num_Points_to_Group, text_point_label, plot_title, y_label, x_label)

    color_list = distinguishable_colors(60,[0 0.5 0 ]);
    figure('Name', Figure_Name); hold on; colour_count = 1;
    % Loop over each point
    for yy = 1:num_Points
        
            y = data_Map(char(data_order_to_process(yy)));
            x = yy;
            plot(x, y, 'o','MarkerEdgeColor','b','MarkerFaceColor',color_list(colour_count,:))
            
            % Add text label 
            txt1 = join(horzcat(repelem(text_point_label,size(y,1))', num2str(y)));
            labelpoints(x,y,txt1,'N',0.2,1)

        if ~mod(yy,num_Points_to_Group)
            colour_count = colour_count + 1;
        end
        
    end
    x_labels = data_order_to_process';
    ax = gca;
    ax.XTick = 1:length(x_labels);
    ax.XTickLabel = x_labels;
    ax.XTickLabelRotation = 45;
    title(plot_title,'Interpreter', 'none');ylabel(y_label);xlabel(x_label)
    grid on;
    hold off;
end