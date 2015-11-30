function Start=Dep_Start2(N_cluster, N_factor, Levels_in_factors)
    % Use this function to generate the starting point of MCMC chain
        % (1) weight of each cluster (vector: 1*n_cluster): 
        %       start.omega ~ dirichlet(1/n_cluster, 1/n_cluster, ...)
        % (2) baseline of each cluster (vector: 1*n_cluster):
        %       start.level ~ normal(0,30)
        % (3) anova factors (3 cells):
        %       start.factor{i} ~ normal(0,30)
        % (4) precision of factors (vector: 1*n_factor):
        %       start.xi_factor ~ gamma(1, scale=0.001)
        % (5) precision of observation y:
        %       start.phi ~ gamma(1, scale=0.001)
    Start.omega = sample_dirichlet(ones(1,N_cluster), 1);
    %Start.omega = [mnrnd(1, 2*ones(1,N_cluster/2)/N_cluster),mnrnd(1, 2*ones(1,N_cluster/2)/N_cluster)];
    Start.level = normrnd(0,70,[1,N_cluster]);
    Start.factor = normrnd(0,70,[1,sum(Levels_in_factors)]);
    Start.factor_xi = gamrnd(2, 0.0002, [1,N_factor]);
    Start.level_xi = gamrnd(2, 0.0002, 1);
    Start.phi = gamrnd(2,0.00015,[1, N_cluster]);
%     Start.phi = gamrnd(2,0.001,1);
end



