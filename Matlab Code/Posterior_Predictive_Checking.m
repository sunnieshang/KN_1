function [true_summary, predict_summary, predict_y] = Posterior_Predictive_Checking(data_info, sampler)
% mean, std, #<-12; #-12<d<0; # 0<d<12;#12<d<24;#24<d<36; #36<4<48; #48<d
n_cluster = size(sampler.mu,2);
sample_size=1000;
predict_y = zeros(1, length(data_info.dep));
predict_summary=zeros(sample_size,9);
true_summary=[mean(data_info.dep),std(data_info.dep),...
    mean(data_info.dep<-24 | data_info.dep>=36),mean(-24<=data_info.dep & data_info.dep<36)];
for i= 1: length(data_info.dep)
    i
    thinned_sampler =  Thin_Sampler(sampler, sample_size);
    predict_info = struct('category_predictor',data_info.category_predictor(i,:),...
                      'continuous_predictor',data_info.continuous_predictor(i,:), ...
                      'sampler_num', 1);
    omega = Predict_Omega(data_info, predict_info, thinned_sampler);
    Im  =  mnrnd(ones(size(omega,1),1),omega);
    predict =  sum(Im.*normrnd(thinned_sampler.mu,1./sqrt(thinned_sampler.phi),sample_size,n_cluster), 2);
    predict_summary(:,1)=predict_summary(:,1)+predict/86148;
    predict_summary(:,2)=predict_summary(:,2)+predict.*predict/86148;
    predict_summary(:,3)=predict_summary(:,3)+(predict<-24|predict>=36)/86148;
    predict_summary(:,4)=predict_summary(:,4)+(-24<=predict & predict<36)/86148;
    x = randsample(sample_size,1);
    predict_y(i)=predict(x);
end
predict_summary(:,2)=sqrt(predict_summary(:,2)-predict_summary(:,1).*predict_summary(:,1));
for i = 1:4
    figure(i);nbin=50;
    hist(predict_summary(:,i),nbin);hold on;
    plot([true_summary(i),true_summary(i)],[0,60]);
    
end



