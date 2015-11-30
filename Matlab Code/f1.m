function y = f1 (x)
    a = binornd(ones(length(x),1),0.5);
    y = a.* normrnd(1,1,[length(x),1]) + (1-a).*normrnd(-1,0.5,[length(x),1]);
