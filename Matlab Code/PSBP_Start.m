
function Start = PSBP_Start(n_cluster, data_info, prior)
    % Use this function to generate the starting point of probit stick-breaking MCMC chain
    rng('shuffle');
    Start.phi            = gamrnd  (prior.phi_a,          prior.phi_s,          [1, n_cluster]);
    Start.mu             = normrnd (prior.mu_nu,          1./sqrt(prior.mu_xi), [1, n_cluster]);
    n_category           = size    (data_info.category_predictor, 2);
    Start.category_xi    = gamrnd  (prior.category_xi_a,  prior.category_xi_s,  [1, n_category]);
    Start.level_xi       = gamrnd  (prior.level_xi_a,     prior.level_xi_s,     1); 
    Start.level          = normrnd (prior.level_nu,       Start.level_xi,       [1, n_cluster-1]);
    levels_in_category   = max     (data_info.category_predictor,  [],  1);
    sub                  = [0,     levels_in_category];
    Start.category       = zeros   (1,  sum(sub));       
    for i  =  2: n_category+1 
        sub(i)  = sub(i)  +  sub(i-1);
        Start.category(2+sub(i-1): sub(i)) = normrnd (0, 1/sqrt(Start.category_xi(i-1)), [1,levels_in_category(i-1)-1]);
    end   
    n_continuous         = size(data_info.continuous_predictor, 2);   
    if n_continuous > 0
        Start.continuous = normrnd(0, 1/sqrt(prior.continuous_xi)/5, [1,n_continuous]);
    end 
end

