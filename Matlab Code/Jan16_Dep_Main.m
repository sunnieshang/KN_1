%% Title: Main Code of Dependent Finite Mixture
%% Initial Set Up
clc
close all
clear all

% cd('D:\Dropbox\5.2New Data\Research from 2013 Summer\Latte');
% cd('/Users/sunnieshang/Dropbox/5.2New Data/Research from 2013 Summer/Latte');

%% Read In Data 
X = csvread('Jan16.csv', 1, 0); 
    % The data read in from STATA file Jan16.do
        % (1) first column X(,1) is delay_1410
        % (2) X(,2:10) is airlines (factor AF has already been removed)
        %     1:AF; 2:BA; 3:CV; 4:DL; 5:KL; 6:LH; 7:LX; 8:MP; 9:QR; 10:SQ
        % (3) X(,11:14) is route information
        %     1(2443): CDG-SIN; 2(3817): FRA-ATL; 3(4995): HKG-BUD; 
        %     4(6616): LHR-MAD; 5(8189): NBO-AMS
        % (4) X(,15:31) is airline-route interactions
X( X(:,1)>150 | X(:,1)<-150,:) = []; 
data_info = struct('dep', X(:,1), 'indep', sparse(X(:,2:31)),...
    'n_factor', 3, 'levels_in_factors', [9,4,17]);
clear X;
    % n_factor: number of anova factors
    % levels_in_factors: number of different levels in each factor

%% Setting Parameters: N(mean, precision), G(shape, scale)
    % y ~ \sum omega_i*N(level_i + A_a + R_r + AR_ar, phi)
        % level_i ~ N(0, xi_level)
        % A_a ~ N(0, xi(1))
        % R_r ~ N(0, xi(2))
        % AR_ar ~ N(0, xi(3))
            % xi(:), xi_level ~ G(xi_a, xi_s)
        % phi ~ G(phi_a, phi_s)
        % omega ~ dirichlet(1/L,...);
n_cluster = 40;
prior_value = struct('phi_a', 2, 'phi_s', 0.0001, ...
                     'factor_xi_a', 2, 'factor_xi_s', 0.0002, ...
                     'level_xi_a', 2, 'level_xi_s', 0.0002, ...
                     'factor_nu', zeros(1, sum(data_info.levels_in_factors)),...
                     'level_nu', zeros(1, n_cluster),...
                     'omega',1500*ones(1,n_cluster)/n_cluster);
% prior_value = struct('phi_a', 2, 'phi_s', 0.0005, ...
%                      'factor_xi', 0.001*ones(1,3), ...
%                      'level_xi', 0.001, ...
%                      'factor_nu', zeros(1, sum(data_info.levels_in_factors)),...
%                      'level_nu', zeros(1, n_cluster),...
%                      'omega', ones(1,n_cluster)/n_cluster);
model_setup = struct('n_cluster', n_cluster, 'iter', 1000, 'prior', prior_value);
clear prior_value;
    % n_cluster: number of mixture clusters
    % iter: MCMC iterations
    % prior: prior distribution, phi~gamma(shape=phi_a, scale=phi_s)

%% 
n_factor = data_info.n_factor;
levels_in_factors = data_info.levels_in_factors;
% load dep_result_jan23.mat;
% chain_start = cell(1,8);
% chain_sampler = cell(1,8);
% factor = post_sampler.factor(end,:);
% level = post_sampler.level(end,:);
% phi = post_sampler.phi(end);
% factor_xi = post_sampler.factor_xi(end,:);
% level_xi = post_sampler.level_xi(end);
% omega = post_sampler.omega(end,:);
parfor i=1:8
    chain_start{i} = Dep_Start2(n_cluster, n_factor, levels_in_factors); 
%     chain_start{i} = struct('factor',factor,...
%                             'level',level,...
%                             'phi',phi,...
%                             'factor_xi',factor_xi,...
%                             'level_xi',level_xi,...
%                             'omega',omega);
    chain_sampler{i} = Dep_Sampler(data_info, model_setup, chain_start{i});
end
sname = fieldnames(chain_sampler{1});
post_sampler = struct();
%post_summary = struct();
for j=1:numel(sname)
    post_sampler.(sname{j}) = [Burnin_Thin(chain_sampler{1}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{2}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{3}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{4}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{5}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{6}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{7}.(sname{j}), model_setup.iter, 0.5, 10);...
                               Burnin_Thin(chain_sampler{8}.(sname{j}), model_setup.iter, 0.5, 10)];
    %post_summary.(sname{j}) = MCMC_Summary(post_sampler.(sname{j}), 8);
end
clear chain_sampler sname n_factor n_cluster levels_in_factors j;
save dep_result_feb3(3).mat;
% MCMC_Plot(post_sampler.factor, 1:1:12, {'omega'},'chainpanel');
% MCMC_Plot(post_sampler.factor, 13:1:23, {'omega'},'chainpanel');
% MCMC_Plot(post_sampler.factor, 1:1:10, {'factor'},'pairs');
% MCMC_Plot(post_sampler.factor, 20:1:30, {'factor'},'dens');
% MCMC_Plot(post_sampler.omega, [], {'omega'},'hist');
% MCMC_Plot(post_sampler.omega, [], {'omega'},'denspanel');
% MCMC_Plot(post_sampler.omega, [], {'omega'},'acf'); % skip = 10;

%% Density estimation plots
% Table about airline and route
name = {'HKG-BUD-CV','HKG-BUD-QR','NBO-AMS-CV','NBO-AMS-MP','NBO-AMS-SQ',...
    'LHR-MAD-BA','LHR-MAD-LH','LHR-MAD-LX','FRA-ATL-CV','FRA-ATL-DL',...
    'FRA-ATL-LH','CDG-SIN-AF','CDG-SIN-SQ'};
airline = {2,8,2,7,9,1,5,6,2,3,5,nan,9};
route = {2,2,4,4,4,3,3,3,1,1,1,nan,nan};
al_rt = {5,14,6,13,17,3,11,12,4,7,10,nan,16};
density_info = struct('name', name, 'airline', airline, 'route', route, 'al_rt', al_rt);
clear name airline route al_rt;
density_estimates = Dep_Density_Estimate(density_info, data_info, ...
                                         post_sampler, -60, 96, chain_start);
Density_Plot(density_info, data_info, density_estimates,'Dep-feb3(3)');
Density_Traceplot(density_info, density_estimates,'Dep-feb3(3)');
%save dep_result_jan302(2).mat;
