function BetaData=BetaBand(unfilteredData,sfreq)
Apass=3;
Astop=50;
%30dB is not enough to get rid of all the noise at around 0 Hz. 50 is more
%appropriate.

%highpass filter
Whp=12/(sfreq/2);
Whs=10/(sfreq/2);
[nh,Whs]=cheb2ord(Whp,Whs,Apass,Astop);
[dh,ch]=cheby2(nh,Astop,Whs,'high');

%figure;
%freqz(dh,ch);

%lowpass filter
Wlp=40/(sfreq/2);
Wls=41/(sfreq/2);
[nl,Wls]=cheb2ord(Wlp,Wls,Apass,Astop);
% automatatically find the order
[dl,cl] = cheby2(nl,Astop,Wls); % by default bandpass
% !!order of the filter cannot be too high >7 else the filter doesn't
% work()unstable
% doc signal/cheby2 for highpass bandpass bandstop

%figure;
%freqz(dl,cl);

BetaData=filter(dl,cl,unfilteredData);
BetaData=filter(dh,ch,BetaData);