function [cumul_head_prob, cumul_average, cumul_cushion, stock]=ARPair_Inspect(fname, data_info, post_sampler)
% plot sample AR pair   
delay_level=0;
service_level=0.9;
[airline, route, al_rt,name] = AR_Index(fname); 
cumul_head_prob = zeros(length(route),3);
cumul_average = zeros(length(route),3);
cumul_cushion = zeros(length(route),3);
stock = zeros(length(route),3);
parfor i=1:length(route)        
    incomplete_pred_info = struct('category_predictor',[airline(i),route(i),al_rt(i),NaN, NaN,NaN], ...
    'continuous_predictor',[NaN,NaN,NaN,NaN,NaN], 'sampler_num',10);
    [real_y,cumul_density, cumul_cdf, axis, cumul_head_prob(i,:), cumul_average(i,:),~] = ...
        Cumul_Estimate(data_info, incomplete_pred_info, post_sampler); 
    Visual_Test(real_y,axis, cumul_density, name{i})
    cumul_cushion(i,:)=Schedule_proposal(delay_level, service_level, cumul_cdf, axis);
    stock(i,:)=Safety_Stock(cumul_density, axis);
end 
HeadProb_Comp(cumul_head_prob, name) 
Mean_Comp(cumul_average, name) 
