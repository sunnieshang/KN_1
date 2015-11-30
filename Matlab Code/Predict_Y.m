function predict_y = Predict_Y(data_info, predict_info, gibbs_sampler)
% only calculate predictions based on ONE conditional density    
% the index put in this function must be the right indexes, no NaN
thinned_sampler = Thin_Sampler (gibbs_sampler, predict_info.sampler_num);
omega = Predict_Omega(data_info, predict_info, thinned_sampler);           
Im  =  mnrnd(ones(size(omega,1),1),omega);
predict_y =  sum(Im.*normrnd(thinned_sampler.mu,1./sqrt(thinned_sampler.phi)), 2);
