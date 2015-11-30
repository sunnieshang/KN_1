function [cumul_head_prob, cumul_average]=Month_Inspect(fname,data_info, post_sampler)
% plot sample AR pair   
if strcmp(fname, 'PSBP_5_Sample_Routes.csv')==1
    name = {'5January','5Feburary','5March','5April','5October','5November','5December'};
elseif strcmp(fname,'PSBP_Whole.csv')==1
    name = {'January','Feburary','March','April','October','November','December'};
end
month = linspace(1,7,7);
cumul_head_prob = zeros(length(month),3);
cumul_average = zeros(length(month),3);
parfor i=1:length(month)        
    incomplete_pred_info = struct('category_predictor',[NaN,NaN,NaN,month(i),NaN,NaN], ...
    'continuous_predictor',[NaN,NaN,NaN,NaN,NaN], 'sampler_num',10);
    [real_y,cumul_density,~, axis, cumul_head_prob(i,:), cumul_average(i,:), ~] = ...
        Cumul_Estimate(data_info, incomplete_pred_info, post_sampler); 
    Visual_Test(real_y,axis, cumul_density, name{i})
end
HeadProb_Comp(cumul_head_prob, name) 
Mean_Comp(cumul_average, name) 

    
    
    