%load data
function [pxxMatrix freq]=GetPxx(TrialCell,window, sfreq)

overlap=0.5*window;
nfft=2*2^nextpow2(window);

%you can do the detrend first because detrend can operate on matrices
%(faster than doing for each)
processedData = TrialCell;

bDetrend = false;

if bDetrend == false
    for iTrial=1:size(TrialCell,1)
        processedData{iTrial} = processedData{iTrial}';
    end
else
    for iTrial=1:size(TrialCell,1)
       processedData{iTrial} = detrend(processedData{iTrial}');
    end
end

%filter
for iTrial=1:size(TrialCell,1)
   filteredData= highlowfilter(processedData{iTrial},sfreq );
   TrialIndex=ceil(sfreq*0.5):size(filteredData,1)-ceil(sfreq *0.5)-1;
   processedData{iTrial} =filteredData(TrialIndex,:);
end


pxxMatrix=nan((nfft/2)+1,size(TrialCell{end},1),size((TrialCell),1));

for TrialNo=1:1:size((TrialCell),1);
    %only 3 trials in each catogory!
    dataIn=processedData{TrialNo};
    for ChannelNo=1:1:size(dataIn,2)
        %detrend it
        %DetrendedData=detrend(UndetrendedData);
        %DetrendedData = DetrendedDataAll{TrialNo}
        
        
        %filter into bands
        %FilteredData=highlowfilter(DetrendedData);
        
        %pwelch
        
        [pxx,freq]= pwelch(dataIn(:,ChannelNo),window,overlap,nfft,sfreq);
        pxxMatrix(:,ChannelNo,TrialNo)=pxx;
    end
    
    %scripts to subplot pwelch
    %{
plot it
subplot(2,2,TrialNo);
plot(freq,10*log10(pxx))
xlim([0,40])
ylim([-5,5])
title(strcat('Trial ',num2str(TrialNo),' PSD'))
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
    %}
    
end

%scripts for ave
%{
subplot (2,2,4);
ave_pxx=mean(pxxMatrix,2);
plot(freq,10*log10(ave_pxx))
xlim([0,40])
ylim([-5,5])
title(strcat('Average PSD'))
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
%}

end

