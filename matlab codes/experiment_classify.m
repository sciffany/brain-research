clear;
close all;
clc;
%datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
datadir = 'C:\Users\zy\Desktop\Tiffany\ProcessedData';
dataTrainingFolder = 'DataTraining';
subjects = {'XiaMian' 'Tiffany' 'ZhengYang' 'XiangJun' 'Yiheng'};
nSubjects = length(subjects);
sel_chan_no = [7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
sel_subj_no = 1:5;
Yh_excluded = [106 113 124];
Yh = [1:105 107:112 114:123 125:126]; %removed stim codes which display too high alpha and beta power
rateType =2; %1-valence by subj 2-arousal by subj %3-valence by IAPS %4-arousal by IAPS

%0 to strictly lower than 4
%4 to strictly lower than 6
%6 to strictly lower than 10 
% ratingLimits =  [0 4;...
%                  4 6;...
%                  6 10;...
%                  ];

ratingLimits = [0 3;...
                8 10]
nClasses = size(ratingLimits,1);

iband = 4; %1 = theta, 2 = alpha, 3 = beta, 4 = alpha and beta
%4 to 8 = theta; 8-12 = alpha; 12-40 = beta
switch iband
    case 1
        filterL = 4;
        filterH = 8;
    case 2
        filterL = 8;
        filterH = 12;
    case 3
        filterL = 12;
        filterH = 40;
    case 4
        filterL = [8 12];
        filterH = [12 40];
end
nBands = size(filterL,2);

%setting the constants
Fs = 250;                    % Sampling frequency
nSample = 6*Fs;             %Length of Sample
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L);                     % counter

nChs = size(sel_chan_no, 2);                  %Number of Channels

nOpen = 500;                 %Length of Open Eyes
halfSec = Fs/2;

bandPower_AllSubj = cell(1,nSubjects);
%PART I : get the bandpowers for subjects
%features should be X = ntrials x npowerfeatures for each subject
for subjNo = 1:size(subjects, 2)
    
    subject = subjects{subjNo};
    
    Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

    Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

    %TAKE VALENCE OR AROUSAL BASED ON SUBJ RATING
    stimLocations=find(Raw_sub.stimcode==240)-1;

%     if subjNo == 5
%         stimLocations = stimLocations(:, Yh);
%     end

    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);
    bandPower_list = nan(nTrials, nChs*nBands);
    for n = 1:nTrials
        %extracts the channel signal from channel and makes them vertical
        
        %filtering frequency
        for iBand = 1:nBands
            y =  extract(stimTimings(n)-halfSec, nSample+2*halfSec, Raw_sub.EEG, sel_chan_no);
            y = y';
            y = generalFilter(filterL(iBand),filterH(iBand),y);
            y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal
            
            %spatial common average reference filtering
            car = mean(y,2);
            y = y - repmat(car, [1 size(y,2)]);
            
            %finally the bandpowers
            squared = y.^2;
            y = sum(squared,1)/size(squared,1);
            if iBand == 1
               filteredData = y;
            else
               filteredData = [filteredData y]; 
            end
        end

        bandPower_list(n, :) = filteredData;
    end
    bandPower_AllSubj{subjNo} = bandPower_list;
end

%%
%PART II
%get the labels for each subject which should be a ntrials x 1
%SEGMENTS THE DATA INTO THREE CATEGORIES
ratings_AllSubj{subjNo} = cell(1,nSubjects);
for subjNo = sel_subj_no
    %finds subject's ratings
    subject = subjects{subjNo};
    ratingsGrid = findSubjRatings([datadir '\' subject], loadRatings());
    subjRating = nan(size(ratingsGrid, 1),1);
    for iRating= 1:nClasses
       currLimit = ratingLimits(iRating,:);
       idx2 = ratingsGrid(:,rateType)< currLimit(2);
       idx1 = ratingsGrid(:,rateType)>= currLimit(1);
       idx = idx2 & idx1;
       subjRating(idx) = iRating-1; 
    end
%     if subjNo == 5
%         subjRating = subjRating(Yh);
%     end
    ratings_AllSubj{subjNo} = subjRating;
end

%exceptions come here before any classification
if ~isempty(bandPower_AllSubj{5})
    bandPower_AllSubj{5}(Yh_excluded,:) = [];
    ratings_AllSubj{5}(Yh_excluded,:) = [];
end

%trials which are still not labeled i.e. nan are removed too
chance_acc = nan(1, nSubjects);
for subjNo = sel_subj_no
    idx = isnan(ratings_AllSubj{subjNo});
    bandPower_AllSubj{subjNo}(idx,:) = [];
    ratings_AllSubj{subjNo}(idx,:) = [];
    %display the number of occurences of each class
    nRatings = nan(1,nClasses);
    for iClass = 1:nClasses
        nRatings(iClass) = sum(ratings_AllSubj{subjNo} == iClass-1);
    end
    nRatings
    chance_acc(subjNo) = max(nRatings)/sum(nRatings) * 100;
end

%finally classify
nknn = 12;
cacc = nan(nknn, nSubjects);
cConMat=nan(nClasses,nClasses,nSubjects);
for iknn = 1:nknn
    for subjNo=  sel_subj_no
        %use ratio of the features
        xdata = bandPower_AllSubj{subjNo};
        for iBand=1:nBands
            idx = (1 + (iBand-1)*nChs):(nChs + (iBand-1)*nChs);
            s = sum(xdata(:,idx),2);
            s = repmat(s,[1 nChs]);
            if iBand == 1
                sumAcrossRows = s;
            else
                sumAcrossRows = [sumAcrossRows s];
            end
        end
        
        %sumAcrossRows = sum(xdata,2);
        xdata = log10(xdata./sumAcrossRows);
        
%         if iband == 4
%             xdata = (xdata./sumAcrossRows);
%             nCols = size(xdata,2);
%             temp = xdata(:, 1: nCols/2)./xdata(:,nCols/2 +1:end);
%             xdata =log10( temp);
%         else
%             xdata = (xdata./sumAcrossRows);
%         end

%kFolds = 0 is leave-one-out
        [cacc(iknn, subjNo)  cConMat(:,:,subjNo)]= classify(xdata,ratings_AllSubj{subjNo},0,iknn, 'kappa');
    end
    cacc(iknn,:)
    mean(cacc(iknn,:))
end