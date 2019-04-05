clear;
clc;

%all the variables that will be tuned comes in the mainScript when possible

datadir='\\psf\Home\Documents\BCI EEG\LoadEEGFunctions\raw data';
datafolder='DataTraining';
Subjects={...
            'Tiffany\20151201',...
            'XiaMian\20151201',...
			'Xiangjun\20151204',...
            'Yiheng\20151207',...
             'ZhengYang\20151207',...
         };
sel_chan_list = {'Fp1';'Fp2';'F7';'F3';'Fz';'F4';'F8';'FT7';'FC3';'FCz';'FC4';'FT8';'T7';'C3';'Cz';'C4';'T8';'TP7';'CP3';'CPz';'CP4';'TP8';'P7';'P3';'Pz';'P4';'P8';'O1';'Oz';'O2';'PO1';'PO2';};
winSize = 1; %in seconds
cates = [176 173 172 175 171 174];
subs = 1:5;
superCellAlphaPower = cell(length(cates),length(subs));
superCellBetaPower = cell(length(cates),length(subs));
superCellThetaPower = cell(length(cates),length(subs));
for isub=subs
    Raw_sub=loadeegdata(Subjects{isub},'rootdir',datadir,'datadir',datafolder);
    Raw_sub.sel_chan_list=sel_chan_list;
    %[base_power_alpha base_power_beta]=baseline(Raw_sub);
    stimIndices = getStartEndOfTrials(Raw_sub, Subjects{isub});
    for icate=1:length(cates)
        cat = cates(icate); 
        TrialCell = getTrials(Raw_sub, stimIndices, cat);
        %TrialCell= cellarray_category(Raw_sub, cat); 
        [AlphaPowerMatrix BetaPowerMatrix ThetaPowerMatrix]=GetPower(TrialCell, Raw_sub.sampling_rate, cat);
        %supermatrix(:,:,1:size(outData,3),icate,isub) = outData;
        nR=size(AlphaPowerMatrix,1);
        superCellAlphaPower{icate,isub} = AlphaPowerMatrix;%-base_power_alpha(1:nR,:);
        superCellBetaPower{icate,isub} = BetaPowerMatrix;%-base_power_beta(1:nR,:);
        superCellThetaPower{icate,isub} = ThetaPowerMatrix;
    end
    
end
