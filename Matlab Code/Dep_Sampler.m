function Sampler = Dep_Sampler(data_info, model_setup, chain_start)
% Jan 16 2014    
    %% free structure inputs to speed up code
    levels_in_factors = data_info.levels_in_factors;
    sub = levels_in_factors;
        sub(2) = sub(1)+sub(2);
        sub(3) = sub(2)+sub(3);
    dep = data_info.dep;
    n1 = length(dep);
    indep = data_info.indep;
    n_factor = data_info.n_factor;
    clear data_info;

    iter = model_setup.iter;
    prior = model_setup.prior;
    n_cluster = model_setup.n_cluster;
    clear model_setup;

    prior_phi_a = prior.phi_a;
    prior_phi_b = 1/prior.phi_s;
%     prior_factor_xi = prior.factor_xi;
    prior_factor_xi_a = prior.factor_xi_a;
    prior_factor_xi_b = 1/prior.factor_xi_s;
    prior_level_xi_a = prior.level_xi_a;
    prior_level_xi_b = 1/prior.level_xi_s;
%     prior_level_xi = prior.level_xi; 
    prior_level_nu = prior.level_nu;
    prior_factor_nu = prior.factor_nu;
    prior_omega = prior.omega;
    clear prior; 
    
%     posterior_phi_a = prior_phi_a + n1/2;
    posterior_factor_xi_a = prior_factor_xi_a + levels_in_factors/2;
    posterior_level_xi_a = prior_level_xi_a + n_cluster/2;
    %% initialize samplers
    omega = ones(iter, n_cluster);
    level = ones(iter, n_cluster);
    factor = ones(iter, sum(levels_in_factors)); 
    factor_xi = ones(iter, n_factor);
    level_xi = ones(iter, 1);
    phi = ones(iter, n_cluster);
%     phi = ones(iter, 1);
        % starting point
        omega(1,:) = chain_start.omega;
        level(1,:) = chain_start.level;
        factor(1,:) = chain_start.factor;
        factor_xi(1,:) = chain_start.factor_xi;
        level_xi(1,:) = chain_start.level_xi;
        phi(1,:) = chain_start.phi;
%         phi(1) = chain_start.phi;
    clear chain_start;

    %% anonymous functions to use
    err2 = @(y, mu) sum((y-mu)'*(y-mu),1);
    update_phi = @(a, b) gamrnd(a, 1./b, [1, length(a)]);
    post_xi = @(n, prior_xi, phi) phi*n+prior_xi; % phi is a row vector
    post_nu = @(post_xi, prior_xi, phi, mid, prior_nu) (prior_nu.*prior_xi + phi*mid)./post_xi;
   
    %% wait bar setup
%     hdl=waitbar(0,'Generating chain...');
%     set(hdl,'Name','MCMC status');
%     hmsg=get(findobj(hdl,'Type','Axes'),'xlabel');
%     set(hmsg,'HorizontalAlignment','left');
%     set(hmsg,'Position',[0,-1]);
    
    %% Gibbs sampler
    for i = 2:1:iter
%         % set up initial time
%         if i==2
%             t0 = clock;
%         end
%         % wait bar
%         if mod(i,100)==3
%             hh=i/iter;
%             secs = etime(clock,t0)*(1-hh)/hh;
%             mins = floor(secs/60);
%             secs = ceil(secs - 60*mins);
%             hrs  = floor(mins/60);
%             mins = mins - hrs*60;
%             waitbar(i/iter, hdl, sprintf('Generating Dep chain (%g:%02g:%02g left)',...
%                     hrs,mins,secs));
%             drawnow;
%         end
        alpha = repmat(indep*factor(i-1,:)', 1, n_cluster)+repmat(level(i-1,:),n1,1);  
        pro = normpdf(repmat(dep,1,n_cluster), alpha, 1./sqrt(repmat(phi(i-1,:),n1,1)));
        pro = pro.*repmat(omega(i-1,:),n1,1);
        pro = pro./repmat(sum(pro,2),1,n_cluster);   
        index = mnrnd(ones(n1,1),pro);
        nc = index'*index; % number of each cluster
%         nc=sum(index,1);
        
        % update phi
        new_b = err2(index.*repmat(dep,1,n_cluster), index.*alpha)/2;
%         new_b = err2(dep, sum(index.*alpha,2))/2;
        phi(i,:) = update_phi(prior_phi_a+sum(nc,1)/2, prior_phi_b+new_b);
%         phi(i) = update_phi(posterior_phi_a, prior_phi_b+new_b);
        % Update omega
        omega(i,:) = sample_dirichlet(prior_omega+sum(nc,1), 1); 
        
        % Update level
%         xi = post_xi(nc, level_xi(i-1), phi(i));
        xi = post_xi(nc, level_xi(i-1), phi(i,:));
        alpha = repmat(dep-indep*factor(i-1,:)', 1, n_cluster).*index;
%         alpha = dep-indep*factor(i-1,:)';
        mid = alpha'*index;
        mu = post_nu(xi, level_xi(i-1), phi(i,:), mid, prior_level_nu);
        level(i,:) = normrnd(mu, 1./sqrt(xi));

        nar = index'*indep;
%         nar = sum(indep,1);
        
        alpha = repmat(dep-indep(:,sub(1)+1:sub(3))*factor(i-1,sub(1)+1:sub(3))'...
                       -index*level(i,:)', 1, n_cluster).*index; 
%         alpha = dep-indep(:,sub(1)+1:sub(3))*factor(i-1,sub(1)+1:sub(3))'...
%                 -index*level(i,:)'; 
        xi = post_xi(nar(:,1:sub(1)), factor_xi(i-1,1), phi(i,:));
        mid = alpha'*indep(:, 1:sub(1));
        mu = post_nu(xi, factor_xi(i-1,1), phi(i,:), mid, prior_factor_nu(1:sub(1)));
        factor(i,1:sub(1))=normrnd(mu, 1./sqrt(xi));

        alpha = repmat(dep-indep(:,1:sub(1))*factor(i,1:sub(1))'...
                       -indep(:,sub(2)+1:sub(3))*factor(i-1,sub(2)+1:sub(3))'...
                       -index*level(i,:)', 1, n_cluster).*index; 
%         alpha = dep-indep(:,1:sub(1))*factor(i,1:sub(1))'...
%                 -indep(:,sub(2)+1:sub(3))*factor(i-1,sub(2)+1:sub(3))'...
%                 -index*level(i,:)';
        xi = post_xi(nar(:,1+sub(1):sub(2)), factor_xi(i-1,2), phi(i,:));
        mid = alpha'*indep(:, 1+sub(1):sub(2));
        mu = post_nu(xi, factor_xi(i-1,2), phi(i,:), mid, prior_factor_nu(1+sub(1):sub(2)));
        factor(i,1+sub(1):sub(2))=normrnd(mu,1./sqrt(xi));

        alpha = repmat(dep-indep(:,1:sub(2))*factor(i,1:sub(2))'...
                       -index*level(i,:)', 1, n_cluster).*index; 
%         alpha = dep-indep(:,1:sub(2))*factor(i,1:sub(2))'...
%                 -index*level(i,:)';
        xi = post_xi(nar(:,1+sub(2):sub(3)), factor_xi(i-1,3), phi(i,:));
        mid = alpha'*indep(:, 1+sub(2):sub(3));
        mu = post_nu(xi, factor_xi(i-1,3), phi(i,:), mid, prior_factor_nu(1+sub(2):sub(3)));
        factor(i,1+sub(2):sub(3))=normrnd(mu,1./sqrt(xi));

        % Update ANOVA hyper-parameter
        new_b = [err2(factor(i,1:sub(1))', prior_factor_nu(1:sub(1))'), ...
                 err2(factor(i,1+sub(1):sub(2))', prior_factor_nu(1+sub(1):sub(2))'), ...
                 err2(factor(i,1+sub(2):sub(3))', prior_factor_nu(1+sub(2):sub(3))')]/2;
        factor_xi(i,:) = update_phi(posterior_factor_xi_a, new_b+prior_factor_xi_b);
        new_b = err2(level(i,:)',prior_level_nu')/2;
        level_xi(i) = update_phi(posterior_level_xi_a, prior_level_xi_b+new_b);
    end
    % delete wait bar
%     if ishandle(hdl)
%         delete(hdl);
%     end
    Sampler = struct('factor', factor, 'level', level, ...
                     'phi', phi, 'omega', omega, 'factor_xi', factor_xi, 'level_xi', level_xi);
end

