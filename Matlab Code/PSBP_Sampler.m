function  Sampler = PSBP_Sampler ( data_info, model_setup, prior, chain_start)
% July 29 2014 
% This function generate Gibbs sampler for PSBP mixture model, the most
% important part of the whole model. Several points to note: (1) for each
% category coefficent, the first is zero, just don't update it; (2)
% hierarchy only exist for category predictors; (3) the methods of updating
% is classified into: levels; category; continuous; category-continous; (3)
% in the end, sampler is a struct contains gibbs sampler and number of
% labels switchings. 
    %% free structure inputs to speed up code
    rng shuffle
    levels_in_category =  max  ( data_info.category_predictor, [], 1 );
    n_category         =  size ( data_info.category_predictor,  2 );
    n_continuous       =  size ( data_info.continuous_predictor,2 );
    %% use a consistent categorical variable for all predictors, such change subscripts
    sub = [ 0, levels_in_category ];   
    if n_category > 0
        for iter  =  2 : n_category+1
            sub(iter)  =  sub(iter-1)  +  sub(iter);
        end
        for iter  =  1 : n_category
            data_info.category_predictor  (:,iter)  =  data_info.category_predictor(:,iter)  +  sub(iter);
        end
    end
    
    observation_num        =  length  (  data_info.dep  );   
    posterior_category_xi_a=  model_setup.prior.category_xi_a  +  (levels_in_category  -  1)/2;
    posterior_level_xi_a   =  model_setup.prior.level_xi_a   +  (model_setup.n_cluster-1)/2;
    
    %% initialize samplers
    post_likelihood        =  zeros  (  model_setup.iteration,  1  );
    test                   =  unifrnd(  0,  1,  [model_setup.iteration,  2]  );
    omega                  =  zeros  (  observation_num,          model_setup.n_cluster  );
    mu                     =  zeros  (  model_setup.iteration,  model_setup.n_cluster  );
    phi                    =  zeros  (  model_setup.iteration,  model_setup.n_cluster  );
    level                  =  zeros  (  model_setup.iteration,  model_setup.n_cluster-1  );
    category   =  zeros  (  model_setup.iteration,  sum(levels_in_category)  ); 
    category_xi=  zeros  (  model_setup.iteration,  n_category  );
    continuous =  zeros  (  model_setup.iteration,  n_continuous  ); 
    level_xi             =  zeros  (  model_setup.iteration,  1  );
    change               =  zeros  (  model_setup.iteration,  1  );
        level(1,:)       =  chain_start.level;
        category(1,:)    =  chain_start.category;
        category_xi(1,:) =  chain_start.category_xi;
        if n_continuous > 0
            continuous(1,:)  =  chain_start.continuous;
        end
        level_xi(1,:)  =  chain_start.level_xi;
        phi(1,:)       =  chain_start.phi;
        mu(1, :)       =  chain_start.mu;
    
    %% anonymous function
    err2        =  @(y, mu)                                  sum   (  (y-mu)'*(y-mu),  1  );
    update_phi  =  @(a, b)                                   gamrnd(  a,  1./b,  [1, length(a)]  );
    post_xi     =  @(n, prior_xi, phi)                       n.*phi  +  prior_xi;
    post_nu     =  @(post_xi, prior_xi, phi, mid, prior_nu)  (prior_nu.*prior_xi  +  mid.*phi)  ./  post_xi;

    %% Computation: Gibbs sampling
    
    for  iter  =  2  :  model_setup.iteration;
        if iter==2
            alpha  =  zeros  (  observation_num,  model_setup.n_cluster-1  );       
            if  n_category  >  0
                for  j  =  1  :  n_category
                    alpha  =  alpha  +  repmat  (  category  ...
                        (  iter-1,  data_info.category_predictor(:,j)  )'  ,  1  ,  model_setup.n_cluster-1  );
                end
            end
            if  n_continuous  >  0
                alpha  =  alpha  +  repmat  (  data_info.continuous_predictor...
                    *  continuous(iter-1,:)'  ,  1  ,  model_setup.n_cluster-1  );
            end       
            alpha  =  alpha  +  repmat  (  level(iter-1,:),  observation_num,  1  );
        end
        
        
        omega(:,1)  =  normcdf  (  alpha(:,1)  );
        for  j  =  2  :  model_setup.n_cluster-1
            omega(:,j)  =  (  ones(observation_num,1)  -  sum(omega(:,1:j-1),2)  )  .*  normcdf  (  alpha(:,j)  );
        end  
        omega(:, end)   =  ones  (  observation_num,  1  )  -  sum  (  omega(:,  1:end-1)  ,  2  );
        Pos  =  normpdf  (  repmat  (  data_info.dep,  1,  model_setup.n_cluster),...
                            repmat  (  mu(iter-1,:),  observation_num,  1  ),  ...
                            1  ./  sqrt  (  repmat  (  phi(iter-1,:),  observation_num,  1  )  )  );
        Pos  =  Pos  .*  omega;
        Pos  =  Pos  ./  repmat  (  sum  (  Pos,  2  ),  1,  model_setup.n_cluster  );   
        if isnan(sum(sum(Pos))) || isinf(sum(sum(Pos)))
            change(iter) =1;
            Pos(isnan(sum(Pos,2)),:)=1/model_setup.n_cluster;
            Pos(isinf(sum(Pos,2)),:)=1/model_setup.n_cluster;
        end
        Im   =  mnrnd  (  ones  (  observation_num,  1  ),  Pos  );
        
        %% Metropolis-hasting label-switching move 1
            %: switch two random labels
        label  =  randsample  (  model_setup.n_cluster,  2  );
        % make sure label(2) is the larger one
        if  label(1)  >  label(2)
            label([1,2])  =  label([2,1]);
        end
        Im2  =  Im; 
        Im2(:,  [label(2),  label(1)])  =  Im(:,  [label(1),  label(2)]);
        
        log_old_prob  =  sum(  log  (  omega  (  Im (:,  label(1))==1,  label(1)  )  )  )...
                      +  sum(  log  (  omega  (  Im (:,  label(2))==1,  label(2)  )  )  );
        log_new_prob  =  sum(  log  (  omega  (  Im2(:,  label(2))==1,  label(2)  )  )  )...
                      +  sum(  log  (  omega  (  Im2(:,  label(1))==1,  label(1)  )  )  );
        prob_ratio    =  exp(  log_new_prob  -  log_old_prob  );
        if  test(iter,1)  <=  min(1,prob_ratio)  &&  ~isnan(prob_ratio)
            %label-switching move
            test(iter,1)  =  1;
            Im  =  Im2;
            phi(iter-1,  [label(2), label(1)]  )  =  phi(iter-1,  [label(1), label(2)]);
            mu (iter-1,  [label(2), label(1)]  )  =  mu (iter-1,  [label(1), label(2)]);
        else 
            test(iter,1)  =  0;
        end
        clear label Im2 log_new_prob prob_ratio log_old_prob;
        
        %% Metropolis-hasting label-switching move 2:
            % permute two consecutive labels
        label  =  randsample  (  model_setup.n_cluster-1,  1  );
        Im2    =  Im;
        Im2  (  :,  [label,  label+1] )  =  Im(:,  [label+1,  label]  );

        alpha2  =  alpha;
        if  label  <  model_setup.n_cluster  -  1
            alpha2(:,  [label, label+1])  =  alpha(:,  [label+1, label]);
        end
        if  label  <  model_setup.n_cluster  -  1
            log_old_prob  =  sum  (  log (  1 - normcdf ( alpha ( Im(:, label+1 )==1, label) ) ) )...
                         +   log  (  normpdf (level(iter-1, label  ), prior.level_nu(label),  level_xi(iter-1)))...
                         +   log  (  normpdf (level(iter-1, label+1), prior.level_nu(label+1),level_xi(iter-1)));
            log_new_prob  =  sum  (  log (  1 - normcdf ( alpha2 ( Im2 ( :, label+1 )==1, label) ) ) )...
                            + log  (  normpdf ( level(iter-1,   label ), prior.level_nu(label+1), level_xi(iter-1)))...
                            + log  (  normpdf ( level(iter-1,  label+1), prior.level_nu(label),   level_xi(iter-1)));
        elseif  label  ==  model_setup.n_cluster-1 
            log_old_prob  =  sum ( log ( 1 - normcdf ( alpha( Im(:,end)==1, end) ) ) )...
                           + sum ( log ( normcdf ( alpha(Im(:,end-1)==1, end) ) ) );
            log_new_prob  =  sum ( log ( 1-normcdf ( alpha2 ( Im2(:,end)==1, end))))...
                           + sum ( log ( normcdf ( alpha2 ( Im2(:,end-1)==1, end))));
        end 
        prob_ratio  =  exp(log_new_prob-log_old_prob);
        if test(iter,2)  <=  min(1,prob_ratio)  &&  ~isnan(prob_ratio)
            %label-switching move
            test(iter,2)  =  1;
            Im  =  Im2;
            phi(iter-1, [label+1,label])  =  phi(iter-1, [label, label+1]);
            mu (iter-1, [label+1,label])  =  mu (iter-1, [label, label+1]);
            if label  <  model_setup.n_cluster-1
                level(iter-1, [label+1, label])  =  level(iter-1, [label, label+1]);
                alpha  =  alpha2;
            end
        else 
            test(iter,2)  =  0;
        end
        clear label log_old_prob log_new_prob alpha2 prob_ratio;
        Om  =  Im * tril ( ones( model_setup.n_cluster,  model_setup.n_cluster ),  -1 ); 
        Om  =  Om (:,  1: model_setup.n_cluster-1);
        Z   =  norminv ( unifrnd(0, normcdf(-Om.*alpha)), alpha, 1).*Om;       
        Z   =  Z + Im(:,  1: model_setup.n_cluster - 1 ).*...
               norminv ( unifrnd ( normcdf ( -Im(:, 1: model_setup.n_cluster - 1 ) .* alpha), 1), alpha, 1);
        Z(isinf(Z))=0;
        nc  =  sum(Im,1); 
        index  =  Im ( :,  1:  model_setup.n_cluster - 1 ) + Om;
        
        %% Update mixture normal mean  
        
        xi      =   post_xi  (  nc,  prior.mu_xi,  phi(iter-1,:));
        mid     =   sum ( Im .* ( repmat ( data_info.dep,  1,  model_setup.n_cluster)  ),  1);
        nu      =   post_nu  (  xi,  prior.mu_xi,  phi(iter-1,:),  mid,  prior.mu_nu);
        mu(iter,:) =   normrnd ( nu,  1 ./ sqrt(xi) );
        
        % Update mixture normal precision
        phi_new_b  =  err2       ( repmat (data_info.dep,  1,  model_setup.n_cluster )...
            .*Im,  Im .* repmat ( mu(iter,:),  observation_num,  1) );
        phi(iter,:)   =  update_phi ( prior.phi_a  +  nc/2  , phi_new_b/2  +  1./prior.phi_s  );  
        
        %% Update level 
        no          =  sum(index, 1);
        xi          =  post_xi ( no,  level_xi(iter-1), 1);
        alpha       =  alpha  -  repmat ( level(iter-1,:),  observation_num,  1); 
        mid         =  sum ( ( Z - alpha ) .* index,  1 );
        nu          =  post_nu ( xi,  level_xi(iter-1), 1, mid, prior.level_nu);
        level(iter,:)  =  normrnd  ( nu,  1./sqrt(xi) );
        alpha       =  alpha  +  repmat ( level(iter,:),  observation_num,  1);
        
        %% Update coefficients of category predictors
        observation_category  =  zeros ( 1,  sum(levels_in_category));
        sum_index             =  sum   ( index,  2);
        if  n_category  >  0
            for  k  =  1:  n_category
                for  j  =  1:  levels_in_category(k)
                    observation_category ( sub(k)+j ) = sum ( sum_index (data_info.category_predictor(:,k) == sub(k)+j ) );
                end   
                alpha = alpha - repmat(category(iter-1,  data_info.category_predictor(:,k))',...
                                           1,  model_setup.n_cluster-1); 
                mid_alpha  =  sum ( index .* ( Z - alpha), 2); 
                xi         =  post_xi  (observation_category ( sub(k)+2 : sub(k+1) ), category_xi (iter-1, k), 1);
                mid        =  zeros (1, levels_in_category(k));
                for  j  =  1:  levels_in_category(k)
                    mid(j)  =  sum(  mid_alpha(  data_info.category_predictor(:,k) == sub(k)+j) );
                end
                nu  =  post_nu( xi,  category_xi(iter-1, k), 1,  mid(2: end), prior.category_nu(sub(k)+2 : sub(k+1) ) );
                category(iter,  sub(k)+2:  sub(k+1))  =  normrnd(nu,  1./sqrt(xi));
                alpha  =  alpha +  repmat (category(iter,  data_info.category_predictor(:,k))',...
                                           1,  model_setup.n_cluster-1); 
            end
        end

        %% Update coefficients of continuous predictors
        if  n_continuous  >  0
            for  k  =  1:  n_continuous
                alpha = alpha - repmat ( data_info.continuous_predictor(:,k) * ...
                                              continuous(iter-1,k),  1,  model_setup.n_cluster-1);
                mid_alpha  =  data_info.continuous_predictor(:,k)'*sum ( index .* ( Z - alpha), 2); 
                xi  =  post_xi (data_info.continuous_predictor(:,k)'*(data_info.continuous_predictor(:,k).*sum(index,2)),  ...
                                prior.continuous_xi,  1);
                nu  =  post_nu (xi, prior.continuous_xi, 1, mid_alpha, prior.continuous_nu(k));
                continuous(iter, k) = normrnd ( nu,  1./sqrt(xi) );
                alpha  =  alpha  +  repmat ( data_info.continuous_predictor(:,k) * ...
                                              continuous(iter,k),  1,  model_setup.n_cluster-1);
            end
        end
        
        %% Update hyper-parameter
        if n_category > 0
            new_b = zeros(1, n_category);
            for j = 1: n_category
                new_b(j) = err2( category (iter, 2+sub(j):sub(j+1))', prior.category_nu (2+sub(j): sub(j+1))')/2;
            end
            category_xi(iter,:)=  update_phi( posterior_category_xi_a,   new_b+1./prior.category_xi_s);
        end
        new_b                  =  err2      ( level(iter,:)',            prior.level_nu')/2;
        level_xi(iter)         =  update_phi( posterior_level_xi_a,      1./prior.level_xi_s+new_b); 
        post_likelihood(iter)  =  sum       ( log(normpdf(data_info.dep, Im*mu(iter,:)',  1./sqrt(Im*phi(iter,:)') ) ) );
        
        if  iter  ==  model_setup.iteration
            last_sampler  =  struct('category',category(iter,:),'level',level(iter,:),...
                                    'continuous', continuous(iter,:), ...
                                    'phi',phi(iter,:),'mu',mu(iter,:),'category_xi',category_xi(iter,:),...
                                    'level_xi',level_xi(iter,:));
        
        end
    end
    Sampler = struct('category', category, 'level', level, ...
                     'continuous', continuous, 'phi', phi, 'mu', mu, 'category_xi', ...
                     category_xi, 'level_xi', level_xi, 'test', ...
                     test, 'change',change,'post_likelihood',post_likelihood,'last_sampler',last_sampler);
end
