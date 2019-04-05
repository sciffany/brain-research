function TrialCell= cellarray_category( Raw_sub, icate )
%CELLARRAY_CATEGORY Summary of this function goes here
%get the cell array of each category and each subject
%   Detailed explanation goes here

%extract the selected channels
chan_index=nan(length(Raw_sub.sel_chan_list),1);

for ichan=1:1:length(Raw_sub.sel_chan_list);
    chan_index(ichan,:)=find(strcmp(Raw_sub.sel_chan_list{ichan},Raw_sub.chan_list)==1);
end
%the old wrong codes, just in case

for the wrong stimcodes recorded in tiffany's trial
%
if icate==176
    DisplayStimcode=find(Raw_sub.stimcode==icate|Raw_sub.stimcode==178);
else
    DisplayStimcode=find(Raw_sub.stimcode==icate);
end

DisplayStimpos=Raw_sub.stimpos(:,DisplayStimcode);
VideoLabel=Raw_sub.stimcode(:,DisplayStimcode);
%Getting the the labels of the 18 trials too i.e. sad, disgust etc

RatingStimcode=DisplayStimcode+1;
RatingStimpos=Raw_sub.stimpos(:,RatingStimcode);


ntrial=length(DisplayStimpos);
nchannel=length(Raw_sub.sel_chan_list);
nsec=0.5; %take less than 0.5s of starting point and more than 0.5s of ending pt
sfreq = Raw_sub.sampling_rate;

TrialCell=cell(ntrial,1);
%create an empty cell

for itrial=1:ntrial
    TrialIndex=(DisplayStimpos(itrial)-sfreq*nsec):(RatingStimpos(itrial)+sfreq*nsec);
    %index is a range of numbers defined as: starting number: ending number
    Trial=nan(nchannel,length(TrialIndex));
    Trial=(Raw_sub.resolution)*double (Raw_sub.EEG(chan_index,TrialIndex));
    TrialCell(itrial,:)={Trial};
end

end



