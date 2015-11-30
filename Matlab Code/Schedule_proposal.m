function proposal = Schedule_proposal(delay_level, service_level, cdf, axis)
x_length = size(cdf,2); 
iter = size(cdf,1);
proposal = zeros(1,3);
mid = zeros(iter,1);
for i=1:iter
    for j=1:x_length-1
        if cdf(i,j)<=service_level && cdf(i,j+1)>service_level
            mid(i) = axis(j);
        end
    end           
mid = mid - delay_level;
proposal = [quantile(mid,[0.025,0.975]),mean(mid)];
end