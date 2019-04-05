function bandPower = getBandPower(lowLimit, highLimit, y)
    
    %GENERAL FILTER
    y3 = generalFilter(lowLimit, highLimit, y);
    %GET POWER
    squared = y3.^2;
    bandPower = sum(squared)/size(y3,1);
