%y is the EEG data for all channnels for 1 trial
%should take the baRatio for channels in 1 trial
%baRatio

function baRatios = getbaRatioAll(y)

detrend_y = detrend(y);

b_d_y = generalFilter(12, 40, detrend_y);
b_squared = b_d_y.^2;
b_power = sum(b_squared)/1500;

a_d_y = generalFilter(8, 12, detrend_y);
a_squared = a_d_y.^2;
a_power = sum(a_squared)/1500;

baRatios = b_power./a_power;