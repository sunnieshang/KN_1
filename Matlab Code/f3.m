function y = f3 (x)
    a = binornd(ones(length(x),1),0.5);
    y = a.* normrnd(10,2+4*exp(-min(x,0.5)),[length(x),1]) +...
        (1-a).*normrnd(-10+5*x,5,[length(x),1]);
