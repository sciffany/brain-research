clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'Yiheng';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

%finds subject's ratings
ratingsGrid = findSubjRatings(subject, loadRatings());

%1=subject's valence rating
%2=subject's arousal rating
%3=IAPS valence rating
%4=IAPS arousal rating
rateType = 4;

%returns a set of boolean values to classify the three types of arousal
subjRating(1,:) = ratingsGrid(:,rateType)<4;
subjRating(2,:) = ratingsGrid(:,rateType)<6 & ratingsGrid(:,rateType)>4;
subjRating(3,:) = ratingsGrid(:,rateType)>6;

%setting the constants
nChs = 40;                  %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                 %Length of Open Eyes

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter

compileMatrix = zeros(3, 40);

%EXTRACT A CERTAIN TRIAL
for rating = 3
    
     %TAKE VALENCE OR AROUSAL BASED ON SUBJ RATING
    stimLocations=find(Raw_sub.stimcode==240);
    stimLocations = stimLocations(subjRating(rating,:)) -1; %finds the position of stimcodes with that rating value
    
    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    
    baseLocations = stimLocations - 2;
    baseTimings = Raw_sub.stimpos(baseLocations);
    bandPower_list = zeros(nTrials,nChs);

    for n = 1:nTrials
        %does stuff for 1 trial
        
        %extracts the channel signal from channel and makes them vertical
        y =  extractAll(stimTimings(n), nSample, Raw_sub.EEG);
        y = y';
        
        %gets baRatio for baseline


        %gets baRatio for the signal
        bandPower = getbandPower(12, 40, y);
        bandPower_list(n, :) = bandPower;

    end
    mean = sum(bandPower_list)/nTrials;
    
    compileMatrix(rating, :) = mean;

end

%Check for correlation
A = compileMatrix(1,:)>compileMatrix(2,:) & compileMatrix(2,:)>compileMatrix(3,:);
Y = Raw_sub.chan_list(A==1);

B = compileMatrix(1,:)<compileMatrix(2,:) & compileMatrix(2,:)<compileMatrix(3,:);
Z = Raw_sub.chan_list(B==1);

