function head_prob = Predict_HeadProb(data_info, predict_info, thinned_sampler)
% Only calcualte head/tail probability of ONE conditional density
omega = Predict_Omega(data_info, predict_info, thinned_sampler); 
%     tail_threshold = [    0,    12, 15.5,    24, 32.2,   48, 63.2,    72, 82.5,  99.3]; % 1-cdf
%     tail_perc =      [0.798, 0.888,  0.9, 0.938, 0.95, 0.97, 0.98, 0.987, 0.99, 0.995];
%     head_threshold = [-65.4, -51.5, -39.4, -24.9,   -24, -16.6,  -12]; % cdf
%     head_perc =      [0.005,  0.01,  0.02,  0.05, 0.054,   0.1, 0.15];
head_threshold = 12; % cdf
mid = 1-normcdf(head_threshold,thinned_sampler.mu,1./sqrt(thinned_sampler.phi)); 
head_prob = sum(omega.*mid, 2);
