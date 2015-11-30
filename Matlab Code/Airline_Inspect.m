function [cumul_head_prob, cumul_average, cumul_uo_ratio, cumul_cost1, cumul_cost2, cumul_cost3]=Airline_Inspect(fname, data_info, post_sampler)
% plot sample AR pair   
cost1 = @(x) x;
cost2 = @(x) x.^2 ;
cost3 = @(x) x>=18;
[airline,name] = Airline_Index(fname);
cumul_head_prob = zeros(length(airline),3);
cumul_average = zeros(length(airline),3);
cumul_uo_ratio = zeros(length(airline),3);
cumul_cost1 = zeros(length(airline),3);
cumul_cost2 = zeros(length(airline),3);
cumul_cost3 = zeros(length(airline),3);
parfor i=1:length(airline)        
    incomplete_pred_info = struct('category_predictor',[airline(i),NaN,NaN,NaN,NaN,NaN], ...
    'continuous_predictor',[NaN,NaN,NaN,NaN,NaN], 'sampler_num',10);
    [real_y,density, ~, axis, cumul_head_prob(i,:), cumul_average(i,:), cumul_uo_ratio(i,:)] = ...
            Cumul_Estimate(data_info, incomplete_pred_info, post_sampler); 
    Visual_Test(real_y,axis, density, name{i})
    cost = Cost_Integrate(cost1, density, axis);
    cumul_cost1(i,:) = [quantile(cost,[0.025,0.975]),mean(cost)];
    cost = Cost_Integrate(cost2, density, axis);
    cumul_cost2(i,:) = [quantile(cost,[0.025,0.975]),mean(cost)];
    cost = Cost_Integrate(cost3, density, axis);
    cumul_cost3(i,:) = [quantile(cost,[0.025,0.975]),mean(cost)];
end
HeadProb_Comp(cumul_head_prob, name) 
Mean_Comp(cumul_average, name) 

    
    
    