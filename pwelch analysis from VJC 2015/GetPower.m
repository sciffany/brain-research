%load data
function [AlphaPowerMatrix BetaPowerMatrix ThetaPowerMatrix]=GetPower(TrialCell,sfreq, icate)

%you can do the detrend first because detrend can operate on matrices
%(faster than doing for each)
processedData = TrialCell;

%detrend
for iTrial=1:size(TrialCell,1)
    processedData{iTrial} = detrend(processedData{iTrial}');
end

%filter
AlphaData=cell(size(TrialCell));
BetaData=cell(size(TrialCell));
ThetaData=cell(size(TrialCell));
for iTrial=1:size(TrialCell,1)
    FilteredAlphaData= AlphaBand(processedData{iTrial},sfreq );
    FilteredBetaData= BetaBand(processedData{iTrial},sfreq );
    FilteredThetaData= ThetaBand(processedData{iTrial},sfreq );
    TrialIndex=ceil(sfreq*0.5):size(FilteredAlphaData,1)-ceil(sfreq *0.5)-1;
    AlphaData{iTrial} =FilteredAlphaData(TrialIndex,:);
    BetaData{iTrial}=FilteredBetaData(TrialIndex,:);
    ThetaData{iTrial}=FilteredThetaData(TrialIndex,:);
end

AlphaPowerMatrix=nan(size((TrialCell),1),size(TrialCell{end},1));
BetaPowerMatrix=nan(size((TrialCell),1),size(TrialCell{end},1));
ThetaPowerMatrix=nan(size((TrialCell),1),size(TrialCell{end},1));

for TrialNo=1:1:size((TrialCell),1);
    %only 3 trials in each catogory!
    AlphaDataIn=AlphaData{TrialNo};
    BetaDataIn=BetaData{TrialNo};
    ThetaDataIn=ThetaData{TrialNo};
    nsample=size(AlphaDataIn,1);
    power_alpha=sum(AlphaDataIn.^2)/nsample;
    power_beta=sum(BetaDataIn.^2)/nsample;
    power_theta=sum(ThetaDataIn.^2)/nsample;
    AlphaPowerMatrix(TrialNo,:)=power_alpha;
    BetaPowerMatrix(TrialNo,:)=power_beta;
    ThetaPowerMatrix(TrialNo,:)=power_theta;
end
end

% %ratio
% BAratio=(power_beta-ave_base_power_beta)/(power_alpha-ave_base_power_alpha);

%{
%use fft to check
Fs=250;
T=1/Fs;
L=size(BetaData,2);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(BetaData,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
figure;
% write figure so that the graph is plotted on a new figure, otherwise it
% is plotted on the same graph
plot(f,2*abs(Y(1:NFFT/2+1)))
axis([0,42,0,2])
title('AlphaData')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
%}







