function cont_eeg=ReadBatchContEEG(data_path, data_fn)

iNumFile=length(data_path);

cont_eeg=[];

for id=1:iNumFile
    cont_eeg=ReadContEEG(fullfile(data_path{id}, data_fn{id}));
    if(~isempty(cont_eeg)) break;end;
end

if(isempty(cont_eeg)) return;end;

for id=id+1:iNumFile
    eeg_id=ReadContEEG(fullfile(data_path{id}, data_fn{id}));
    if(isempty(cont_eeg)) continue;end;
    eeg_id.stimpos=eeg_id.stimpos+size(cont_eeg.EEG,2);
    cont_eeg.EEG=[cont_eeg.EEG eeg_id.EEG];
    cont_eeg.stimcode=[cont_eeg.stimcode eeg_id.stimcode];
    cont_eeg.stimpos=[cont_eeg.stimpos eeg_id.stimpos];
    %added by ZY in the event there are erroneous stimcodes
    cont_eeg.codelist=unique([cont_eeg.codelist eeg_id.codelist]);
end

for iStimCode=1:length(cont_eeg.codelist)
    cont_eeg.codenum(iStimCode)=sum(cont_eeg.stimcode==cont_eeg.codelist(iStimCode));
end
