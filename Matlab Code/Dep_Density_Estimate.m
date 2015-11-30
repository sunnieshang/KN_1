function density_estimates = Dep_Density_Estimate...
                            (density_info, data_info, sampler, lower, upper, chain_start)
% generate density sampler for each route
%   density_info: route-airline combination information
%   data_info: need levels_in_factors
%   lower: lower bound of the y we want to calculate density
%   upper: upper bound of the y we want to calculate density
    
    omega = sampler.omega;
    phi = sampler.phi;
    level = sampler.level;
    factor = sampler.factor;
    [iter, n_cluster] = size(level);

    levels_in_factors = data_info.levels_in_factors;
    sub = levels_in_factors;
        sub(2) = levels_in_factors(1)+levels_in_factors(2);
        sub(3) = sub(2) + levels_in_factors(3);
    
    airline = [density_info(:).airline];
    route = [density_info(:).route]+sub(1);
    al_rt = [density_info(:).al_rt]+sub(2);
    name = {density_info(:).name};
    
    n_plot = length(airline);
    %density_estimates = cell(n_plot,1);
    t = lower: 1 : upper;
    t_length = length(t);
    
    n_chain = length(chain_start);
    omega_s = zeros(n_chain, n_cluster);
    factor_s = zeros(n_chain, sub(3));
    level_s = zeros(n_chain, n_cluster);
    phi_s = zeros(n_chain,n_cluster);
    for i=1:n_chain
        omega_s(i,:) = chain_start{i}.omega;
        factor_s(i,:) = chain_start{i}.factor;
        level_s(i,:) = chain_start{i}.level;
        phi_s(i,:) = chain_start{i}.phi;
    end
    
    for i = 1:n_plot
        if ~isnan(airline(i)) && ~isnan(route(i))
            alpha = factor(:,airline(i))+factor(:,route(i))+factor(:,al_rt(i));
            alpha_s = factor_s(:,airline(i))+factor_s(:,route(i))+factor_s(:,al_rt(i));
        elseif ~isnan(airline(i)) && isnan(route(i))
            alpha = factor(:,airline(i))+factor(:,al_rt(i));  
            alpha_s = factor_s(:,airline(i))+factor_s(:,al_rt(i));
        elseif isnan(airline(i)) && ~isnan(route(i))
            alpha = factor(:,route(i))+factor(:,al_rt(i));   
            alpha_s = factor_s(:,route(i))+factor_s(:,al_rt(i));
        else
            alpha = zeros(iter,1);  
            alpha_s = zeros(n_chain,1);
        end
        q=zeros(iter,t_length);
        q_s = zeros(n_chain, t_length);
        for j=1:1:n_cluster
            sim=repmat(omega(:,j),1,t_length).*...
                       normpdf(repmat(t,iter,1)...
                               ,repmat(alpha+level(:,j),1,t_length)...
                               ,1./sqrt(repmat(phi(:,j),1,t_length)));
            sim_s=repmat(omega_s(:,j),1,t_length).*...
                       normpdf(repmat(t,n_chain,1)...
                               ,repmat(alpha_s+level_s(:,j),1,t_length)...
                               ,1./sqrt(repmat(phi_s(:,j),1,t_length)));
            q=q+sim;
            q_s = q_s + sim_s;
        end
                                                    
        density_estimates(i).matrix = q;
        density_estimates(i).name = name{i};
        density_estimates(i).y = t;
        density_estimates(i).start = q_s;
    end
end