function [predict,error] = ForecastError(testdata_info, gibbs_sampler)
% calculate multiple predict conditional density function 
observation_num = length(testdata_info.dep);
sampler_num = 1;
predict = zeros(observation_num, sampler_num);
for i = 1: observation_num
    predict_info = struct('category_predictor',testdata_info.category_predictor(i,:), ...
        'continuous_predictor',testdata_info.continuous_predictor(i,:), 'sampler_num',sampler_num);
    predict(i) = Predict_Y (testdata_info, predict_info, gibbs_sampler);
end
error = sqrt(sum((predict-testdata_info.dep).^2)/observation_num);
