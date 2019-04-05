clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'XiangJun';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);
Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;
fileList = loadRatings();
ratingsGrid = findSubjRatings(subject, fileList);

electrode_pairing = {'F7', 'F8'; 'F3', 'F4';'FT7','FT8';'FC3','FC4';'T7','T8';'TP7','TP8';'CP3','CP4'};

pairNo = 2;
for pairNo = 3
    
    %finds row number of channel
    chanNameA = electrode_pairing(pairNo,1);
    chanNameB = electrode_pairing(pairNo,2);
    [rnA, cnA]=find(strcmp(Raw_sub.chan_list, chanNameA));
    [rnB, cnB]=find(strcmp(Raw_sub.chan_list, chanNameB));

    rn = [rnA, rnB];

    %setting the constants
    nChs = 40;                  %Number of Channels
    nSample = 1500;             %Length of Sample
    nOpen = 500;                 %Length of Open Eyes
    halfSec = 125;

    Fs = 250;                    % Sampling frequency
    T = 1/Fs;                    % Sample time 
    L = nSample;                 % Length of signal 
    t = (0:L-1)*T;               % Time vector
    i = (1:L)                    % counter


    %Takes stimtimings given the subject's valence
    stimLocations=find(Raw_sub.stimcode==240);
    stimLocations = stimLocations -1; %finds the position of stimcodes with that valence value

    nTrials = size(stimLocations, 2);
    stimTimings = Raw_sub.stimpos(stimLocations);

    for n = 1:nTrials
        %does stuff for 1 trial

        %extracts the channel signal from channel and makes them vertical
        y =  extract(stimTimings(n)-halfSec, nSample+2*halfSec, Raw_sub.EEG, rn);
        y = y';
        y = y(halfSec:nSample+halfSec - 1, :); %cuts off the half a second before and after the signal
        y =  generalFilter(8,12,y);
        %spatial common average reference filtering
        %car = mean(y,2);
        %y = y - repmat(car, [1 size(y,2)]);   
       
        %gets alpha asymmetry index for signal
        squared = y.^2;
        alphaPower = mean(y,1);
        %alphaPower = getBandPower(8, 12, y);
        %betaPower = getBandPower(12, 40, y);
        %asymIndex = (alphaPower(1)-alphaPower(2))*(alphaPower(1)+alphaPower(2));
        asymIndex = log(alphaPower(2)/alphaPower(1));
        asymIndexList(n, 1) = asymIndex;



    end

    x = ratingsGrid(:, 1);
    y = asymIndexList;

    % for m = 1:nChs
    %     coeffs(:, m) = polyfit(x, y(:,m), 1);
    %end
    %PLOT THE SCATTER GRAPH AND TREND LINE
    subplot(2,4, pairNo);
    scatter(x,y);
    hold on;
    coeffs = polyfit(x, y, 1);
    %Get fitted values
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    %Plot the fitted line
    % Plot the fitted line
    hold on;
    plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
end


%{
nTrials = 14;
nChs = 40;
nSample = 1500;

everything = zeros(nChs, nSample, nTrials);

stimLocations=find(Raw_sub.stimcode==230);
stimTimings = Raw_sub.stimpos(stimLocations);

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = nSample;                % Length of signal 
t = (0:L-1)*T;                % Time vector
tbyf = meshgrid(0:L-1, 0:14)*T;
% howToAccessElementofCell = Raw_sub.EEG(rn, 2);

for n = 1:nTrials
    % plots a graph of 1 trial
    i = (stimTimings(n):stimTimings(n)+nSample-1) % counter
    y = Raw_sub.EEG(:, i);         %Get EEG data
    everything(:, :, n) = y(:,:);
    plot (Fs*t, y);
end


freq=-5:4;                     %10 vector
plane=meshgrid(1:4, 1:10);     %10x4 matrix
amp=randn([10,4]);             %10x4 matrix
plot3(freq,plane,amp);

xlabel('freq)');
ylabel('plane');
zlabel('amp');

%}
%{
chanName = 'C3';

%finds row number of channel
a = strcmp(Raw_sub.chan_list, chanName);
[rn, cn]=find(a);

% howToAccessElementofCell = Raw_sub.EEG(rn, 2);

Fs = 250;                    % Sampling frequency
T = 1/Fs;                    % Sample time 
L = size(Raw_sub.EEG, 2);     % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter
y = Raw_sub.EEG(rn, i);
plot(Fs*t(1:2000),y(1:2000));

Raw_sub.stimcode;
%}
%FILTER
%{
Fs = 250;  % Sampling Frequency

Fstop1 = 8;           % First Stopband Frequency
Fpass1 = 10;          % First Passband Frequency
Fpass2 = 12;          % Second Passband Frequency
Fstop2 = 14;          % Second Stopband Frequency
Astop1 = 60;          % First Stopband Attenuation (dB)
Apass  = 1;           % Passband Ripple (dB)
Astop2 = 80;          % Second Stopband Attenuation (dB)
match  = 'stopband';  % Band to match exactly

h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, Fs);
Hd = design(h, 'cheby2', 'MatchExactly', match);

y2 = filter(Hd,y);

plot(Fs*t(1:2000),y2(1:2000));


xlabel('Time (s)')
ylabel('Amplitude')
legend('Original Signal','Filtered Data')
%}

%FOURIER TRANSFORM
%{
NFFT = 2^nextpow2(L); % Next power of 2 from length of y

Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
%}
