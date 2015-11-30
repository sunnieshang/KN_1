function Sampler = FirstStage_Sampler(data_info, model_setup, chain_start)
% Different from original samplers, here the kernal mu is ordered
% Feb 13 2014; Using index of airline & route rather than the huge dummy matrix    
    %% free structure inputs to speed up code
    % make sure the first factor in each group equals to zero
%     levels_in_factors = data_info.levels_in_factors;
%     sub = levels_in_factors;
%         sub(2) = sub(1)+sub(2);
%         sub(3) = sub(2)+sub(3);
    dep = data_info.dep;
    n1 = length(dep);
%     indep = data_info.indep;
%     n_factor = data_info.n_factor;
    clear data_info;

    iter = model_setup.iter;
    prior = model_setup.prior;
    n_cluster = model_setup.n_cluster;
    clear model_setup;

    prior_phi_a = prior.phi_a;
    prior_phi_b = 1/prior.phi_s;
    prior_mu_xi = prior.mu_xi;
    prior_mu_nu = prior.mu_nu;
%     prior_factor_xi = prior.factor_xi;
%     prior_factor_xi_a = prior.factor_xi_a;
%     prior_factor_xi_b = 1/prior.factor_xi_s;
%     prior_factor_nu = prior.factor_nu;
%     prior_level_nu = prior.level_nu;
%     prior_level_xi_a = prior.level_xi_a;
%     prior_level_xi_b = 1/prior.level_xi_s;
%     prior_level_xi = prior.level_xi;
    clear prior; 
    
%    posterior_phi_a = prior_phi_a + n1/2;
%     posterior_factor_xi_a = prior_factor_xi_a + (levels_in_factors-1)/2;
%     posterior_level_xi_a = prior_level_xi_a + (n_cluster-1)/2;
    
    %% initialize samplers
    post_likelihood = zeros(iter,1);
%     omega = zeros(n1, n_cluster);
    omega_base = zeros(iter, n_cluster);
    mu = zeros(iter, n_cluster);
    phi = zeros(iter, n_cluster);
%     level = zeros(iter, n_cluster-1);
%     factor = zeros(iter, sum(levels_in_factors)); 
%     factor_xi = zeros(iter, n_factor);
%     level_xi = zeros(iter, 1);
        % starting point
%         level(1,:) = chain_start.level;
%         factor(1,:) = chain_start.factor;
%         factor_xi(1,:) = chain_start.factor_xi;
%         level_xi(1,:) = chain_start.level_xi;
        phi(1,:) = chain_start.phi;
        mu(1,:) = chain_start.mu;
        omega_base(1,:) = sample_dirichlet(1/n_cluster*ones(1,n_cluster), 1);
    clear chain_start;
    
    %% set up wait bar    
%     hdl=waitbar(0,'Generating chain...');
%     set(hdl,'Name','Stick-breaking MCMC status');
%     hmsg=get(findobj(hdl,'Type','Axes'),'xlabel');
%     set(hmsg,'HorizontalAlignment','left');
%     set(hmsg,'Position',[0,-1]);
    
    %% anonymous function
    err2 = @(y, mu) sum((y-mu)'*(y-mu),1);
    update_phi = @(a, b) gamrnd(a, 1./b, [1,length(a)]);
    post_xi = @(n, prior_xi, phi) n.*phi+prior_xi;
    post_nu = @(post_xi, prior_xi, phi, mid, prior_nu) (prior_nu.*prior_xi + mid.*phi)./post_xi;

    %% Computation: Gibbs sampling
    for i=2:iter
%         if i==2
%             t0 = clock;
%         end
%         % wait bar
%         if mod(i,100)==50
%             hh=i/iter;
%             secs = etime(clock,t0)*(1-hh)/hh;
%             mins = floor(secs/60);
%             secs = ceil(secs - 60*mins);
%             hrs  = floor(mins/60);
%             mins = mins - hrs*60;
%             waitbar(i/iter, hdl, sprintf('Generating chain (%g:%02g:%02g left)',...
%                     hrs,mins,secs));
%             drawnow;
%         end
%         alpha = repmat(factor(i-1,indep(:,1))'+factor(i-1,sub(1)+indep(:,2))'+factor(i-1,sub(2)+indep(:,3))'...
%             , 1, n_cluster-1)+repmat(level(i-1,:),n1,1); 
%         omega(:,1)= normcdf(alpha(:,1));
        % calculate base alpha and base omega
%         omega_base(i,1)=normcdf(level(i-1,1));
%         for j=2:n_cluster-1
%             omega(:,j) = (ones(n1,1)-sum(omega(:,1:j-1),2)).*normcdf(alpha(:,j));
%             omega_base(i,j) = (1-sum(omega_base(i,1:j-1)))*normcdf(level(i-1,j));
%         end  
%         omega(:,n_cluster) = ones(n1,1)-sum(omega(:,1:n_cluster-1),2);
%         omega_base(i,n_cluster) = 1 - sum(omega_base(i,1:n_cluster-1));
        Pos = normpdf(repmat(dep,1,n_cluster),repmat(mu(i-1,:),n1,1),1./sqrt(repmat(phi(i-1,:),n1,1)));
        Pos = Pos.*repmat(omega_base(i-1,:),n1,1);
        Pos = Pos./repmat(sum(Pos,2),1,n_cluster);   
        
        % Indicator matrix, record which cluster each observation is in
        Im = mnrnd(ones(n1,1),Pos);
%         Om = Im*tril(ones(n_cluster,n_cluster),-1);
%         Om = Om(:,1:n_cluster-1);
%         Z = norminv(unifrnd(0,normcdf(-Om.*alpha)), alpha, 1).*Om;
%         Z = Z+Im(:,1:n_cluster-1).*...
%               norminv(unifrnd(normcdf(-Im(:,1:n_cluster-1).*alpha),1), alpha, 1);
        % since the last column is not calcualted as the others, need to
        % cut off the last column. Falling into the last cluster means that
        % all the previous z_s are all negative.
%         index = Im(:,1:n_cluster-1)+Om;
        %Z = index.*(Z+alpha);
        
        % Update mixture normal mean  
        nc = sum(Im,1); % number of observations in each cluster
        xi = post_xi(nc, prior_mu_xi, phi(i-1,:));
        mid = sum(Im.*(repmat(dep,1,n_cluster)),1);
        nu = post_nu(xi, prior_mu_xi, phi(i-1,:), mid, prior_mu_nu);
        % mu(i,:)=normrnd(nu,1./sqrt(xi));
        % generate ordered mu
        mu(i,1)=normrnd(nu(1),1/sqrt(xi(1)));
        for j=2:n_cluster
            mu(i,j)=norminv(unifrnd(normcdf(mu(i,j-1),nu(j),1/sqrt(xi(j)))...
                                    ,1),nu(j),1/sqrt(xi(j)));
            if mu(i,j)==inf
                mu(i,j)=mu(i,j-1);
            end
        end
        
        
        % Update mixture normal precision
        phi_new_b = err2(repmat(dep,1,n_cluster).*Im, Im.*repmat(mu(i,:),n1,1));
        phi(i,:)=update_phi(prior_phi_a+nc/2, phi_new_b/2+prior_phi_b);  
        
%         % Update level 
%         no = sum(index, 1);
%         xi = post_xi(no, level_xi(i-1), 1);
%         alpha = repmat(factor(i-1,indep(:,1))'+factor(i-1,sub(1)+indep(:,2))'+factor(i-1,sub(2)+indep(:,3))'...
%             , 1, n_cluster-1);
%         mid = sum((Z-alpha).*index,1);
%         nu = post_nu(xi, level_xi(i-1), 1, mid, prior_level_nu);
%         level(i,:)=normrnd(nu,1./sqrt(xi));
%         
%         % Update ANOVA factor
%         %nf = sum(index'*indep, 1);
%         nf = zeros(1, sum(levels_in_factors));
%         sum_index = sum(index,2);
%         for k=1:3
%             for j=1:levels_in_factors(k)
%                 if k==1
%                     nf(j)=sum(sum_index(indep(:,k)==j));
%                 else
%                     nf(sub(k-1)+j)=sum(sum_index(indep(:,k)==j));
%                 end
%             end
%         end
%         alpha=sum(index.*(Z-repmat(factor(i-1,sub(1)+indep(:,2))'+factor(i-1,sub(2)+indep(:,3))', 1, n_cluster-1)...
%                            -repmat(level(i,:),n1,1)),2);  
%         na=nf(2:sub(1));
%         xi=post_xi(na, factor_xi(i-1,1), 1);
%         mid = zeros(1, levels_in_factors(1));
%         for j=1:levels_in_factors(1)
%             mid(j) = sum(alpha(indep(:,1)==j));
%         end
%         nu = post_nu(xi, factor_xi(i-1,1), 1, mid(2:end), prior_factor_nu(2:sub(1)));
%         factor(i,2:sub(1))=normrnd(nu,1./sqrt(xi));
% 
%         alpha=sum(index.*(Z-repmat(factor(i-1,sub(2)+indep(:,3))'+factor(i,indep(:,1))', 1, n_cluster-1)...
%                           -repmat(level(i,:),n1,1)), 2);  
%         nr=nf(2+sub(1):sub(2));
%         xi=post_xi(nr, factor_xi(i-1, 2), 1);
%         mid = zeros(1, levels_in_factors(2));
%         for j=1:levels_in_factors(2)
%             mid(j) = sum(alpha(indep(:,2)==j));
%         end
%         nu = post_nu(xi, factor_xi(i-1, 2), ...
%                      1, mid(2:end), prior_factor_nu(2+sub(1):sub(2)));
%         factor(i,2+sub(1):sub(2)) = normrnd(nu,1./sqrt(xi)); 
%      
%         alpha=sum(index.*(Z-repmat(factor(i,indep(:,1))'+factor(i,sub(1)+indep(:,2))', 1, n_cluster-1)...
%                            -repmat(level(i,:),n1,1)),2);  
%         nar=nf(2+sub(2):sub(3));
%         xi=post_xi(nar, factor_xi(i-1, 3), 1);
%         mid = zeros(1, levels_in_factors(3));
%         for j=1:levels_in_factors(3)
%             mid(j) = sum(alpha(indep(:,3)==j));
%         end
%         nu = post_nu(xi, factor_xi(i-1, 3), ...
%                      1, mid(2:end), prior_factor_nu(2+sub(2):sub(3)));
%         factor(i,2+sub(2):sub(3))=normrnd(nu,1./sqrt(xi));       
%         
%         %Update ANOVA hyper-parameter
%         new_b = [err2(factor(i,2:sub(1))', prior_factor_nu(2:sub(1))'), ...
%                  err2(factor(i,2+sub(1):sub(2))', prior_factor_nu(2+sub(1):sub(2))'), ...
%                  err2(factor(i,2+sub(2):sub(3))', prior_factor_nu(2+sub(2):sub(3))')]/2;
%         factor_xi(i,:) = update_phi(posterior_factor_xi_a, new_b+prior_factor_xi_b);
%         new_b = err2(level(i,:)',prior_level_nu')/2;
%         level_xi(i) = update_phi(posterior_level_xi_a, prior_level_xi_b+new_b); 
%         post_likelihood(i) = sum(log(normpdf(dep, Im*mu(i-1,:)',1./sqrt(Im*phi(i-1,:)'))));
    omega_base(i,:)=sample_dirichlet(nc+1/n_cluster,1);
    end
%     if ishandle(hdl)
%         delete(hdl);
%     end
    Sampler = struct('phi', phi, 'mu', mu, 'omega_base', omega_base);
end