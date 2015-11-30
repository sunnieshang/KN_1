function omega = Predict_Omega(data_info, predict_info, thinned_sampler)
% only calculate alpha for ONE conditional density
% sampler_num decide the number of sampler in
% thinned_sampler
n_cluster = size (thinned_sampler.mu,2);
n_category             = size (data_info.category_predictor,   2);
n_continuous           = size (data_info.continuous_predictor, 2);   
levels_in_category     = max  (data_info.category_predictor,   [], 1 );
sub   =  [0,  levels_in_category];   
sampler_num = size(thinned_sampler.mu,1);
if n_category > 0
    for i  =  2 : n_category+1
        sub(i)  =  sub(i-1)  +  sub(i);
    end
    for i  =  1 : n_category
        predict_info.category_predictor  (:,i)  =  predict_info.category_predictor(:,i)  +  sub(i);
    end
end
n_data = size(predict_info.category_predictor,1);
alpha  =  zeros  (sampler_num, n_data); 

if  n_category  >  0
    for  j  =  1  :  n_category
        alpha  =  alpha + thinned_sampler.category(:,predict_info.category_predictor(:,j));
    end
end
if  n_continuous  >  0
    alpha = alpha+thinned_sampler.continuous*predict_info.continuous_predictor';
end   
alpha=reshape(alpha, sampler_num*n_data,1);
alpha = repmat(alpha, 1, n_cluster-1);
alpha = alpha  +  thinned_sampler.level; 
omega = zeros(size(alpha,1),  n_cluster);
omega(:,1) = normcdf(alpha(:,1));
for j = 2: n_cluster-1
    omega(:,j) = (1-sum(omega(:,1:j-1),2)).*normcdf(alpha(:,j));
end 
omega(:,end) =  1-sum(omega(:,1:end-1),2);
