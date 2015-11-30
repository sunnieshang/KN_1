function post_sampler2 = PSBP_PostSampler2(data_info, model_setup, prior, post_sampler)
% This function generate samplers after dropping burnin
% data_info: dependent variable and category/continuous/category-continous
% predictors
% model_setup: cluster number, and burnin periods
% prior: prior for Gibbs sampling
chain_start         = cell (1,  model_setup.iter_part);
chain_sampler       = cell (1,  model_setup.iter_part);
label_change        = zeros(model_setup.iter_part,  2);
%% Gibbs Sampling Estimate Coefficients
for i = 1: model_setup.iter_part
    if mod(i,10)==0
        disp(i);
    end
    if i==1
        rng('shuffle');
        chain_start{i} = Last_Sampler(post_sampler);
    elseif i>1
        chain_start{i} = chain_sampler{i-1}.last_sampler;
    end
    chain_sampler{i}   = PSBP_Sampler(data_info, model_setup, prior, chain_start{i});
    label_change(i,:)  = mean(chain_sampler{i}.test);
end
sname = fieldnames(chain_sampler{1});
post_sampler2 = struct();
for j=1:numel(sname)-1
    for i = model_setup.burnin_part+1 : model_setup.iter_part
        if i == model_setup.burnin_part+1
            post_sampler2.(sname{j}) = chain_sampler{i}.(sname{j});
        else
            post_sampler2.(sname{j}) = [post_sampler2.(sname{j});...
                                      chain_sampler{i}.(sname{j})];
        end
    end
end  

