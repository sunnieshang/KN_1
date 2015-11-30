function cost = Cost_Integrate(cost_func, density, axis)
    sampler_num = size(density,1);
    cost=density.*repmat(cost_func(axis),sampler_num,1);
    cost = cost(:,2:end);
    cost = cost .* repmat(diff(axis),sampler_num,1);
    cost = sum(cost,2);
    
