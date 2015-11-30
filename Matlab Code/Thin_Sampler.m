function thinned_sampler = Thin_Sampler(gibbs_sampler, sampler_num)
% to thin the sampler and keep sampler_num samplers
rng shuffle;
iteration = size(gibbs_sampler.mu,1);
if iteration >= sampler_num
    gap = floor(iteration/sampler_num);
    max_start = iteration - (sampler_num-1)*gap;
    start = randi(max_start,1);
    thinned_sampler = gibbs_sampler;
    sname = fieldnames(thinned_sampler);
    for j=1:numel(sname)
        thinned_sampler.(sname{j}) = thinned_sampler.(sname{j})(start:gap:start+(sampler_num-1)*gap,:);
    end
else
    multi_time = ceil (sampler_num/iteration);
    sname = fieldnames(gibbs_sampler);
    for j=1:numel(sname)
        gibbs_sampler.(sname{j}) = repmat(gibbs_sampler.(sname{j}),multi_time,1);
    end
    thinned_sampler = gibbs_sampler;
    max_start = multi_time * iteration - sampler_num + 1;
    start = randi(max_start, 1);
    for j=1:numel(sname)
        thinned_sampler.(sname{j}) = thinned_sampler.(sname{j})(start:sampler_num+start,:);
    end
end