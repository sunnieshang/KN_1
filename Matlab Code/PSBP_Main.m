%% Title: Main Code of Stick-breaking Finite Mixture
%% In all the calculation, Airline_1=Route_1=AirlineRoute_1=0 for identification issue; But I kept all of them in calculation.
clc; clear; close all % Probit Stick Breaking Process -- PSBP
fname ='PSBP_Whole3.csv';  
% fname ='PSBP_12_Sample_Routes.csv';    
data = csvread(fname, 2);
% data(data(:,1)>200 | data(:,1)<-150,:) = []; 
% data structure:
% delay-Airline-Route-AR-Month-Leg-AL-P1280-N1280-Dur-logWeight-logpieces
% Airline Code: AA:1; AC:2, AF:3, AY:4, BA:5, CV:6; CX:7; DL:8; EY:9; KA:10; KE:11;
              % KL:12; LH:13; LX:14; MP:15; OS:16; QR:17; SK:18; SQ:19; UA:20
dev_start = data(:,8); dur = data(:,9); log_weight = data(:,10); log_pcs = data(:,11);              
t_dev=[-5,-5,-5,-3,-2,-1,0,1,2,3,8.5,8.5,8.5]; t_dur= [0,0,0,1,2,4,6,8,10,12.1,12.1,12.1];
t_weight=[0,0,0,2,4,6,8,10,10,10];t_pcs=[0,0,0,1,3,5,7,7,7];order=4;
for j=1:length(t_dev)-4
    matrix_dev(:,j)=bspline_basis(j-1,order,t_dev,dev_start);
end
for j=1:length(t_dur)-4
    matrix_dur(:,j)=bspline_basis(j-1,order,t_dur,dur);
end
for j=1:length(t_weight)-4
    matrix_weight(:,j)=bspline_basis(j-1,order,t_weight,log_weight);
end
for j=1:length(t_pcs)-4
    matrix_pcs(:,j)=bspline_basis(j-1,order,t_pcs,log_pcs);
end
data_info = struct('dep',data(:,1),'category_predictor',data(:,2:6),'continuous_predictor',...
    [matrix_dev, matrix_dur,matrix_weight],'group_id',data(:,7));
% data_info = struct('dep',data(:,1),'category_predictor',data(:,2:6),'continuous_predictor',data(:,8:end),'group_id',data(:,7));
n_cluster = 50;   
prior = PSBP_Prior(data_info,   n_cluster); 
% Prior_Plot(data_info.dep, prior, n_cluster, plot_name)   
model_setup  = struct('n_cluster',n_cluster,'iteration',100,'iter_part',20,'burnin_part',0,'prior',prior);
post_sampler1 = PSBP_PostSampler(data_info, model_setup, prior);

%% Generate samplers
% save whole.mat
post_sampler2 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler1);
post_sampler3 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler2);
post_sampler4 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler3);
post_sampler5 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler4);
post_sampler6 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler5);
post_sampler7 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler6);
post_sampler8 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler7);
post_sampler9 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler8);
post_sampler10 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler9);
post_sampler11 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler10);
post_sampler12 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler11);
post_sampler13 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler12);
post_sampler14 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler13);
post_sampler15 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler14);
post_sampler16 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler15);
post_sampler17 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler16);
post_sampler18 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler17);


post_sampler19 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler18);
post_sampler20 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler19);
post_sampler21 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler20);
post_sampler22 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler21);
post_sampler23 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler22);
post_sampler24 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler23);
post_sampler25 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler24);
post_sampler26 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler25);
post_sampler27 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler26);
post_sampler28 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler27);
post_sampler29 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler28);
post_sampler30 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler29);
post_sampler31 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler30);
post_sampler32 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler31);
post_sampler33 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler32);
post_sampler34 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler33);
post_sampler35 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler34);


post_sampler36 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler35);
post_sampler37 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler36);
post_sampler38 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler37);
post_sampler39 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler38);
post_sampler40 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler39);
post_sampler41 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler40);
post_sampler42 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler41);
post_sampler43 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler42);
post_sampler44 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler43);
post_sampler45 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler44);
post_sampler46 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler45);
post_sampler47 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler46);
post_sampler48 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler47);
post_sampler49 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler48);
post_sampler50 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler49);

%% Model Checking: cross validation
Kfold = 3; 
[score, sampler1] = CrossValidation(data_info, model_setup, prior, Kfold);
% [score(2,:), sampler2] = CrossValidation(data_info, model_setup, prior, Kfold);


%% Post Sampler Inspections and Calculations
% save whole.mat

sampler = CatSampler(post_sampler11, post_sampler12);
sampler = CatSampler(sampler , post_sampler13);
sampler = CatSampler(sampler , post_sampler14);
sampler = CatSampler(sampler , post_sampler15);
sampler = CatSampler(sampler , post_sampler16);
sampler = CatSampler(sampler , post_sampler17);
sampler = CatSampler(sampler , post_sampler18);
sampler = CatSampler(sampler , post_sampler19);
sampler = CatSampler(sampler , post_sampler20);

[dic1,dic2, p_D1,p_D2,D_hat,d_bar, D_bar] = DIC(sampler, data_info);
%% Results and Applications 
[head_prob_ar, average_ar, cushion_ar, stock_ar]= ARPair_Inspect('PSBP_Whole3.csv', data_info, sampler);
[head_prob_route, average_route]= Route_Inspect('PSBP_Whole2.csv', data_info, sampler);
[head_prob_month, average_month]= Month_Inspect(data_info, sampler);
[head_prob_airline, average_airline, uo_ratio_airline, cost1_airline, cost2_airline, cost3_airline]= ...
    Airline_Inspect('PSBP_Whole.csv', data_info, sampler);
save whole_ARMW.mat
% posterior conditional density ARMW
[airline, route, al_rt,name] = AR_Index(fname);
choice = 9; sample_dev=0; sample_dur=1.5; sample_weight=log(100);
sample_leg=2;sample_month=3;
for j=1:length(t_dev)-4
    continuous1(j)=bspline_basis(j-1,order,t_dev,sample_dev);
end
for j=1:length(t_dur)-4
    continuous2(j)=bspline_basis(j-1,order,t_dur,sample_dur);
end
for j=1:length(t_weight)-4
    continuous3(j)=bspline_basis(j-1,order,t_weight,sample_weight);
end
predict_info = struct('category_predictor',[airline(choice),route(choice),al_rt(choice),sample_month, sample_leg],...
                      'continuous_predictor',[continuous1, continuous2, continuous3], ...
                      'sampler_num', 5000);
axis = linspace(-40,60,200);
thinned_sampler = Thin_Sampler(sampler, predict_info.sampler_num);
density = Predict_Density(data_info, predict_info, thinned_sampler, axis);
matrix = quantile(density,[0.025,0.975],1);
matrix = [matrix;mean(density,1)];
figure; clf;
plot(axis, matrix(3,:),'red',...
    axis,matrix(1:2,:),'blue','LineWidth',2);
set(gca,'FontSize',55,'XLim',[-40,60],'YLim',[0,0.2])
title(name{choice},'FontSize',60);

% integrate with cost function
cost1 = @(x) x>=12 | x<=-12;
cost2 = @(x) abs(x);
cost3 = @PieceWise;
cost4 = @(x) x;
cost5 = @(x) x.^2 ;
cost6 = @(x) x>=18;
cost = Cost_Integrate(cost6, density, axis);
quantile(cost,[0.025,0.975])
mean(cost)

R1 = [-3.25, -1.37, -2.28; -2.89, -1.20, -1.99; -4.95, -1.88, -3.42;...
      -3.79, -1.09, -2.39; -0.637, 0.662, 0.104; -0.648, 0.680, 0.130];
name = {'CV S','CV N','DL S','DL N','LH S','LH N'};
Mean_Comp(R1, name) 

R2 = [0.064, 0.073,0.069; 0.065, 0.074, 0.069; 0.075, 0.112, 0.094; ...
     0.086, 0.120, 0.104; 0.083, 0.131, 0.105; 0.076, 0.122, 0.099];
Mean_Comp(R2, name) 

R3 = [149.48, 165.62,157.29; 147.36, 163.96, 155.76; 261.53, 298.14, 279.39; ...
     258.60,295.09, 277.96; 166.85, 245.72, 205.70; 151.65, 224.36, 187.28];
Mean_Comp(R3, name) 

% Schedule Proposal
[airline, route, al_rt,name] = AR_Index(fname);
predict_info = struct('category_predictor',[airline(8),route(8),al_rt(8),7],...
                      'continuous_predictor',[log(1000)/10,log(100)/7], ...
                      'sampler_num', 1000);
axis = linspace(-40,60,200);
thinned_sampler = Thin_Sampler(sampler, predict_info.sampler_num);
Cdf = Predict_Cdf(data_info, predict_info, thinned_sampler, axis);
matrix = quantile(Cdf,[0.025,0.975],1);
matrix = [matrix;mean(Cdf,1)];
delay_level = 0;
service_level = 0.90;
proposal = Schedule_proposal(delay_level, service_level, Cdf);

% airline reference level
mean_dev = mean(dev_start);mean_dur = mean(dur);mean_weight=mean(log_weight);
for j=1:length(t_dev)-4
    continuous4(j)=bspline_basis(j-1,order,t_dev,mean_dev);
end
for j=1:length(t_dur)-4
    continuous5(j)=bspline_basis(j-1,order,t_dur,mean_dur);
end
for j=1:length(t_weight)-4
    continuous6(j)=bspline_basis(j-1,order,t_weight,mean_weight);
end
predict_info = struct('category_predictor',[1,NaN,NaN,NaN,NaN],...
                      'continuous_predictor',[continuous4, continuous5, continuous6], ...
                      'sampler_num', 1000);
ou_ratio = AirlineReference(data_info, sampler, predict_info) ;
quantile(ou_ratio, [0.025 0.975])
mean(ou_ratio)
title('BA');

AR = [0.238 0.360 0.287; 0.144, 0.443, 0.282; ...
      0.133 0.251 0.186; 0.0065 0.126 0.046; ...
      0.162 0.208 0.186; 0.068 0.109 0.081; ...
      0.175 0.241 0.209; 0.106 0.186 0.149; ... 
      0.471 0.643 0.576; 0.122 0.218 0.172; ...
      0.156 0.439 0.288; 0.0062 0.0165 0.0103; ...
      0.162 0.303 0.207; 0.127 0.191 0.165; ...
      0.156 0.275 0.206; 0.019 0.117 0.058; ...
      0.164 0.359 0.237; 0.104 0.357 0.190; ...
      0.0065 0.0358 0.0136; 0.168 0.270 0.207];
[~,name] = Airline_Index(fname);
Mean_Comp(AR, name) 
report = [0.85,0.8, 0.74, 0, 0.78, 0.78, ...
    0.92, 0.73, 0, 0, 0.93, 0.82, 0.89,0, ...
    0.77, 0.9, 0, 0.94, 0.94, 0.73];
% underage / overage ratio
uo_ratio = Predict_UORatio(data_info, predict_info, thinned_sampler)

% safety stock
stock = Safety_Stock(density, axis)
                  
% % Airline comparison on share route: for only two airlines comparison
% AC_Name = {'AA','UA'};
% % Sampler of each airlines are taken with step 10
% A_comparison = Airline_Comparison(AC_Name,data_info,post_sampler,-60,100,[1,22]);
% % Counterfacture: A new airline on a route
% AL_label = 21;
% Route_label = 653;
% NewAirlineOnRoute = CF_NewAirlineOnRoute(AL_label, Route_label, data_info, post_sampler, -60,100);

%% Model Comparison
clc; clear; close all % Probit Stick Breaking Process -- PSBP
fname ='predict2.csv';  
% fname ='PSBP_5_Sample_Routes.csv';    
data = csvread(fname,2,10);
y = data(:,11);
y(y<-150 | y>200)=[];
clf; figure(1); hist(y,100);title('OLS Replicate');savefig('OLS_replicate');
clc; clear; close all % Probit Stick Breaking Process -- PSBP
fname ='PSBP_Whole2.csv';  
% fname ='PSBP_5_Sample_Routes.csv';    
data = csvread(fname, 1);
y = data(:,1);
y(y<-150 | y>200)=[];
clf; figure(1); hist(y,100);title('Real Data');savefig('Real Data');

% model replicate
clc; clear all; close all; clf; load whole_latte_noMP.mat
[true_summary, predict_summary, predict_y] = Posterior_Predictive_Checking(data_info, sampler);
save whole_latte_noMP.mat
figure; y=predict_y; y(y<-100 | y>200)=[]; hist(y,100); title('PSBP replicate');
savefig('PSBP replicate');

% model comparison at each route level
[head_prob_route, average_route]= Route_Inspect('PSBP_Whole2.csv', data_info, sampler);
[head_prob_ar, average_ar, cushion_ar, stock_ar]= ARPair_Inspect('PSBP_Whole2.csv', data_info, sampler);
OLS_fname ='predict2.csv';  
% fname ='PSBP_5_Sample_Routes.csv';    
OLS_data = csvread(OLS_fname, 2,10);
% OLS_predict = OLS_data(OLS_data(:,5)==451 & OLS_data(:,6)==12,11);
OLS_predict = OLS_data(OLS_data(:,5)==781 & OLS_data(:,6)==8,11);
[f,xi]=ksdensity(OLS_predict);
plot(xi,f,'--r','LineWidth',1);
