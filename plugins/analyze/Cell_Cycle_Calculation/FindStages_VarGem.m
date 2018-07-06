function [idxEG1,idxLG1,idxG1S,idxS,idxG2] = FindStages_VarGem(DNA,lGem,FieldName,varargin)
% Assigns cells to five cell cycle stages.
% DIFFERENCE FROM FindStages_v2: GEMININ THRESHOLD FOR S-PHASE AND G2 CELLS
% LOWERED (LINES 111-112). USE THIS VERSION FOR "MESSIER" POPULATIONS, WHERE GEMININ LEVELS
% VARY, SO SOME S-PHASE CELLS ARE NOT THAT BRIGHT. 
%
% INPUTS
% DNA = a vector listing DNA content for each cell
% lGem = a vector the same length as DNA, listing corresponding log(geminin) measurement for each
%        cell. **Note the use of log(geminin) rather than geminin as an input.**
% Optional: FindStages(DNA,logGeminin,'image') will also display a figure
% plotting results
%
% OUTPUTS
% idxEG1 = a binary vector (matlab class logical), the same length as DNA
%          and lGem, with a one corresponding to each early-G1 cell (2N DNA, low
%          geminin) and a zero corresponding to each other cell.
% idxLG1,idxG1S,idxS,idxG2 = similar vectors to idxEG1, identifying cells
%                            in late G1 (2N DNA, high geminin), G1/S transition period, S-phase, and
%                            late-S-phase/G2, respectively.


% Set adaptive thresholds for DNA
[fi,xi] = ksdensity(DNA,linspace(prctile(DNA,1),prctile(DNA,99),500)); %CHANGED FROM FIRST VERSION.
if max(xi)-min(xi)>1e7
    disp(['Correction: Trimming DNA axis'])
    [fi,xi] = ksdensity(DNA,linspace(prctile(DNA,1),prctile(DNA,99),500));
end
pk1DNA = xi(fi==max(fi));  % DNA level of 2N peak
[fi,xi] = ksdensity(DNA, 0.5*pk1DNA:0.02*pk1DNA:2.5*pk1DNA);
pk1DNA = xi(fi==max(fi));
% Correction for wells where 4N peak is higher than 2N peak
if sum(DNA<1.25*pk1DNA)/length(DNA) > 0.9 % If almost all cells are in "early G1", check if there is an earlier peak.
    [fi,xi] = ksdensity(DNA,linspace(prctile(DNA,1),prctile(DNA,99),500)); %THIS IS THE LINE THAT WAS CHANGED IN VERSION 2
    [pksDNA,locsDNA] = findpeaks(fi);
    highpeaks=pksDNA>=max(fi)/4;
    pksDNA=pksDNA(highpeaks); locsDNA=locsDNA(highpeaks);
    if length(pksDNA)==2
        pk1DNA=xi(locsDNA(1));
        disp(['Correction: Lowering DNA threshold'])
    elseif length(pksDNA)>2%CORRECTION FOR SITUATION WHERE THERE IS MORE THAN ONE EARLIER PEAK.
        earlypeaks=xi(locsDNA)<0.8*pk1DNA;
        pksDNA=pksDNA(earlypeaks); locsDNA=locsDNA(earlypeaks);
        [ep,epi] = max(pksDNA);
        pk1DNA=xi(locsDNA(epi)); 
    end
end
DNA_thr1 = 0.8*pk1DNA;
DNA_thr2 = 1.25*pk1DNA;
DNA_thr3 = 1.85*pk1DNA;
DNA_thr4 = 2.3*pk1DNA;
% Set adaptive thresholds for Geminin
[fj,xj] = ksdensity(lGem(DNA>DNA_thr1&DNA<DNA_thr4));
xj = xj(fj>0.05); fj = fj(fj>0.05);
pks = findpeaks(fj); % Identify the two peaks
pk1Gem = xj(fj==pks(1));  %Gem level of the 1st peak
if length(pks)>1
    pk2Gem = xj(fj==pks(2));  %Gem level of the 2nd peak
    Gem_thr1 = pk1Gem + 0.25*(pk2Gem - pk1Gem);
    Gem_thr2 = pk1Gem + 0.7*(pk2Gem - pk1Gem);
    Gem_thr3 = (Gem_thr1+Gem_thr2)/2;
else
    if sum(DNA>DNA_thr1&DNA<(DNA_thr1+(DNA_thr2-DNA_thr1)/4))<20
        [fj,xj] = ksdensity(lGem(DNA>DNA_thr1&DNA<(DNA_thr1+(DNA_thr2-DNA_thr1))));
    else
        [fj,xj] = ksdensity(lGem(DNA>DNA_thr1&DNA<(DNA_thr1+(DNA_thr2-DNA_thr1)/4))); %If geminin peaks can't be separated, use DNA level to estimate geminin peak locations.
    end
    pk1Gem = xj(fj==max(fj));
    [fj,xj] = ksdensity(lGem(DNA>DNA_thr3&DNA<DNA_thr4));
    pk2Gem = xj(fj==max(fj));
    pk2Gem=mean(pk2Gem);
    Gem_thr1 = pk1Gem + 0.25*(pk2Gem - pk1Gem);
    Gem_thr2 = pk1Gem + 0.7*(pk2Gem - pk1Gem);
    Gem_thr3 = (Gem_thr1+Gem_thr2)/2;
end
% Fix geminin thresholds if they were thrown off by a few very bright cells.
if sum(DNA>DNA_thr2&DNA<DNA_thr3&lGem>Gem_thr3)/sum(DNA>DNA_thr2&DNA<DNA_thr3)<0.5%If only a few cells with S-phase DNA are above the geminin threshold for S-phase, threshold may be incorrect.
    disp(['Correction: Lowering geminin threshold'])
    [fj,xj] = ksdensity(lGem(DNA>DNA_thr1&DNA<DNA_thr4&lGem<Gem_thr3));
    xj = xj(fj>0.05); fj = fj(fj>0.05);
    pks = findpeaks(fj); % Identify the two peaks
    pk1Gem = xj(fj==pks(1));  %Gem level of the 1st peak
    if length(pks)>1
        pk2Gem = xj(fj==pks(2));  %Gem level of the 2nd peak
        Gem_thr1 = pk1Gem + 0.25*(pk2Gem - pk1Gem);
        Gem_thr2 = pk1Gem + 0.7*(pk2Gem - pk1Gem);
        Gem_thr3 = (Gem_thr1+Gem_thr2)/2;
    else
        [fj,xj] = ksdensity(lGem(DNA>DNA_thr1&DNA<(DNA_thr1+(DNA_thr2-DNA_thr1)/4))); %If geminin peaks can't be separated, use DNA level to estimate geminin peak locations.
        pk1Gem = xj(fj==max(fj));
        if length(pk1Gem)>1 %Fix added for when multiple neighboring points in xj have maximum value of fj (flat peak)
            test=find((fj==max(fj)));
            if length(pk1Gem)<5 && max(diff(test))<2
                pk1Gem=mean(pk1Gem);
            else
                disp('ERROR: MULTIPLE VALUES OF pk1Gem')
                keyboard
            end
        end
        [fj,xj] = ksdensity(lGem(DNA>DNA_thr3&DNA<DNA_thr4));
        pk2Gem = xj(fj==max(fj));
        Gem_thr1 = pk1Gem + 0.25*(pk2Gem - pk1Gem);
        Gem_thr2 = pk1Gem + 0.7*(pk2Gem - pk1Gem);
        Gem_thr3 = (Gem_thr1+Gem_thr2)/2;
    end
end
% Index for different cell cycle groups
idxEG1 = DNA>DNA_thr1&DNA<DNA_thr2&lGem<Gem_thr1;
idxLG1 = DNA>DNA_thr1&DNA<DNA_thr2&lGem>Gem_thr1&lGem<Gem_thr2;
idxG1S = DNA>DNA_thr1&DNA<DNA_thr2&lGem>Gem_thr2;
idxS = DNA>DNA_thr2&DNA<DNA_thr3&lGem>Gem_thr1; %Changed from FindStages_v2.m
idxG2 = DNA>DNA_thr3&DNA<DNA_thr4&lGem>Gem_thr2; %Changed from FindStages_v2.m
% Visualization
if length(varargin)>0 && strcmp(varargin{1},'image')
    figure(900);clf;hold on
    plot(DNA(idxEG1), lGem(idxEG1), 'go');hold on;
    plot(DNA(idxLG1), lGem(idxLG1), 'ro');
    plot(DNA(idxG1S), lGem(idxG1S), 'yo');
    plot(DNA(idxS), lGem(idxS), 'co');
    plot(DNA(idxG2), lGem(idxG2), 'mo');
    plot(DNA, lGem, '.');
    hold off
    legend('EG1', 'LG1', 'G1S', 'S', 'G2');
    title(FieldName)
    xlabel('DNA'); ylabel('log(Geminin)');
    if pk1Gem-0.5*(pk2Gem-pk1Gem)<pk2Gem+0.8*(pk2Gem-pk1Gem)
        minLim=pk1Gem-0.5*(pk2Gem-pk1Gem);
        maxLim=pk2Gem+0.8*(pk2Gem-pk1Gem);
    else
        minLim=pk2Gem+0.8*(pk2Gem-pk1Gem);
        maxLim=pk1Gem-0.5*(pk2Gem-pk1Gem);
    end
    xlim([pk1DNA*0.6 pk1DNA*3]); ylim([minLim maxLim])
%     axis tight
end





