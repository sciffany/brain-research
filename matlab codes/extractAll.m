%takes a segment of signal from EEG data
%returns a vector of timings and a vector of amplitudes

function [signalMatrix] = extract(startTime, signalLength, EEGdata)

endTime = startTime + signalLength - 1;
i = (startTime:endTime)     % counter 
signalMatrix = EEGdata(:, i);  % signal
    

