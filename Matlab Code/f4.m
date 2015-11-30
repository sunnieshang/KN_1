function y = f4 (x)
y = zeros(length(x),1);
y(x<=1/6) = normrnd(-10,1,[length(x(x<1/6)),1]);
y(x>1/6 & x<=1/2) = normrnd(0,1,[length(x(x>1/6 & x<=1/2)),1]);
y(x>1/2 & x<=5/6) = normrnd(10,1,[length(x(x>1/2 & x<=5/6)),1]);
y(x>5/6) = normrnd(20,1,[length(x(x>5/6)),1]);

