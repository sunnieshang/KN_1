function [score, post_sampler] = CrossValidation(data_info, model_setup, prior, Kfold)
% This function caculate k-fold cross validation
% To simply, we use PSBP_PostSampler function
    rng('shuffle');
    Kfold_index = crossvalind('Kfold',data_info.group_id,Kfold); 
    score = zeros(1,Kfold);
    for CV = 1:Kfold
        traindata_info = struct('dep',  data_info.dep(Kfold_index~=CV),...
                 'category_predictor',  data_info.category_predictor(Kfold_index~=CV,:),...
               'continuous_predictor',  data_info.continuous_predictor(Kfold_index~=CV,:));
        testdata_info = struct( 'dep',  data_info.dep(Kfold_index==CV),...
                 'category_predictor',  data_info.category_predictor(Kfold_index==CV,:),...
               'continuous_predictor',  data_info.continuous_predictor(Kfold_index==CV,:));
        post_sampler = PSBP_PostSampler(traindata_info, model_setup, prior);
    %% Calculate Forecast Error
        [~,~, ~,~,~,score(CV), ~] = DIC(post_sampler, testdata_info);
    end
  
