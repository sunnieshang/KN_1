function MLE_Estimate = MLE(data_info, model_setup, chain_start)
    mu = model_setup.mu;
    levels_in_factors = data_info.levels_in_factors;
    sub = levels_in_factors;
        sub(2) = sub(1)+sub(2);
        sub(3) = sub(2)+sub(3);
    dep = data_info.dep;
    n = length(dep);
    indep = data_info.indep;
    
    %calculate the log-likelihood function
    function f = log_likelihood(factor_level_phi)
        n_cluster = length(mu);
        omega = zeros(n,n_cluster);
        alpha = repmat(factor_level_phi(indep(:,1))'+...
            factor_level_phi(sub(1)+indep(:,2))'+factor_level_phi(sub(2)+indep(:,3))'...
            , 1, n_cluster-1)+repmat(factor_level_phi(sub(3)+1:sub(3)+n_cluster-1),n,1); 
        omega(:,1)= normcdf(alpha(:,1));
        for j=2:n_cluster-1
            omega(:,j) = (ones(n,1)-sum(omega(:,1:j-1),2)).*normcdf(alpha(:,j));
        end 
        omega(:,n_cluster) = ones(n,1)-sum(omega(:,1:n_cluster-1),2);
        f = -sum(log(sum(omega.*...
            normpdf(repmat(dep,1,n_cluster), repmat(mu,n,1), ...
            1./sqrt(repmat(factor_level_phi(sub(3)+n_cluster:end),n,1))), 2)));
    end

    % starting point of optimization
    level = chain_start.level;
    factor = chain_start.factor;
    phi = chain_start.phi;
    x0=[factor,level,phi];
    % optimization
    options = optimset('MaxFunEvals', 1e12, 'MaxIter', 1e12...
        ,'TolFun',1e-6, 'TolX',1e-6);
    [x_search,fval_search] = fminsearch(@log_likelihood, x0, options);
    [x_unc,fval_unc] = fminunc(@log_likelihood, x0, options);
    MLE_Estimate.factor_search = x_search(1:sub(3));
    MLE_Estimate.level_search = x_search(1+sub(3):sub(3)+n_cluster-1);
    MLE_Estimate.phi_search = x_search(sub(3)+n_cluster-1:end);
    MLE_Estimate.factor_unc = x_unc(1:sub(3));
    MLE_Estimate.level_unc = x_unc(1+sub(3):sub(3)+n_cluster-1);
    MLE_Estimate.phi_unc = x_unc(sub(3)+n_cluster-1:end);
end