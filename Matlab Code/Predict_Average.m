function average = Predict_Average(data_info, predict_info, thinned_sampler)
% Only calcualte average of ONE conditional density
omega = Predict_Omega(data_info, predict_info, thinned_sampler);         
average = sum(omega.*thinned_sampler.mu,2);

