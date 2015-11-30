function uo_ratio = AirlineReference(data_info, sampler, predict_info)
thinned_sampler = Thin_Sampler(sampler, predict_info.sampler_num);
n_cluster = size (thinned_sampler.mu,2);
n_category             = size (data_info.category_predictor,   2);
n_continuous           = size (data_info.continuous_predictor, 2);   
levels_in_category     = max  (data_info.category_predictor,  [], 1 );
sub   =  [0,  levels_in_category];  
matrix = zeros(size(thinned_sampler.mu,1), n_category+n_continuous);

if n_category > 0
    for i  =  2 : n_category+1
        sub(i)  =  sub(i-1)  +  sub(i);
        matrix(:,i-1) = mean(thinned_sampler.category(:,sub(i-1)+1:sub(i)),2);
    end
end
matrix(:,1) = thinned_sampler.category(:,predict_info.category_predictor(1));
% matrix(:,3) = 0;
% matrix(:,n_category-1) = thinned_sampler.category(:,sub(n_category-1)+predict_info.airline+1);
% matrix(:,n_category-1) = 0;
% matrix(:,n_category)=0;
alpha  =  zeros  (size(thinned_sampler.mu,1),  n_cluster-1); 
if  n_category  >  0
    alpha  =  alpha + repmat (sum(matrix(:,1:n_category),2), 1, n_cluster-1 );
end
matrix(:,n_category+1:end)=thinned_sampler.continuous;
if  n_continuous  >  0
    alpha = alpha+repmat(matrix(:,n_category+1:end)...
                *predict_info.continuous_predictor' , 1, n_cluster-1);
end       
alpha = alpha  +  thinned_sampler.level; 
omega = zeros(size(alpha,1),  n_cluster);
omega(:,1) = normcdf(alpha(:,1));
for j = 2: n_cluster-1
    omega(:,j) = (1-sum(omega(:,1:j-1),2)).*normcdf(alpha(:,j));
end 
omega(:,end) =  1-sum(omega(:,1:end-1),2);
axis = linspace(-50,100,100);
density = repmat(omega(:,1),1,length(axis)).* normpdf(repmat(axis,size(omega,1),1)...
               ,repmat(thinned_sampler.mu(:,1),1,length(axis))...
               ,1./sqrt(repmat(thinned_sampler.phi(:,1),1,length(axis))));
for j=2:size(omega,2)
    density = density+repmat(omega(:,j),1,length(axis))...
             .*normpdf(repmat(axis,size(omega,1),1),repmat(thinned_sampler.mu(:,j),...
             1,length(axis)),1./sqrt(repmat(thinned_sampler.phi(:,j),1,length(axis))));
end
figure; 
plot(axis, mean(density,1),'red',axis,quantile(density,[0.025, 0.975],1),'blue'...
    ,'LineWidth',2);
set(gca,'FontSize',40,'YLim',[0,0.35],'XLim',[-50,50]);
sprintf('Reference Level of Airline %d', predict_info.category_predictor(1));


head_threshold = 0; % cdf
mid = normcdf(head_threshold,thinned_sampler.mu,1./sqrt(thinned_sampler.phi)); 
mid = sum(omega.*mid, 2);
uo_ratio = 1./mid-1;
% savefig(predictinfo.airline);












