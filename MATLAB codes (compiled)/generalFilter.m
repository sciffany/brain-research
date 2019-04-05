function y3 = generalFilter(lowLimit, highLimit, y)
    
    %DETREND
    y = detrend(y);

    % HIGHPASS
    Wp_H = [lowLimit]/125;
    Ws_H = [lowLimit-2]/125;
    Apass_H = 3;
    Astop_H = 50;

    [n_H, Ws_H] = cheb2ord(Wp_H, Ws_H, Apass_H, Astop_H);

    [b, a] = cheby2(n_H, Astop_H, Ws_H, 'high');

    y2 = filter(b,a,y);

    %LOWPASS
    Wp_L = [highLimit]/125;
    Ws_L = [highLimit+ 1]/125;
    Apass_L = 3;
    Astop_L = 50;

    [n_L, Ws_L] = cheb2ord(Wp_L, Ws_L, Apass_L, Astop_L);

    [d, c] = cheby2(n_L, Astop_L, Ws_L);

    y3 = filter(d,c,y2);
    