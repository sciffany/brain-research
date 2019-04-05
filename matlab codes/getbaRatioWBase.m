%y is the EEG data for 1 trial
%should take the baRatio for 1 trial
%baRatio

function baRatioWBase = getbaRatioWBase(y, baseline)

detrend_y = detrend(y);
detrend_base = detrend(baseline);


b_d_y = beta(detrend_y);
b_squared = b_d_y.^2;
b_power = sum(b_squared)/1500;

b_d_base = beta(detrend_base);
b_squared_base = b_d_base.^2;
b_power_base = sum(b_squared_base)/1500;

a_d_y = alpha(detrend_y);
a_squared = a_d_y.^2;
a_power = sum(a_squared)/1500;

a_d_base = alpha(detrend_base);
a_squared_base = a_d_base.^2;
a_power_base = sum(a_squared_base)/1500;

b_power = b_power - b_power_base;
a_power = a_power - a_power_base;

baRatioWBase = b_power./a_power;