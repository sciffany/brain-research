function indices = getStartEndOfTrials(Raw_sub, subName)

stimcodeTrials = 171:176;
stimcodeEndTrials = 180;

%exceptions come here
if strfind(subName,'Tiffany');
   idx = Raw_sub.stimcode == 178;
   Raw_sub.stimcode(idx) = 176;
   idx = Raw_sub.stimcode == 182; 
   Raw_sub.stimcode(idx) = 180;
end


idxStart = false(size(Raw_sub.stimcode));
for istim=1:length(stimcodeTrials)
    idxStart = Raw_sub.stimcode == stimcodeTrials(istim) | idxStart;
end


% idxEndOld = false(size(Raw_sub.stimcode));
% for istim=1:length(stimcodeEndTrials)
%     idxEndOld = Raw_sub.stimcode == stimcodeEndTrials(istim) | idxEndOld;
% end

%then check through every stim start
index = find(idxStart);
idxEnd = nan(size(index));

for istim=1:length(index)
    ind = index(istim);
    ind = ind+1;
    while (Raw_sub.stimcode(ind) == 200)
        ind=ind+1;
        if (ind >= length(Raw_sub.stimcode))
           break;
        end
    end
    
    if (Raw_sub.stimcode(ind) == 180)
        idxEnd(istim) = Raw_sub.stimpos(ind);
    else
        error('please check');
    end
end

stims = Raw_sub.stimcode(idxStart);
startStimPos = Raw_sub.stimpos(index);
endStimPos = idxEnd;

indices = [ startStimPos(:) endStimPos(:) stims(:)];

end