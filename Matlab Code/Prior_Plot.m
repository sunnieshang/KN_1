function Prior_Plot(dep, prior, n_cluster, type)
t=-60:1:100;
t_length = length(t);
[n,x] = hist(dep,t(1:3:end));
h = figure;
bar(x,n/length(dep)/diff(x(1:2)));
hold on;
phi = gamrnd(prior.phi_a, prior.phi_s, [8, n_cluster]);
mu = normrnd(repmat(prior.mu_nu,8,1), 1./sqrt(prior.mu_xi),[8,n_cluster]);
category_xi = gamrnd(prior.category_xi_a, prior.category_xi_s, [8,3]);
category = normrnd(0, category_xi, [8,3]);
level_xi = gamrnd(prior.level_xi_a, prior.level_xi_s, [8,1]);
level = normrnd(repmat(prior.level_nu, 8, 1), repmat(level_xi,1,n_cluster-1), [8, n_cluster-1]);
omega = zeros(8, n_cluster);
alpha = repmat(sum(category,2),1,n_cluster-1)+level;
omega(:,1)=normcdf(alpha(:,1));
q = repmat(omega(:,1),1,length(t)).*...
    normpdf(repmat(t,8,1),repmat(mu(:,1),1,t_length),1./sqrt(repmat(phi(:,1),1,t_length)));
for j=2:n_cluster-1
    omega(:,j)=(1-sum(omega(:,1:j-1),2)).*normcdf(alpha(:,j));
    q=q+repmat(omega(:,j),1,t_length)...
       .*normpdf(repmat(t,8,1),repmat(mu(:,j),1,t_length),1./sqrt(repmat(phi(:,j),1,t_length)));
end 
omega(:,n_cluster)=1-sum(omega(:,1:n_cluster-1),2);
q=q+repmat(omega(:,n_cluster),1,t_length).*...
    normpdf(repmat(t,8,1),repmat(mu(:,n_cluster),1,t_length),1./sqrt(repmat(phi(:,n_cluster),1,t_length)));
plot(t, q);
% saveas(h,sprintf('%s-Prior-Plot',type),'png');
title('Empirical distribution of data and 8 sampled priors');
savefig(sprintf('%s-Prior-Plot.fig',type));
end
