clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'XiaMian';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

electrode_pairing = {'F7', 'F8'; 'F3', 'F4';'T3','T4'};

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

%finds subject's ratings
ratingsGrid = findSubjRatings(subject);

%returns a set of boolean values to classify the three types of valence
subjValence(1,:) = ratingsGrid(:,1)>6;
subjValence(2,:) = ratingsGrid(:,1)<7 & ratingsGrid(:,2)>3;
subjValence(3,:) = ratingsGrid(:,1)<4;

%finds row number of channel
%chanName = 'TP7';
%[rn, cn]=find(strcmp(Raw_sub.chan_list, chanName));

%setting the constants
nChs = 40;                  %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                 %Length of Open Eyes
nClose = 3000;               % Length of Close Eyes

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter


%EXTRACT A CERTAIN TRIAL
for valence = 1:3
    %Takes stimtimings given the subject's valence
    
    
    stimLocations=find(Raw_sub.stimcode==240);
    stimLocations = stimLocations(subjValence(valence,:)) -1; %finds the position of stimcodes with that valence value
    
    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    
    baseLocations = stimLocations - 2;
    baseTimings = Raw_sub.stimpos(baseLocations);
    
    %Takes stimtimings given the supposed arousal
    %{
    baseStim = 229 + arousal;

    stimLocations=find(Raw_sub.stimcode==baseStim | Raw_sub.stimcode==baseStim+3 | Raw_sub.stimcode==baseStim+6);
    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    %}


    for n = 1:nTrials
        %does stuff for 1 trial
        
        %extracts the channel signal from channel and makes them vertical
        y =  extractAll(stimTimings(1), nSample, Raw_sub.EEG);
        y = y';
        
        bandPower = getBandPower(8, 12, y);
        bpPerTrial(nTrials, :) = bandPower;
        
        %gets signal for baseline
        %baseline = extractAll(baseTimings(n), nClose, Raw_sub.EEG);
        %baseline = baseline';

        %gets baRatio for the signal
        %baRatio = getbaRatioWBase(y, baseline);
        %ba_ratio_list(n, :) = baRatio;

    end
    
    

end

