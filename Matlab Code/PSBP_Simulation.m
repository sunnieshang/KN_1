clc; clear all; close all;
observation_num = 1000;
simu_x = unifrnd (0, 1, [observation_num, 1]);
simu_y = f4(simu_x); 
data_info = struct('dep',simu_y,'category_predictor',zeros(length(simu_y),0),'continuous_predictor',simu_x);
n_cluster   = 10;   
prior       = PSBP_Prior(data_info,   n_cluster); 
model_setup = struct('n_cluster',n_cluster,'iteration',1000,'iter_part', 5,'burnin_part',2,'prior', prior);
sampler = PSBP_PostSampler(data_info, model_setup, prior);
%% Visual inspection of simulation test
test_x = 0.3;
predict_info = struct('category_predictor',zeros(1,0),'continuous_predictor',test_x, 'sampler_num', length(simu_y));
real_y = f4(repmat(test_x, [observation_num,1])); 
axis = linspace (-6, 25, 100);
thinned_sampler = Thin_Sampler(sampler, predict_info.sampler_num);
predict_density = Predict_Density(data_info, predict_info, thinned_sampler, axis);
Visual_Test(real_y, axis, predict_density, 'when x=0.9');
