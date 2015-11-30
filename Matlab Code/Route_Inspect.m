function [cumul_head_prob, cumul_average]=Route_Inspect(fname, data_info, post_sampler)  
[route, name] = Route_Index(fname); 
cumul_head_prob = zeros(length(route),3);
cumul_average = zeros(length(route),3);
parfor i=1:length(route)        
    incomplete_pred_info = struct('category_predictor',[NaN,route(i),NaN,NaN,NaN,NaN], ...
        'continuous_predictor',[NaN,NaN,NaN,NaN,NaN], 'sampler_num',10);
    [real_y,cumul_density,~, axis, cumul_head_prob(i,:), cumul_average(i,:), ~] = ...
            Cumul_Estimate(data_info, incomplete_pred_info, post_sampler); 
    Visual_Test(real_y,axis, cumul_density, name{i})
end
HeadProb_Comp(cumul_head_prob, name) 
Mean_Comp(cumul_average, name) 


    
    
    