%takes a segment of signal from EEG data
%returns a vector of timings and a vector of amplitudes

function [signalVector] = extract(startTime, signalLength, EEGdata, channelNo)

endTime = startTime + signalLength - 1;
i = (startTime:endTime);     % counter 
signalVector = EEGdata(channelNo, i);  % signal
    

