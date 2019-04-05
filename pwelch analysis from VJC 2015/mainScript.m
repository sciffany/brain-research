clear;
clc;

%all the variables that will be tuned comes in the mainScript when possible
datadir='C:\Users\zy\Desktop\Yiheng Progress 11 Dec 2015\raw data';
datafolder='DataTraining';
Subjects={...
            'Tiffany\20151201',...
            'XiaMian\20151201',...
			'Xiangjun\20151204',...
            'Yiheng\20151207',...
            'ZhengYang\20151207',...
         };
sel_chan_list = {'F7';'F3';'Fz';'F4';'F8';'FT7';'FC3';'FCz';'FC4';'FT8';'T7';'C3';'Cz';'C4';'T8';'TP7';'CP3';'CPz';'CP4';'TP8';'P7';'P3';'Pz';'P4';'P8';'O1';'Oz';'O2';'PO1';'PO2';};
winSize = 1; %in seconds
cates = [171:176];
subs = 1:5;
supermatrix = cell(length(cates),length(subs));
for isub=subs
    Raw_sub=loadeegdata(Subjects{isub},'rootdir',datadir,'datadir',datafolder);
    for icate=1:length(cates)
        cat = cates(icate);
        Raw_sub.sel_chan_list=sel_chan_list;
        windowSize = winSize * Raw_sub.sampling_rate;
        TrialCell= cellarray_category(Raw_sub, cat); 
        outData=GetPxx(TrialCell, windowSize, Raw_sub.sampling_rate, cat);
        %supermatrix(:,:,1:size(outData,3),icate,isub) = outData;
        supermatrix{icate,isub} = outData;
    end
end