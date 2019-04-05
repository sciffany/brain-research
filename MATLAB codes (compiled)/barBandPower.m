clear;
close all;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
%datadir = 'C:\Users\zy\Desktop\Tiffany Progress 16 Dec 2015\ProcessedData';
dataTrainingFolder = 'DataTraining';
subjects = {'XiaMian' 'Tiffany' 'ZhengYang' 'XiangJun' 'Yiheng'};
sel_chan_no = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
sel_subj_no = 1:5;
Yh = [1:105 107:112 114:123 125:126];
rateType = 2; %1-valence by subj 2-arousal by subj %3-valence by IAPS %4-arousal by IAPS
lowLimit = 3; %for categories
highLimit = 10-lowLimit; %for categories
filterL = 8;
filterH = 12;
%4 to 8 = theta; 8-12 = alpha; 12-40 = beta

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
        ny = y';
        
        y = generalFilter(filterL,filterH,ny);
        b = generalFilter(12,35,ny);
        y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal
        b = b(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal

        %spatial common average reference filtering
        car = mean(y,2);
        y = y - repmat(car, [1 size(y,2)]);   

        car = mean(b,2);
        b = b - repmat(car, [1 size(b,2)]);  

        %gets beta-alpha ratio
        squared = y.^2;
        bsquared = b.^2;
        bandPower = sum(squared,1)/size(squared,1);
        bbandPower = sum(bsquared,1)/size(bsquared,1);
        %bandPower_list(n, :) = bandPower;
        bandPower_list(n, :) = bbandPower./bandPower;

    end

    %sumAcrossRows = repmat(sum(bandPower_list,2), 1, nChs);    
    %bandPower_list = bandPower_list./sumAcrossRows;
   
    bandPower_AllSubj{subjNo} = bandPower_list;
    
end

% %PLOTS THE GRAPH OF 1 CHANNEL
% rows = 2;
% columns = 4;
% total = rows*columns;
% 
% for subjNo = sel_subj_no
%     if rem(subjNo,total)== 1
%             figure;
%     end
%     plotSpot = rem(subjNo,total);
%     if plotSpot == 0 
%         plotSpot = total;
%         
%     end
%     %legend(Raw_sub.chan_list(sel_chan_no(1:32)));
%     subplot(rows,columns, plotSpot);
%     
%     bandPower_list = bandPower_AllSubj{subjNo};
%     subject = subjects{subjNo};
% 
%     
%     ratingsGrid = findSubjRatings(subject, loadRatings());
%     if subjNo == 5
%         ratingsGrid = ratingsGrid(Yh, :);
%     end
%     
%     x = ratingsGrid(:, 1);    
%     y = bandPower_list(:, 25);
% 
%     % for m = 1:nChs
%     %     coeffs(:, m) = polyfit(x, y(:,m), 1);
%     %end
%     
%     scatter(x,y);
%     hold on;
%     coeffs = polyfit(x, y, 1);
%     %Get fitted values
%     fittedX = linspace(min(x), max(x), 200);
%     fittedY = polyval(coeffs, fittedX);
%     %Plot the fitted line
%     % Plot the fitted line
%     hold on;
%     plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
%     
% end

%SEGMENTS THE DATA INTO THREE CATEGORIES
%bandPowerAll = nan(size(sel_subj_no, 2), 3, nChs);
for subjNo = sel_subj_no
    
    bandPower_list = bandPower_AllSubj{subjNo};
    subject = subjects{subjNo};
    
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
        bandPowerChosen = bandPower_list(subjRating(rating,:), :);
        bandPowerMean = mean(bandPowerChosen);
        bandPowerMeanList(rating, :) = bandPowerMean;

    end
    bandPowerDifference = bandPowerMeanList(3,:) - bandPowerMeanList(1,:);
    %bandPowerAll(subjNo, :, :)=  bandPowerMeanList;
    bandPowerAll(subjNo, :)=  bandPowerDifference;
    %newVar = sum(bandPowerMeanList, 2);
    %ANS(subjNo, :)=  newVar;
    
end
%bar(ANS);
%PLOTS THE BAR CHARTS
rows = 2;
columns =3;
total = rows*columns;
sel = [3 5 7 8 10 11 15];
for chan = 1:6
    channel = sel(chan);
    if rem(channel,total)== 1
       %figure;
    end
    plotSpot = rem(chan,total);
    if plotSpot == 0 
        plotSpot = total;
        
    end
    %legend(Raw_sub.chan_list(sel_chan_no(1:32)));
    subplot(rows,columns, plotSpot);

    bar(squeeze(bandPowerAll(:,channel)));
    ylim([-1 1.5]);
    xLabel('Subjects');
    yLabel('Beta-Alpha Ratio Difference');
    title(Raw_sub.chan_list(sel_chan_no(channel)));
    hold on;    
    
end

% Check whether mean is increasing or decreasing
% A = compileMatrix(1,:)>compileMatrix(2,:) & compileMatrix(2,:)>compileMatrix(3,:);
% Y = Raw_sub.chan_list(A==1);
% 
% B = compileMatrix(1,:)<compileMatrix(2,:) & compileMatrix(2,:)<compileMatrix(3,:);
% Z = Raw_sub.chan_list(B==1);

