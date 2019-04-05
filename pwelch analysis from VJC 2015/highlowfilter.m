function FilteredData=highlowfilter(unfilteredData, sfreq)
Apass=3;
Astop=50;
%30dB is not enough to get rid of all the noise at around 0 Hz. 50 is more
%appropriate.

%highpass filter
Whp=4/(sfreq/2);
Whs=2/(sfreq/2);
[nh,Whs]=cheb2ord(Whp,Whs,Apass,Astop);
[bh,ah]=cheby2(nh,Astop,Whs,'high');

%figure;
%freqz(bh,ah);

%lowpass filter
Wlp=40/(sfreq/2);
Wls=42/(sfreq/2);
[nl,Wls]=cheb2ord(Wlp,Wls,Apass,Astop);
% automatatically find the order
[bl,al] = cheby2(nl,Astop,Wls); % by default bandpass
% !!order of the filter cannot be too high >7 else the filter doesn't
% work()unstable
% doc signal/cheby2 for highpass bandpass bandstop
FilteredData=filter (bl,al, unfilteredData);
FilteredData=filter(bh,ah,FilteredData);
%figure;
%freqz(bl,al);
% not so good as the ripple exceeds Astop
%fdatool is used to design a filter, helpful tool to analyse the filter

