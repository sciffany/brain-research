%y is the EEG data for 1 trial
%should take the baRatio for 1 trial
%baRatio

function baRatio = getbaRatio(y)

%y= detrend(y);

b_d_y = generalFilter(12,40, y);
b_squared = b_d_y.^2;
b_power = sum(b_squared)/1500;

a_d_y = generalFilter(8, 12, y);
a_squared = a_d_y.^2;
a_power = sum(a_squared)/1500;

baRatio = b_power./a_power;