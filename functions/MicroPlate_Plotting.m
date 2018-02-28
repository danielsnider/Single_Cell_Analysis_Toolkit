function MicroPlate_Plotting(uniResults,uniWells,Plot_Title,MetaRows,MetaCols)   
    
%     Plate_Values = uniResults.Cell_Cycle;
    
    uniResults = sortrows(uniResults,{'column' 'row'}, {'ascend'});
    rownames=cell([8 1]);
    idcs=unique(uniResults.row,'stable');
    rownames(idcs(1:end),1)=uniResults.(regexprep(char(MetaRows.name),'\s','_'))(unique(uniResults.row,'stable')==unique(uniWells.row,'stable'));
    Default_Rows = {'A','B','C','D','E','F','G','H'};
    for i = 1:8        
        if isempty(rownames{i,1})
            rownames{i,1}=Default_Rows{i};
        end        
    end    
    
    uniResults = sortrows(uniResults,{'row' 'column' }, {'ascend'});
    colnames=cell([1 12]);
    idcs=unique(uniResults.column,'stable');
    colnames(1,idcs(1:end))=uniResults.(regexprep(char(MetaCols.name),'\s','_'))(unique(uniResults.column,'stable')==unique(uniWells.column,'stable'));
    Default_Cols = {'1','2','3','4','5','6','7','8','9','10','11','12'};
    for i = 1:12        
        if isempty(colnames{1,i})
            colnames{1,i}=Default_Cols{i};
        end        
    end   
    
    uniResults = sortrows(uniResults,{'column' 'row'}, {'ascend'});
    Default_96 = zeros([8 12])*nan;
    for well  = 1:size(uniWells,1)
        row = uniWells.row(well); col=uniWells.column(well);
        
        if cell2mat(uniResults.Cell_Cycle(uniResults.row==row&uniResults.column==col))>0
            Default_96(row,col)=cell2mat(uniResults.Cell_Cycle(uniResults.row==row&uniResults.column==col));
        else
            Default_96(row,col)= NaN;
        end
    end 
    data=mat2gray(Default_96,[0 50]);    
    data(data==1)=NaN;
    
    figure('Name','MicroPlatePlot');microplateplot(data,'TEXTLABELS',sprintfc('%d',Default_96),'MissingValueColor',[0.9,0.9,0.9],'TextFontSize',12,'RowLabels',rownames,'ColumnLabels',colnames);colorbar
    colormap('cool(6)')
    title(['Cell Cycle Length (Hours) for Experiment: ' char(Plot_Title)],'Interpreter', 'none')  
    ax=gca;
    ax.XTickLabelRotation = 45;
    
end