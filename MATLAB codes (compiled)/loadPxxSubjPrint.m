%function pxxSubj = loadPxxSubj(subject)
close all; clear;
iSubject = 1;
subjects = {'XiaMian', ...
			'Tiffany', ...
			'Yiheng', ...
			'Xiangjun',...
			'ZhengYang'}
rateType = 4;

%1=subject's valence rating
%2=subject's arousal rating
%3=IAPS valence rating
%4=IAPS arousal rating

subject =subjects{iSubject};
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
%datadir = 'C:\Users\zy\Desktop\Tiffany Progress 16 Dec 2015\ProcessedData';
dataTrainingFolder = 'DataTraining';

Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

%FINDS THE FOUR TYPES OF RATINGS BY COLUMN
%1=subject's valence rating
%2=subject's arousal rating
%3=IAPS valence rating
%4=IAPS arousal rating
ratingsGrid = findSubjRatings([datadir  '\'  subject], loadRatings());


%RETURNS THREE SETS OF BOOLEAN VALUES TO SPECIFY WHICH TRIALS BELONG
%TO EACH OF THE THREE CATEGORIES
subjRating(1,:) = ratingsGrid(:, rateType)>6;
subjRating(2,:) = ratingsGrid(:, rateType)<=6 & ratingsGrid(:,2)>=4;
subjRating(3,:) = ratingsGrid(:, rateType)<4;

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

% TAKES THE INDICES OF SELECTED CHANNELS
% sel_chan = Raw_sub.sel_chan_list;
% 
% nSelChan = size(sel_chan);
% sel_chan_no = zeros(nSelChan, 1);
% 
% for a = 1:nSelChan
%     channel = sel_chan(a, 1);
%     [rn, cn]=find(strcmp(Raw_sub.chan_list, channel));
%     sel_chan_no(a, 1) = rn;
% end

sel_chan_no = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];

nChs = size(sel_chan_no, 2); %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                %Length of Open Eyes
nClose = 3000;              %Length of Close Eyes
halfSec = 125;

Fs = 250;                   %Sampling frequency
T = 1/Fs;                   %Sample time 
L = nSample;                %Length of signal 
t = (0:L-1)*T;              %Time vector
i = (1:L)                   %counter

%pxxSubj = {};
%LOAD THE AVERAGE PWELCH'S PER CHANNEL FOR THREE CATEGORIES
for rating = 1:size(subjRating,1)

    
    %TAKES STARTING TIMES OF TRIALS
    stimLocations=find(Raw_sub.stimcode==240);
    stimLocations = stimLocations(subjRating(rating,:)) -1; %finds the position of stimcodes with that rating value
    
    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    
%     baseLocations = stimLocations - 2;
%     baseTimings = Raw_sub.stimpos(baseLocations);
    
    pxxCat = zeros(nTrials, 257, nChs);
    for n = 1:nTrials

        %extracts the channel signal from channel and makes them vertical
        y =  extract(stimTimings(n)-halfSec, nSample+halfSec*2, Raw_sub.EEG, sel_chan_no);
        y = y';

        %detrends and filters
        y = generalFilter(4, 40, y);
        y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal
        pxx = nan(size(pxxCat,2), size(pxxCat,3));
        
        %spatial common average reference filtering
        car = mean(y,2);
        y = y - repmat(car, [1 size(y,2)]);        
        
        
        for i=1:size(sel_chan_no, 2)

            %pxx(:,i) = pwelch(y(:,i), 250, 125); %Mine
            %pxx(:,i) = pwelch(y(:,i), 250, 125, 2^nextpow2(250), 250); %Yiheng's method
            [pxx(:,i),f] = pwelch(y(:,i), [], [], [], 250);

        end

        pxxCat(n,:,:) = pxx(:,:);
    end
    pxxAve = mean(pxxCat);  
    pxxSubj(rating, :, :) = pxxAve(1,:,:);
end

%PLOTS THE GRAPHS
rows = 2;
columns = 4;
total = rows*columns;
for channel = 1:nChs
    if rem(channel,total)== 1
            figure;
    end
    plotSpot = rem(channel,total);
    if plotSpot == 0 
        plotSpot = total
        legend('High', 'Mid', 'Low');
    end
    subplot(rows,columns, plotSpot);

    plot(f,(pxxSubj(:,:,channel)'));
    title(Raw_sub.chan_list(sel_chan_no(channel)));
    
    hold on;
    ylabel('dB');
    axis([0,50,0,5]);
        
    
end

