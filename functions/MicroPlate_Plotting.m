function MicroPlate_Plotting(uniResults,uniWells,data_to_plot,color,Main_Title,Plot_Title,MetaRows,MetaCols,rounding_decimal)   
    
    % Parse row meta-data info for row labeling
    uniResults = sortrows(uniResults,{'column' 'row'}, {'ascend'});
    rownames=cell([8 1]);
    idcs=unique(uniResults.row,'stable');
    try
        rownames(idcs(1:end),1)=uniResults.(regexprep(char(MetaRows.name),'\s','_'))(unique(uniResults.row,'stable')==unique(uniWells.row,'stable'));
    catch
        rownames(idcs(1:end),1)=uniResults.(MetaRows)(unique(uniResults.row,'stable')==unique(uniWells.row,'stable'));
    end
    Default_Rows = {'A','B','C','D','E','F','G','H'};
    for i = 1:8        
        if isempty(rownames{i,1})
            rownames{i,1}=Default_Rows{i};
        end        
    end    
    
    % Parse column meta-data info for column labeling
    uniResults = sortrows(uniResults,{'row' 'column' }, {'ascend'});
    colnames=cell([1 12]);
    idcs=unique(uniResults.column,'stable');
    try
        colnames(1,idcs(1:end))=uniResults.(regexprep(char(MetaCols.name),'\s','_'))(unique(uniResults.column,'stable')==unique(uniWells.column,'stable'));
    catch
        colnames(1,idcs(1:end))=uniResults.(MetaCols)(unique(uniResults.column,'stable')==unique(uniWells.column,'stable'));
    end
    Default_Cols = {'1','2','3','4','5','6','7','8','9','10','11','12'};
    for i = 1:12        
        if isempty(colnames{1,i})
            colnames{1,i}=Default_Cols{i};
        end        
    end   
    
    % Parsing Data into 96 dimension matrix
    uniResults = sortrows(uniResults,{'column' 'row'}, {'ascend'});
    Default_96 = zeros([8 12])*nan;
    for well  = 1:size(uniWells,1)
        row = uniWells.row(well); col=uniWells.column(well);
        if iscell(uniResults.(data_to_plot)(uniResults.row==row&uniResults.column==col))
            if cell2mat(uniResults.(data_to_plot)(uniResults.row==row&uniResults.column==col))>0 %Error Here
                Default_96(row,col)=cell2mat(uniResults.(data_to_plot)(uniResults.row==row&uniResults.column==col));
            else
                Default_96(row,col)= NaN;
            end
        else
            if uniResults.(data_to_plot)(uniResults.row==row&uniResults.column==col)>0 %Error Here
                Default_96(row,col)=uniResults.(data_to_plot)(uniResults.row==row&uniResults.column==col);
            else
                Default_96(row,col)= NaN;
            end
        end
    end 
    % Scale data for microplate plot, allows for easier visualization and difference between values with color coding
    data=mat2gray(Default_96,[min(min(Default_96))-100 max(max(Default_96))+100]);    
    data(data==1)=NaN;
    Default_96 = round(Default_96,rounding_decimal,'decimals');
    
    % Plotting Action
    
    fh=figure('Name','MicroPlatePlot');microplateplot(data,'TEXTLABELS',sprintfc('%g',Default_96),'MissingValueColor',[0.9,0.9,0.9],'TextFontSize',12,'RowLabels',rownames,'ColumnLabels',colnames);colorbar
    try
        colormap(brewermap([],color))
    catch
        colormap(color)
    end
    title([Main_Title ' for Experiment: ' char(Plot_Title)],'Interpreter', 'none')  
    ax=gca;
    ax.XTickLabelRotation = 45;
    
end