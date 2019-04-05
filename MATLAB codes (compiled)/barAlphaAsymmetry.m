clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subjects = {'XiaMian' 'Tiffany' 'ZhengYang' 'XiangJun' 'Yiheng'};
sel_chan_no = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
pair_no = [7 11; 8 10; 12 16; 13 14; 17 21; 18 20; 22 26; 23 25; 28 32; 29 31; 34 36; 39 40];
sel_subj_no = 1:5;
Yh = [1:105 107:112 114:123 125:126];
rateType =  1;
lowLimit = 3;
highLimit = 10-lowLimit;


%setting the constants
nChs = size(sel_chan_no, 2);                  %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                 %Length of Open Eyes
halfSec = 125;
nPairs = size(pair_no, 1);

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter

    
pair_ch = zeros(nPairs, 2, nChs);
for iPair = 1:nPairs

     pair_ch(iPair, 1, :) = sel_chan_no == pair_no(iPair,1);
     pair_ch(iPair, 2, :) = sel_chan_no == pair_no(iPair,2);

end
leftChs = squeeze(pair_ch(:,1,:));
rightChs = squeeze(pair_ch(:,2,:));


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
        
        y = generalFilter(9,12,y);
        y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal

        %spatial common average reference filtering
        car = mean(y,2);
        y = y - repmat(car, [1 size(y,2)]);   

        %gets bandpower
        squared = y.^2;
        bandPower = sum(squared,1)/size(squared,1);
        bandPower_list(n, :) = bandPower;
    end

    
    bandPowerSelect = zeros(nTrials, nPairs, 2);
    
     for iPair = 1:nPairs
        
        bandPowerSelect(:,iPair,1) = bandPower_list(:,find(leftChs(iPair,:)));
        bandPowerSelect(:,iPair,2) = bandPower_list(:,find(rightChs(iPair,:)));
    
     end

     alphaAsym = log(bandPowerSelect(:,:,2)./bandPowerSelect(:,:,1));
     bandPower_AllSubj{subjNo} = alphaAsym;
end


%PLOTS THE GRAPH OF 1 CHANNEL
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
%     y = bandPower_list(:, 3);
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
for subjNo = sel_subj_no

    alphaAsym = bandPower_AllSubj{subjNo};
    subject = subjects{subjNo};

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
    bandPowerDifference = bandPowerMeanList(3,:) - bandPowerMeanList(1,:);
    %bandPowerAll(subjNo, :, :)=  bandPowerMeanList;
    bandPowerAll(subjNo, :)=  bandPowerDifference;
end

% for subjNo = sel_subj_no
% 
%     idx = (1 + (iBand-1)*nChs):(nChs + (iBand-1)*nChs);
%     s = sum(xdata(:,idx),2);
%     s = repmat(s,[1 nChs]);
%     if iBand == 1
%         sumAcrossRows = s;
%     else
%         sumAcrossRows = [sumAcrossRows s];
%     end
% end
 
%PLOTS THE BAR CHARTS
rows = 2;
columns = 2;
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

    bar(bandPowerAll(:,channel));
    %legend('Valence 1-3', 'Valence 4-6', 'Valence 7-9');
    ylim([-0.2 0.4]);
    xLabel('Subjects');
    yLabel('Theta (4-6) Asymmetry Difference');
    title(Raw_sub.chan_list(pair_no(channel,1)));
    hold on;    
    
    
end

% Check whether mean is increasing or decreasing
% A = compileMatrix(1,:)>compileMatrix(2,:) & compileMatrix(2,:)>compileMatrix(3,:);
% Y = Raw_sub.chan_list(A==1);
% 
% B = compileMatrix(1,:)<compileMatrix(2,:) & compileMatrix(2,:)<compileMatrix(3,:);
% Z = Raw_sub.chan_list(B==1);

