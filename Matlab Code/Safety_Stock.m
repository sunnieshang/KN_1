function stock = Safety_Stock(density, axis)
z = 0.95; ExpD=100; VarD=100;
sampler_num = size(density,1);

cost1 = @(x) x;
cost2 = @(x) x.^2;
VarLT=density.*repmat(cost2(axis),sampler_num,1);
VarLT = VarLT(:,2:end);
VarLT = VarLT .* repmat(diff(axis),sampler_num,1);
VarLT = sum(VarLT,2);
ExpLT=density.*repmat(cost1(axis),sampler_num,1);
ExpLT = ExpLT(:,2:end);
ExpLT = ExpLT .* repmat(diff(axis),sampler_num,1);
ExpLT = sum(ExpLT,2);   
    
mid = z.*sqrt(ExpLT.*VarD+VarLT.*ExpD);
stock = [quantile(mid,[0.025,0.975]),mean(mid)];
end