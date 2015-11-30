function [dic1,dic2, p_D1,p_D2,D_hat,d_bar, D_bar] = DIC(sampler, data_info)
% the smallest DIC predicts the best
sample_size=min(5000,size(sampler.mu,1));
n_cluster = size(sampler.mu,2);
mean_sampler = struct('category',mean(sampler.category,1),'level',mean(sampler.level,1),...
    'continuous',mean(sampler.continuous,1),'mu',mean(sampler.mu,1),'phi',mean(sampler.phi));
D_bar=zeros(sample_size,1);
D_hat = 0;
thinned_sampler =  Thin_Sampler(sampler, sample_size);
for i= 1: length(data_info.dep)
    if mod(i,2000)==1
        disp(i);
    end
    predict_info = struct('category_predictor',data_info.category_predictor(i,:),...
                      'continuous_predictor',data_info.continuous_predictor(i,:), ...
                      'sampler_num', 1);
    omega = Predict_Omega(data_info, predict_info, mean_sampler);
    D_hat = D_hat-2*log(omega*normpdf(data_info.dep(i),mean_sampler.mu,1./sqrt(mean_sampler.phi))');
    omega = Predict_Omega(data_info, predict_info, thinned_sampler);
    D_bar = D_bar -2*log(sum(omega.*normpdf(repmat(data_info.dep(i),sample_size,n_cluster),thinned_sampler.mu,1./sqrt(thinned_sampler.phi)),2));
end
d_bar = mean(D_bar);
p_D1 = d_bar - D_hat;
p_D2 = var(D_bar)/2;
dic1 = d_bar + p_D1;
dic2 = d_bar + p_D2;