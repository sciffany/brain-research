
%{
datadir='E:\BCI\matlab\raw data';
datafolder='DataTraining';
Raw_sub=loadeegdata('Xiangjun\20151204','rootdir',datadir,'datadir',datafolder);
sel_chan_list = {'F7';'F3';'Fz';'F4';'F8';'FT7';'FC3';'FCz';'FC4';'FT8';'T7';'C3';'Cz';'C4';'T8';'TP7';'CP3';'CPz';'CP4';'TP8';'P7';'P3';'Pz';'P4';'P8';'O1';'Oz';'O2';'PO1';'PO2';};
%}

function [base_power_alpha base_power_beta]=baseline(Raw_sub)
chan_index=nan(length(Raw_sub.sel_chan_list),1);
for ichan=1:1:length(Raw_sub.sel_chan_list);
    chan_index(ichan,:)=find(strcmp(Raw_sub.sel_chan_list{ichan},Raw_sub.chan_list)==1);
end

CBaselineStimcode=find(Raw_sub.stimcode==152);
CBaselineStimpos=Raw_sub.stimpos(:,CBaselineStimcode);

nchannel=length(Raw_sub.sel_chan_list);
duration=60; %in seconds
sfreq = Raw_sub.sampling_rate;
nsample=sfreq*duration;
nbaseline=length(CBaselineStimcode);

%create empty matrix (since they are of the same length)
Baseline=nan(nchannel,nsample,nbaseline);
for ibaseline=1:1:nbaseline;
    BaselineIndex=(CBaselineStimpos(ibaseline)-sfreq*60):(CBaselineStimpos(ibaseline)-1);
    Baseline(:,:,ibaseline)=(Raw_sub.resolution)*double (Raw_sub.EEG(chan_index,BaselineIndex));
end

%baseline power, averaged over the three sessions
base_power_alpha=nan(nbaseline,size(Baseline,1));
base_power_beta=nan(nbaseline,size(Baseline,1));
for ibaseline=1:1:nbaseline;
    BaselineData=Baseline(:,:,ibaseline);
    BaselineData=squeeze(BaselineData);
    BaselineData=detrend(BaselineData');
    AlphaBaseline=AlphaBand(BaselineData,sfreq);
    BetaBaseline=BetaBand(BaselineData,sfreq);
    base_power_alpha(ibaseline,:)=sum(AlphaBaseline.^2)/nsample;
    base_power_beta(ibaseline,:)=sum(BetaBaseline.^2)/nsample;
end 
%ave_base_power_alpha=mean(base_power_alpha);
%ave_base_power_beta=mean(base_power_beta);
end
