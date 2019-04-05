clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'XiaMian';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;
fileList = loadRatings();

%finds subject's ratings
ratingsGrid = findSubjRatings(subject, fileList);

%returns a set of boolean values to classify the three types of arousal
subjArouse(1,:) = ratingsGrid(:,2)>6;
subjArouse(2,:) = ratingsGrid(:,2)<7 & ratingsGrid(:,2)>3;
subjArouse(3,:) = ratingsGrid(:,2)<4;

%finds row number of channel
chanName = 'T7';
[rn, cn]=find(strcmp(Raw_sub.chan_list, chanName));

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
chList = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
for channel = 1:size(chList, 2)
    if rem(channel,8)== 1
            figure;
    end
    plotSpot = rem(channel,8);
    if plotSpot == 0 
        plotSpot = 8
    end
    subplot(2,4, plotSpot);

    for arousal = 1:3
        %Takes stimtimings given the subject's arousal
        %stimLocations=find(Raw_sub.stimcode==240);
        %stimLocations = stimLocations(subjArouse(arousal,:)) -1; %finds the position of stimcodes with that arousal value

        %nTrials = size(stimLocations, 2);
        %stimTimings = Raw_sub.stimpos(stimLocations);

        %baseLocations = stimLocations - 2;
        %baseTimings = Raw_sub.stimpos(baseLocations);

        %Takes stimtimings given the supposed arousal    
        baseStim = 229 + arousal;

        stimLocations=find(Raw_sub.stimcode==baseStim | Raw_sub.stimcode==baseStim+3 | Raw_sub.stimcode==baseStim+6);
        nTrials = size(stimLocations, 2);
        stimTimings = Raw_sub.stimpos(stimLocations);

        for n = 1:nTrials
            %does stuff for 1 trial

            %extracts the channel signal from channel and makes them vertical
            y =  extract(stimTimings(n)-125, nSample+250, Raw_sub.EEG, chList(channel));
            %y = y';

            y = detrend(y);
            y = generalFilter(4, 40, y);
            y = y(125:1750);

            NFFT = 2^nextpow2(L); % Next power of 2 from length of y

            pxx = pwelch(y, 250, 125);
            pxxList(:, n) = pxx;


        end
        pxxList = pxxList';
        pxxAve = mean(pxxList);
        pxxList = pxxList';
        color = ['r' 'b' 'g'];  
        plot(10*log10(pxxAve), color(arousal));
        title(Raw_sub.chan_list(chList(channel)));
        hold on;
        ylabel('dB')
        axis([0,50,10,30]);
        
        

    end
    
end