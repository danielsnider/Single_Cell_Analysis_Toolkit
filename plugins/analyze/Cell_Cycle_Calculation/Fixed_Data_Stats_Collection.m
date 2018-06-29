function [DataStructure] = Fixed_Data_Stats_Collection(row,col,timepoint,keepers,ResultTable,Ch_for_Cytosol_int,Nucleus_Area,DataStructure)

 %% Collect stats
 disp('Start Collecting Stats on cells...')
 disp('--------------------------------------------------------------------------')
 fprintf('Row: %i | Col: %i | TimePoint: %i\nCytosol Channel: %s\nNucleus Area: %s\n', row,col,timepoint,Ch_for_Cytosol_int{1,1},Nucleus_Area)
 disp('--- Collecting cell count')
            DataStructure.Numcells(row,col,timepoint) = length(keepers);
            disp('--- Collecting MeanProt, MedProt, TotalProt and CVProt')
            try
                DataStructure.MeanProt(row,col,timepoint) = mean(ResultTable.(Ch_for_Cytosol_int)(keepers));
                DataStructure.MedProt(row,col,timepoint) = median(ResultTable.(Ch_for_Cytosol_int)(keepers));
                DataStructure.TotalProt(row,col,timepoint) = sum(ResultTable.(Ch_for_Cytosol_int)(keepers));
                DataStructure.CVProt(row,col,timepoint) = std(ResultTable.(Ch_for_Cytosol_int)(keepers))/mean(ResultTable.(Ch_for_Cytosol_int)(keepers));
            catch
                DataStructure.MeanProt(row,col,timepoint) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MedProt(row,col,timepoint) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.TotalProt(row,col,timepoint) = sum(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.CVProt(row,col,timepoint) = std(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers))/mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))));
            end
            disp('--- Collecting Mean Nucleus Area')
            DataStructure.MeanNucArea(row,col,timepoint) = mean(ResultTable.(Nucleus_Area)(keepers));
            disp('--- Collecting Median Nucleus Area')
            DataStructure.MedNucArea(row,col,timepoint) = median(ResultTable.(Nucleus_Area)(keepers));
            disp('--- Collecting Cell Cycle for EG1')
            DataStructure.CC(row,col,timepoint,1) = sum(ResultTable.EG1(keepers))/length(keepers);
            disp('--- Collecting Cell Cycle for LG1')
            DataStructure.CC(row,col,timepoint,2) = sum(ResultTable.LG1(keepers))/length(keepers);
            disp('--- Collecting Cell Cycle for G1S')
            DataStructure.CC(row,col,timepoint,3) = sum(ResultTable.G1S(keepers))/length(keepers);
            disp('--- Collecting Cell Cycle for S')
            DataStructure.CC(row,col,timepoint,4) = sum(ResultTable.S(keepers))/length(keepers);
            disp('--- Collecting Cell Cycle for G2')
            DataStructure.CC(row,col,timepoint,5) = sum(ResultTable.G2(keepers))/length(keepers);
            disp('--- Collecting MeanProtCC, stdProtCC and MedProtCC')
            try
                DataStructure.MeanProtCC(row,col,timepoint,1) = mean(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.EG1));
                DataStructure.MeanProtCC(row,col,timepoint,2) = mean(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.LG1));
                DataStructure.MeanProtCC(row,col,timepoint,3) = mean(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G1S));
                DataStructure.MeanProtCC(row,col,timepoint,4) = mean(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.S));
                DataStructure.MeanProtCC(row,col,timepoint,5) = mean(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G2));
                DataStructure.StdProtCC(row,col,timepoint,1) = MAD(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.EG1));
                DataStructure.StdProtCC(row,col,timepoint,2) = MAD(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.LG1));
                DataStructure.StdProtCC(row,col,timepoint,3) = MAD(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G1S));
                DataStructure.StdProtCC(row,col,timepoint,4) = MAD(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.S));
                DataStructure.StdProtCC(row,col,timepoint,5) = MAD(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G2));         
                DataStructure.MedProtCC(row,col,timepoint,1) = median(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.EG1));
                DataStructure.MedProtCC(row,col,timepoint,2) = median(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.LG1));
                DataStructure.MedProtCC(row,col,timepoint,3) = median(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G1S));
                DataStructure.MedProtCC(row,col,timepoint,4) = median(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.S));
                DataStructure.MedProtCC(row,col,timepoint,5) = median(ResultTable.(Ch_for_Cytosol_int)(ResultTable.Keep & ResultTable.G2));
            catch
                DataStructure.MeanProtCC(row,col,timepoint,1) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.EG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MeanProtCC(row,col,timepoint,2) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.LG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MeanProtCC(row,col,timepoint,3) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G1S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MeanProtCC(row,col,timepoint,4) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MeanProtCC(row,col,timepoint,5) = mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G2,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.StdProtCC(row,col,timepoint,1) = MAD(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.EG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.StdProtCC(row,col,timepoint,2) = MAD(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.LG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.StdProtCC(row,col,timepoint,3) = MAD(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G1S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.StdProtCC(row,col,timepoint,4) = MAD(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.StdProtCC(row,col,timepoint,5) = MAD(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G2,cell2mat(Ch_for_Cytosol_int(2))));         
                DataStructure.MedProtCC(row,col,timepoint,1) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.EG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MedProtCC(row,col,timepoint,2) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.LG1,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MedProtCC(row,col,timepoint,3) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G1S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MedProtCC(row,col,timepoint,4) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.S,cell2mat(Ch_for_Cytosol_int(2))));
                DataStructure.MedProtCC(row,col,timepoint,5) = median(ResultTable.(char(Ch_for_Cytosol_int(1)))(ResultTable.Keep & ResultTable.G2,cell2mat(Ch_for_Cytosol_int(2))));
                
            end
            disp('--- Collecting Mean Nucleus Area per CC and Median Nucleus Area per CC')
            DataStructure.MeanNucAreaCC(row,col,timepoint,1) = mean(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.EG1));
            DataStructure.MeanNucAreaCC(row,col,timepoint,2) = mean(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.LG1));
            DataStructure.MeanNucAreaCC(row,col,timepoint,3) = mean(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.G1S));
            DataStructure.MeanNucAreaCC(row,col,timepoint,4) = mean(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.S));
            DataStructure.MeanNucAreaCC(row,col,timepoint,5) = mean(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.G2));
            DataStructure.MedNucAreaCC(row,col,timepoint,1) = median(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.EG1));
            DataStructure.MedNucAreaCC(row,col,timepoint,2) = median(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.LG1));
            DataStructure.MedNucAreaCC(row,col,timepoint,3) = median(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.G1S));
            DataStructure.MedNucAreaCC(row,col,timepoint,4) = median(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.S));
            DataStructure.MedNucAreaCC(row,col,timepoint,5) = median(ResultTable.(Nucleus_Area)(ResultTable.Keep & ResultTable.G2));  
            try
                [f1,s1] = ksdensity(ResultTable.(Ch_for_Cytosol_int)(keepers),(mean(ResultTable.(Ch_for_Cytosol_int)(keepers))-2*std(ResultTable.(Ch_for_Cytosol_int)(keepers))):((mean(ResultTable.(Ch_for_Cytosol_int)(keepers))+3*std(ResultTable.(Ch_for_Cytosol_int)(keepers)))-(mean(ResultTable.(Ch_for_Cytosol_int)(keepers))-2*std(ResultTable.(Ch_for_Cytosol_int)(keepers))))/100:(mean(ResultTable.(Ch_for_Cytosol_int)(keepers))+3*std(ResultTable.(Ch_for_Cytosol_int)(keepers))));
            catch
                [f1,s1] = ksdensity(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))),(mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))-2*std(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))):((mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))+3*std(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2)))))-(mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))-2*std(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))))/100:(mean(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))+3*std(ResultTable.(char(Ch_for_Cytosol_int(1)))(keepers,cell2mat(Ch_for_Cytosol_int(2))))));
            end
            disp('--- Collecting Protein Density')
            DataStructure.Paxis{row,col,timepoint}=s1;
            DataStructure.Pdensity{row,col,timepoint}=f1;
            [f2,s2] = ksdensity(ResultTable.(Nucleus_Area)(keepers),(mean(ResultTable.(Nucleus_Area)(keepers))-2*std(ResultTable.(Nucleus_Area)(keepers))):((mean(ResultTable.(Nucleus_Area)(keepers))+3*std(ResultTable.(Nucleus_Area)(keepers)))-(mean(ResultTable.(Nucleus_Area)(keepers))-2*std(ResultTable.(Nucleus_Area)(keepers))))/100:(mean(ResultTable.(Nucleus_Area)(keepers))+3*std(ResultTable.(Nucleus_Area)(keepers))));
            disp('--- Collecting Nucleus Density')
            DataStructure.Naxis{row,col,timepoint}=s2;
            DataStructure.Ndensity{row,col,timepoint}=f2;
 disp('Finished Collecting Stats on cells...')
 disp('--------------------------------------------------------------------------')     
%%           
end % End of Function