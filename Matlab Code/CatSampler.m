function sampler = CatSampler(sampler1,sampler2)
sampler = sampler1;
sname = fieldnames(sampler);
for j=1:numel(sname)
    sampler.(sname{j}) = [sampler.(sname{j});sampler2.(sname{j})];
end  