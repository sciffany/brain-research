clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'Yiheng';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);
sel_chan_no = [3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 34 35 36 39 40];
indexes = [1:105 107:112 114:123 125:126];
Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

%finds subject's ratings
ratingsGrid = findSubjRatings(subject, loadRatings());


%setting the constants
nChs = size(sel_chan_no,2);                %Number of Channels
nSample = 1500;             %Length of Sample
nOpen = 500;                 %Length of Open Eyes

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                 % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter


%Takes stimtimings given the subject's arousal
stimLocations=find(Raw_sub.stimcode==240);
stimLocations = stimLocations -1; %finds the position of stimcodes with that arousal value

nTrials = size(stimLocations, 2);
stimTimings = Raw_sub.stimpos(stimLocations);

for n = 1:nTrials
    %does stuff for 1 trial
    
    %extracts the channel signal from channel and makes them vertical
    y =  extract(stimTimings(n), nSample, Raw_sub.EEG, sel_chan_no);
    y = y';

    %spatial common average reference filtering
%     car = mean(y,2);
%     y = y - repmat(car, [1 size(y,2)]);    

    %gets baRatio for the signal
    bandPower = getBandPower(12,30,y);
    bandPower_list(n, :) = bandPower;

end

%PLOTS THE BAR CHARTS
rows = 2;
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
    x = ratingsGrid(:, 1);
    x = x(indexes, :);
    yA = bandPower_list(:, channel);
    yA = yA(indexes, :);
    scatter(x,yA);
    hold on;
    coeffs = polyfit(x, yA, 1);
    %Get fitted values
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    %Plot the fitted line

    plot(fittedX, fittedY, 'r-', 'LineWidth', 3);

    yLabel('EEG Feature');
    xLabel('Valence Ratings');
    title(Raw_sub.chan_list(sel_chan_no(channel)));
    hold on;    
    
end





