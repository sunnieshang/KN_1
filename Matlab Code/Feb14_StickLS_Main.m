%% Title: Main Code of Stick-breaking Finite Mixture
%% In all the calculation, Airline_1=Route_1=AirlineRoute_1=0 for identification issue; But I kept all of them in calculation.
%% Initial Set Up
clc
clear all
close all 

%% Read In Data 
fname ='Feb13_14_whole.csv';
% fname ='Feb13_14_5routes.csv';
data = csvread(fname, 2);
data(data(:,1)>150 | data(:,1)<-150,:) = []; 
data_info = struct('dep',data(:,1),'indep',data(:,2:end),...
        'n_factor', 3, 'levels_in_factors', max(data(:,2:end),[],1));
clear data fname;
    % AA:1; AC:2, AF:3, AY:4, BA:5, C8:6; CV:7; CX:8; DL:9; EY:10; KA:11; KE:12;
    % KL:13; LH:14; LX:15; MP:16; OS:17; QK:18; QR:19; SK:20; SQ:21; UA:22;
    % XB:23; XC:24; XH:25;
%% Setting Parameters: N(mean, precision), G(shape, scale)
    % y ~ \sum omega_i * N(mu, phi), 
    %     , where omega_i ~ (level_i + A_a + R_r + AR_ar, 1)
        % level_i ~ N(0, xi_level)
        % A_a ~ N(0, xi(1))
        % R_r ~ N(0, xi(2))
        % AR_ar ~ N(0, xi(3))
            % xi(:), xi_level ~ G(xi_a, xi_s)
        % phi ~ G(phi_a, phi_s)

% (1) For original sampling, label switching and ordered kernal
n_cluster = 60;   
% (2) For fixed kernal sampling
%    mu=[-48,-35,-24,-18,-12,-8,-5,-3,0,3,6,9,12,18,24,30,40,48,60]; 
%   n_cluster = length(mu);

% Same for all samplings
rng('shuffle');
prior_value = struct('phi_a', 1.25, 'phi_s', 0.026, ...
                     'mu_xi', 2/range(data_info.dep),... %'mu_nu', quantile(data_info.dep,(1:n_cluster)/(n_cluster+1)), ...
                     'mu_nu', mean(data_info.dep)*ones(1,n_cluster),...
                     'factor_nu', zeros(1, sum(data_info.levels_in_factors)),...    
                     'factor_xi_a', 6, 'factor_xi_s', 0.2,...
                     'level_nu', norminv(1./((1+n_cluster)-(1:(n_cluster-1)))), ...
                     'level_xi_a', 6, 'level_xi_s', 0.2);

Prior_Plot(data_info.dep, prior_value, n_cluster, 'LS-whole-jun18')
    
% (1) For original sampling, label switching and ordered kernal
model_setup = struct('n_cluster', n_cluster, 'iter', 1000, 'prior', prior_value);
% (2) For fixed kernal sampling
%     model_setup = struct('n_cluster', n_cluster, 'iter', 20, 'prior', prior_value, 'mu', mu);
%% First Round MCMC Sampler
parts = 60;
chain_start = cell(1,parts);
% (1) For original sampler
chain_sampler = cell(1,parts);
test = zeros(parts,2);
% (4) For fixed kernal sampler
%     chainFK_samplerFK = cell(1,8);
%     MLE_estimate=cell(1,8);
n_factor = data_info.n_factor;
levels_in_factors = data_info.levels_in_factors;
% for j=1:numel(sname)
%     post_sampler.(sname{j}) = Burnin_Thin(chain_sampler{1}.(sname{j}), model_setup.iter, 0.5, 1);
%     %post_summary.(sname{j}) = MCMC_Summary(post_sampler.(sname{j}), 8);
% end
% post_sampler=Post_Label_Switching(post_sampler);
% save stick_5routes_jun04.mat;% A means all the data
%% Second Round MCMC Sampler with Fixed Kernels
for i=1:parts
    i
    if i==1
        rng('shuffle');
        chain_start{i} = Stick_Start(n_cluster, n_factor, levels_in_factors, prior_value);
    elseif i>1
        chain_start{i} = chain_sampler{i-1}.chain_start;
    end
    %(1) original sampler
%         chain_sampler{i} = Stick_Sampler2(data_info, model_setup, chain_start{i});
    %(2) Label switching original sampler
    chain_sampler{i} = Stick_SamplerLS(data_info, model_setup, chain_start{i});
    %(3) First stage procedure
%    chain_sampler{i} = FirstStage_Sampler(data_info, model_setup, chain_start{i});
    %(4) ordered kernel sampler
%         chain_sampler{i} = StickOK_Sampler(data_info, model_setup, chain_start{i});
    %(5) fixed kernal sampler
%         chainFK_sampler{i} = StickFK_Sampler(data_info, model_setup, chain_start{i});   
    % MLE of fixed kernal sampler
        % MLE_estimate{i} = MLE(data_info, model_setup, chain_start{i})
     test(i,:) = mean(chain_sampler{i}.test,1);
end
%save LS_whole_jun12.mat
% (1) original sampler
sname = fieldnames(chain_sampler{1});
% (4) fixed kernal sampler
%     sname = fieldnames(chainFK_sampler{1});
post_sampler = struct();
% post_likelihood = zeros(8,1);
% for i=1:8
%     post_likelihood(i)=mean(chain_sampler{i}.post_likelihood...
%         (floor(model_setup.iter*0.5):model_setup.iter));
% end
% [c,I]=max(post_likelihood);
% for j=1:numel(sname)
%     post_sampler.(sname{j}) = Burnin_Thin(chain_sampler{I}.(sname{j}), model_setup.iter, 0.5, 1);
% end
%post_summary = struct();
% (1) For random kernal sampler
start = 11;
    for j=1:numel(sname)-1
        for i=start:parts
            if i==start
                post_sampler.(sname{j}) = Burnin_Thin(chain_sampler{i}.(sname{j}), model_setup.iter, 0, 1);
            else
                post_sampler.(sname{j}) = [post_sampler.(sname{j});...
                    Burnin_Thin(chain_sampler{i}.(sname{j}), model_setup.iter, 0, 1)];
            end
        end
        %post_summary.(sname{j}) = MCMC_Summary(post_sampler.(sname{j}), 8);
    end
% (4) For fixed kernal sampler
%     for j=1:numel(sname)
%         post_sampler.(sname{j}) = [Burnin_Thin(chainFK_sampler{1}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{2}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{3}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{4}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{5}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{6}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{7}.(sname{j}), model_setup.iter, 0.5, 1);...
%                                 Burnin_Thin(chainFK_sampler{8}.(sname{j}), model_setup.iter, 0.5, 1)];
%         %post_summary.(sname{j}) = MCMC_Summary(post_sampler.(sname{j}), 8);
%     end    
clear sname n_factor levels_in_factors n_cluster j chain_sampler;
save LS_whole_jun18.mat
%% Post_Sampler Analyses
%% Airline-Route Pair
% Table about airline and route
% Table about airline and route
name = {'HKG-BUD-CV','HKG-BUD-QR','NBO-AMS-CV','NBO-AMS-MP','NBO-AMS-SQ',...
        'LHR-MAD-BA','LHR-MAD-LH','LHR-MAD-LX','FRA-ATL-CV','FRA-ATL-DL',...
        'FRA-ATL-LH','CDG-SIN-AF','CDG-SIN-SQ'};
%(1) for 5-routes data
% airline = {3,9,3,8,10,2,6,7,3,4,6,1,10};
% route = {3,3,5,5,5,4,4,4,2,2,2,1,1};
% al_rt = {6,15,7,14,18,4,12,13,5,8,11,1,17};
% (2) for whole data
airline = {7, 19, 7, 16, 21, 5, 14, 15, 7, 9, 14, 3, 21};
route = {653,653,1097,1097,1097,920,920,920, ...
         445,445,445,314,314};
al_rt = {684,2189,753,2094,2381,510,1706,2006,637,908,1498,222,2325};
density_info = struct('name', name, 'airline', airline, 'route', route, 'al_rt', al_rt);
clear name airline route al_rt;
% (1) for orignal samplers
density_estimates = Stick_Density_Estimate(density_info, data_info, post_sampler, -60, 100, chain_start);
Density_Plot(density_info, data_info, density_estimates, 'LS-whole-jun18'); 
% (4) for fixed kernal situation
%     density_estimates = StickFK_Density_Estimate(density_info, data_info, post_sampler, -60, 100, chain_start, model_setup.mu);
%     DensityFK_Plot(density_info, data_info, density_estimates, 'StickFK-5routes-Jun04', model_setup.mu );
% Density_Traceplot(density_info, density_estimates,length(chain_start),'LS-whole-jun18');
%Density_Traceplot(density_info, density_estimates,1,'Stickls-5routes-feb14');
HeadTail_Plot({density_info(:).name}, density_estimates, 'LS-whole-jun18-AL-RT');
Mean_Plot({density_info(:).name}, density_estimates, 'LS-whole-jun18-AL-RT');
% (1): for 5 routes
clear density_estimates;
%% For MSOM Poster
% name = {'FRA-ATL-CV','FRA-ATL-DL','FRA-ATL-LH'};
% airline = {3,4,6};
% route = {2,2,2};
% al_rt = {5,8,11};
% density_info = struct('name', name, 'airline', airline, 'route', route, 'al_rt', al_rt);
% clear name airline route al_rt;
% % (1) for orignal samplers
% density_estimates = Stick_Density_Estimate(density_info, data_info, post_sampler, -60, 100, chain_start);
% Density_Plot(density_info, data_info, density_estimates, 'A'); 
% HeadTail_Plot({density_info(:).name}, density_estimates, 'FRA-ATL');
% Mean_Plot({density_info(:).name}, density_estimates, 'FRA-ATL');
%% Each airline overall average
AL_name = {'AA','AC','AF','AY','BA','C8','CV','CX','DL','EY','KA','KE',...
           'KL','LH','LX','MP','OS','QK','QR','SK','SQ','UA','XB','XC','XH'};
% AL_name = {'AF','BA','CV','DL','x','LH','LX','MP','QR','SQ'};
%     RT_name = {'CDG-SIN','FRA-ATL','HKG-BUD','LHR-MAD','NBO-AMS'};
%     % AL_RT_name = {'CDG-SIN-AF','LHR-MAD-BA','FRA-ATL-CV','HKG-BUD-CV','NBO-AMS-CV',...
%     %     'FRA-ATL-DL',};
%     Postsampler_Plot(post_sampler, AL_name, RT_name, 'StickFK-5routes-Jun04');
AA_sampler = cell(1,length(AL_name));
post_AA = struct();
parfor i=1:25
    % Sampler of airline are taken with a step 20 
    AA_sampler{i} = Airline_Average(i,AL_name{i},data_info,post_sampler,-60,100);
    sname = fieldnames(AA_sampler{i});
    for j=1:numel(sname)
        post_AA(i).(sname{j}) = AA_sampler{i}.(sname{j});
    end
end
clear AA_sampler;
% AA_Plot(AL_name,data_info,post_AA,'whole-jun13-A-Ave');
delay_level = 0;
service_level = 0.90;
proposal = Schedule_proposal(delay_level, service_level,post_AA,AL_name,data_info);
cost1 = @(x) x.^2/10;
cost2 = @(x) abs(x);
cost3 = @PieceWise; 
Cost_AL = AA_Cost(AL_name, cost1, post_AA,'LS-whole-jun18-cost_AL');

%% Airline comparison on share route
% For only two airlines comparison
AC_Name = {'AA','UA'};
% Sampler of each airlines are taken with step 10
A_comparison = Airline_Comparison(AC_Name,data_info,post_sampler,-60,100,[1,22]);

%% Counterfacture: A new airline on a route
AL_label = 21; %SQ
Route_label = 653; %HKG-BUD
NewAirlineOnRoute = CF_NewAirlineOnRoute(AL_label, Route_label, data_info, post_sampler, -60,100);
save LS_whole_jun18(2).mat
% Old_New_AL_Name = {'AF','BA','CV','DL','x','LH','LX'};
% HeadTail_Plot(Old_New_AL_Name,NewAirlineOnRoute,'LS-5-jun12-NewAir');
% Mean_Plot(Old_New_AL_Name,NewAirlineOnRoute,'LS-5-jun12-NewAir');
