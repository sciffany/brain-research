clear;
close all;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subjects = {'XiaMian' 'Tiffany' 'ZhengYang' 'XiangJun' 'Yiheng'};
sel_chan_no = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
pair_no = [7 11; 8 10; 12 16; 13 14; 17 21; 18 20; 22 26; 23 25; 28 32; 29 31; 34 36; 39 40];
sel_subj_no = 1:5;
Yh = [1:105 107:112 114:123 125:126];
rateType = 	1;
lowLimit = 4;
highLimit = 10-lowLimit;


%setting the constants
nChs = size(sel_chan_no, 2);                  %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                 %Length of Open Eyes
halfSec = 125;


Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter

bandPower_AllSubj = {};
for subjNo = 1:size(subjects, 2)
    
    subject = subjects{subjNo};
    
    Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

    Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;
    


    %TAKE VALENCE OR AROUSAL BASED ON SUBJ RATING
    stimLocations=find(Raw_sub.stimcode==240)-1;

    if subjNo == 5
        stimLocations = stimLocations(:, Yh);
    end

    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    bandPower_list = nan(nTrials, nChs);
    for n = 1:nTrials

        %extracts the channel signal from channel and makes them vertical
        y =  extract(stimTimings(n)-halfSec, nSample+2*halfSec, Raw_sub.EEG, sel_chan_no);
        y = y';
        
        y = generalFilter(4,40,y);
        y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal

        %spatial common average reference filtering
        car = mean(y,2);
        y = y - repmat(car, [1 size(y,2)]);   


        %gets alpha
        bandPower = getbandPower(4,6,y);
        bandPower_list(n, :) = bandPower;
    end
    
    pair_ch = zeros(size(pair_no, 1), size(pair_no, 2), nChs);
    for iPair = 1:size(pair_no, 1)
        
         pair_ch(iPair, 1, :) = sel_chan_no == pair_no(iPair,1);
         pair_ch(iPair, 2, :) = sel_chan_no == pair_no(iPair,2);
    
    end
    leftChs = logical(sum(pair_ch(:,1,:), 1));
    rightChs = logical(sum(pair_ch(:,2,:), 1));
    bandPowerSelect = zeros(nTrials, size(pair_no, 1), size(pair_no, 2));
    
    bandPowerSelect(:,:,1) = bandPower_list(:,leftChs);
    bandPowerSelect(:,:,2) = bandPower_list(:,rightChs);
    
    alphaAsym = log(bandPowerSelect(:,:,2)./bandPowerSelect(:,:,1));
    
    bandPower_AllSubj{subjNo} = alphaAsym;
end


%SEGMENTS THE DATA INTO THREE CATEGORIES
for subjNo = sel_subj_no
    
    
    alphaAsym = bandPower_AllSubj{subjNo};
    subject = subjects{sel_subj_no};

    nChs = size(alphaAsym, 2);
    
    %finds subject's ratings
    ratingsGrid = findSubjRatings(subject, loadRatings());
    subjRating = false(3, size(ratingsGrid, 1));
    subjRating(1,:) = ratingsGrid(:,rateType)<lowLimit;
    subjRating(2,:) = ratingsGrid(:,rateType)<=highLimit & ratingsGrid(:,rateType)>=lowLimit;
    subjRating(3,:) = ratingsGrid(:,rateType)>highLimit;
    
    if subjNo == 5
        subjRating = subjRating(:,Yh);
    end
    
    bandPowerMeanList = nan(size(subjRating,1), nChs);
    
    for rating = 1:size(subjRating,1)
        nTrial = size(find(subjRating(rating,:)), 2);
        bandPowerChosen = alphaAsym(subjRating(rating,:), :);
        bandPowerMean = mean(bandPowerChosen);
        bandPowerMeanList(rating, :) = bandPowerMean;

    end
    bandPowerAll(subjNo, :, :)=  bandPowerMeanList;
end

%PLOTS THE BAR CHARTS
rows = 3;
columns = 4;
total = rows*columns;

for channel = 1:nChs
    if rem(channel,total)== 1
            figure;
    end
    plotSpot = rem(channel,total);
    if plotSpot == 0 
        plotSpot = total;
    end
    subplot(rows,columns, plotSpot);

    bar(bandPowerAll(:,:,channel));
    title(Raw_sub.chan_list(pair_no(channel,1)));
    hold on;    
    
end

% Check whether mean is increasing or decreasing
% A = compileMatrix(1,:)>compileMatrix(2,:) & compileMatrix(2,:)>compileMatrix(3,:);
% Y = Raw_sub.chan_list(A==1);
% 
% B = compileMatrix(1,:)<compileMatrix(2,:) & compileMatrix(2,:)<compileMatrix(3,:);
% Z = Raw_sub.chan_list(B==1);

