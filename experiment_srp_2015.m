clear;
clc;
datadir = 'C:\Users\Tiffany\Documents\SRP\matlab\Matlab Reference\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';
subject = 'ZhengYang2Class\20130401';
Raw_sub = loadeegdata(subject,'rootdir', datadir,'datadir',dataTrainingFolder);

Raw_sub.EEG = double(Raw_sub.EEG)*Raw_sub.resolution;

chanName = 'C3';

%finds row number of channel
[rn, cn]=find(strcmp(Raw_sub.chan_list, chanName));

Fs = 250;                    % Sampling frequency
T = 1/Fs;                     % Sample time 
L = size(Raw_sub.EEG, 2);     % Length of signal 
t = (0:L-1)*T;                % Time vector
i = (1:L)                     % counter
y = Raw_sub.EEG(rn, i);
plot(Fs*t(1:1000),y(1:1000));

NFFT = 2^nextpow2(L); % Next power of 2 from length of y

Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')



