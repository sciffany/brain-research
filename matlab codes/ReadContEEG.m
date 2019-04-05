function ContEEG = ReadContEEG(DataFileName)
% ContEEG = ReadContEEG(DataFileName)
% Read CNT EEG data from file DataFileName
% Returned structure with the following elements
%       num_channel: 
%     sampling_rate:
%        resolution:
%               EEG: num_channel x sample
%           stimpos: 
%          stimcode: 
%          codelist: 
%           codenum: 

fprintf('Load Continuous EEG Data from %s ...\n', DataFileName);

% Read Head
[fp, msg] = fopen(DataFileName, 'rb');
if fp == -1
    error(sprintf('Cannot open file %s, message=%s.', DataFileName, msg));
end

ContEEG.num_channel = fread(fp, 1, 'int32');
iNumEvtPerSample = fread(fp, 1, 'int32');
iNumSplPerBlock = fread(fp, 1, 'int32');
ContEEG.sampling_rate = fread(fp, 1, 'int32');
iDataSize = fread(fp, 1, 'int32');
ContEEG.resolution = fread(fp, 1, 'float32');

Data = fread(fp, [ContEEG.num_channel + 1, inf], 'int32=>int32');
fclose(fp);

nLeastNumT=1;%seconds -- minimal duration
if(isempty(Data) | size(Data,2)< nLeastNumT*ContEEG.sampling_rate)
    ContEEG=[];return;
end

ContEEG.EEG = Data(1:ContEEG.num_channel, :);
%ContEEG.EEG = int32(Data(1:ContEEG.num_channel, :));

codes = bitand(double(Data(ContEEG.num_channel + 1, :)), 255);
codes1 = codes(2:end);
samecodes = find(codes1 ~= 0 & codes1 == codes(1:end-1));
if ~isempty(samecodes)
    samecodes = samecodes + 1;
    codes(samecodes) = 0;
end

ContEEG.stimpos = find(codes ~= 0);
ContEEG.stimcode = codes(ContEEG.stimpos);
his = zeros(1, 255);
for i = 1:length(ContEEG.stimcode)
his(ContEEG.stimcode(i)) = his(ContEEG.stimcode(i)) + 1;
end
ContEEG.codelist = find(his);
ContEEG.codenum = his(ContEEG.codelist);

%% define channel list
str_channel = [];
if ContEEG.num_channel == 40
    %4 channels have been renamed: T7 -> T3, T8 -> T4, P7 -> T5, P8 -> P6
    str_channel = 'HEOL,HEOR,Fp1,Fp2,VEOU,VEOL,F7,F3,Fz,F4,F8,FT7,FC3,FCz,FC4,FT8,T7,C3,Cz,C4,T8,TP7,CP3,CPz,CP4,TP8,A1,P7,P3,Pz,P4,P8,A2,O1,Oz,O2,FT9,FT10,PO1,PO2';
elseif ContEEG.num_channel == 66
    str_channel = 'Fp1,Fpz,Fp2,AF3,AF4,F7,F5,F3,F1,Fz,F2,F4,F6,F8,FT7,FC5,FC3,FC1,FCz,FC2,FC4,FC6,FT8,T7,C5,C3,C1,Cz,C2,C4,C6,T8,M1,TP7,CP5,CP3,CP1,CPz,CP2,CP4,CP6,TP8,M2,P7,P5,P3,P1,Pz,P2,P4,P6,P8,PO7,PO5,PO3,POz,PO4,PO6,PO8,CB1,O1,Oz,O2,CB2,VEO,HEO';
end

chan_sprs = find(str_channel == ',');

chan_list = [];
start = 1;
for i = 1:length(chan_sprs)
    stop = chan_sprs(i) - 1;
    if start < stop && isspace(str_channel(start))
        start = start + 1;
    end
    if start <= stop
        chan_list = strvcat(chan_list, str_channel(start:stop));
    end
    start = stop + 2;
end
stop = length(str_channel);
if start <= stop
    chan_list = strvcat(chan_list, str_channel(start:stop));
end
if ~isempty(chan_list)
    chan_list = cellstr(chan_list);
    ContEEG.chan_list = chan_list;
end

%% Insert a stimcode to mark the end of the datafile
iStimEndFile=-1;
ContEEG.stimcode=[ContEEG.stimcode iStimEndFile];
ContEEG.stimpos=[ContEEG.stimpos size(ContEEG.EEG,2)];
ContEEG.codelist=[ContEEG.codelist iStimEndFile];
ContEEG.codenum=[ContEEG.codenum 1];
