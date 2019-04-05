function TrialCell = getTrials(Raw_sub, stimIndices, cat)

%extract the selected channels
chan_index=nan(length(Raw_sub.sel_chan_list),1);

for ichan=1:1:length(Raw_sub.sel_chan_list);
    chan_index(ichan,:)=find(strcmp(Raw_sub.sel_chan_list{ichan},Raw_sub.chan_list)==1);
end

idx = find(stimIndices(:,3) == cat);
ntrial=length(idx);
nsec=0.5; %take less than 0.5s of starting point and more than 0.5s of ending pt
sfreq = Raw_sub.sampling_rate;
TrialCell=cell(ntrial,1);

for itrial=1:ntrial
    TrialIndex = (stimIndices(idx(itrial),1)-sfreq*nsec):(stimIndices(idx(itrial),2)+sfreq*nsec);
    %index is a range of numbers defined as: starting number: ending number
    Trial=(Raw_sub.resolution)*double (Raw_sub.EEG(chan_index,TrialIndex));
    TrialCell(itrial,:)={Trial};
end

end


