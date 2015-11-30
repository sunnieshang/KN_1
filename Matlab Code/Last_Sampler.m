function Start = Last_Sampler(post_sampler)
    % Use this function to generate the starting point of probit stick-breaking MCMC chain
    rng('shuffle');
    Start.phi            = post_sampler.phi(end,:);
    Start.mu             = post_sampler.mu(end,:);
    Start.category_xi    = post_sampler.category_xi(end,:);
    Start.level_xi       = post_sampler.level_xi(end,:); 
    Start.level          = post_sampler.level(end,:);
    Start.category       = post_sampler.category(end,:);       
    n_continuous         = size(post_sampler.continuous, 2);   
    if n_continuous > 0
        Start.continuous = post_sampler.continuous(end,:);
    end 
end

