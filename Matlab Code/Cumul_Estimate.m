function [real_y,cumul_density,cumul_cdf, axis, cumul_head_prob, cumul_average, cumul_uo_ratio] = Cumul_Estimate(data_info, incomplete_pred_info, post_sampler)
% this function is used to calculate culmulative density, examples include
[real_y, complete_pred_info] = Complete_Predictor(data_info, incomplete_pred_info);
% axis = linspace(quantile(real_y,0.02)-5, quantile(real_y,0.98)+5,100);
axis = linspace(-60,100,200);
for i=1:complete_pred_info.sampler_num
    for j=1:size(complete_pred_info.category_predictor,1);
        predict_info = struct('category_predictor',complete_pred_info.category_predictor(j,:),...
                          'continuous_predictor',complete_pred_info.continuous_predictor(j,:), ...
                          'sampler_num', 1);
        thinned_sampler = Thin_Sampler(post_sampler, 1);
        density = Predict_Density(data_info, predict_info, thinned_sampler, axis);
        cdf = Predict_Cdf(data_info, predict_info, thinned_sampler, axis);
        head_prob = Predict_HeadProb(data_info, predict_info, thinned_sampler);
        average = Predict_Average(data_info, predict_info, thinned_sampler);
        uo_ratio = Predict_UORatio(data_info, predict_info, thinned_sampler);
        if j==1
            mid_density = zeros(size(complete_pred_info.category_predictor,1),size(density,2));
            mid_density(1,:)=density;
            mid_cdf = zeros(size(complete_pred_info.category_predictor,1),size(density,2));
            mid_cdf(1,:)=cdf;
            mid_head_prob = zeros(1, size(complete_pred_info.category_predictor,1));
            mid_head_prob(1)=head_prob;
            mid_average = zeros(1, size(complete_pred_info.category_predictor,1));
            mid_average(1)=average;
            mid_uo_ratio = zeros(1, size(complete_pred_info.category_predictor,1));
            mid_uo_ratio(1)=uo_ratio;
        else
            mid_density(j,:) = density;
            mid_cdf(j,:) = cdf;
            mid_head_prob(j) = head_prob;
            mid_average(j)   = average;
            mid_uo_ratio(j)   = uo_ratio;
        end
    end
    if i==1
        cumul_density = zeros(complete_pred_info.sampler_num, size(mid_density,2));
        cumul_density(1,:) = mean(mid_density,1);
        cumul_cdf = zeros(complete_pred_info.sampler_num, size(mid_density,2));
        cumul_cdf(1,:) = mean(mid_cdf,1);
        cumul_head_prob2 = zeros(complete_pred_info.sampler_num, 1);
        cumul_head_prob2(1,:) = mean(mid_head_prob);
        cumul_average2 = zeros(complete_pred_info.sampler_num, 1);
        cumul_average2(1,:) = mean(mid_average);
        cumul_uo_ratio2 = zeros(complete_pred_info.sampler_num, 1);
        cumul_uo_ratio2(1,:) = mean(mid_uo_ratio);
    else 
        cumul_density(i,:) = mean(mid_density,1);
        cumul_cdf(i,:) = mean(mid_cdf,1);
        cumul_head_prob2(i,:) = mean(mid_head_prob);
        cumul_average2(i,:) = mean(mid_average);
        cumul_uo_ratio2(i,:) = mean(mid_uo_ratio);
    end
end
cumul_head_prob = [quantile(cumul_head_prob2,[0.025, 0.975]), mean(cumul_head_prob2)];
cumul_average = [quantile(cumul_average2,[0.025, 0.975]), mean(cumul_average2)];
cumul_uo_ratio = [quantile(cumul_uo_ratio2,[0.025, 0.975]), mean(cumul_uo_ratio2)];