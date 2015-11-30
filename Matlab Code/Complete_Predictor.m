function [real_y, complete_pred_info] = Complete_Predictor(data_info, incomplete_pred_info)
n_category   = size(data_info.category_predictor,  2);
n_continuous = size(data_info.continuous_predictor,2);
index = ones(length(data_info.dep),1);
if n_category > 0
    for i = 1:n_category
        if ~isnan(incomplete_pred_info.category_predictor(i))
            index = index & (data_info.category_predictor(:,i)==incomplete_pred_info.category_predictor(i));
        end
    end
end
if n_continuous>0
    for i=1:n_continuous
        if ~isnan(incomplete_pred_info.continuous_predictor(i))
            index = index & (data_info.continuous_predictor(:,i)==incomplete_pred_info.continuous_predictor(i));   
        end
    end
end
if sum(index)>500
    p = 500/sum(index);
    mid_value = binornd(1,p,[length(data_info.dep),1]);
    index = index & mid_value;
end

sampledata = zeros(sum(index),0);
real_y = data_info.dep(index==1);
if n_category>0
    sampledata = [sampledata,data_info.category_predictor(index==1,:)];
end
if n_continuous>0
    sampledata = [sampledata, data_info.continuous_predictor(index==1,:)];
end
% [sampledata2,ia,ic] = unique(sampledata,'rows', 'stable');
if n_continuous==0
    complete_pred_info = struct('category_predictor',sampledata(:,1:n_category),...
                         'continuous_predictor',zeros(size(sampledata,1),0), ...
                         'sampler_num',incomplete_pred_info.sampler_num);
else
    complete_pred_info = struct('category_predictor',sampledata(:,1:n_category),...
                         'continuous_predictor',sampledata(:,n_category+1: n_category+n_continuous), ...
                         'sampler_num',incomplete_pred_info.sampler_num);
end