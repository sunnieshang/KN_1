function DensityFK_Plot(density_info, data_info, density_estimates, type, mu)
% plot the density estimation lines
    dep = data_info.dep;
    indep = data_info.indep;
    levels_in_factors = data_info.levels_in_factors;
    sub = levels_in_factors;
        sub(2) = levels_in_factors(1)+levels_in_factors(2);
        sub(3) = sub(2) + levels_in_factors(3);
    
    airline = [density_info(:).airline];
    route = [density_info(:).route];
    name = {density_info(:).name};
    n_plot = length(name);  
    n_cluster = length(mu);  
    for i = 1:n_plot
        delay = dep(indep(:,1)==airline(i) & indep(:,2)==route(i));
        y = density_estimates(i).y;
        start = density_estimates(i).start;
        matrix = density_estimates(i).matrix;
        W=density_estimates(i).decompose;
        n_chain = size(start,1);
        [n,x] = hist(delay,y(1:2:end));
        h = figure;
        bar(x,n/length(delay)/diff(x(1:2)));
        hold on;      
        d_mean=mean(matrix,1); % mean of estimated density
        d_95=quantile(matrix,[0.025,0.975],1);
        plot(y,d_mean,'red',y,d_95,'cyan'); 
        hold off
        title(sprintf('%s Density of %s', type, name{i}));
        saveas(h,sprintf('%s-Den-%s',type, name{i}),'png');
        
        h = figure;
        bar(x,n/length(delay)/diff(x(1:2)));
        hold on;
        for j=1:1:n_chain
            plot(y,start(j,:),'--');
        end
        hold off;
        title(sprintf('%s Start of %s', type, name{i}));
        saveas(h,sprintf('%s-Start-%s',type,name{i}),'png');
        
        h=figure;
        p=floor(n_cluster^0.5);
        q=ceil(n_cluster/p);
        for j=1:n_cluster
            subplot(p,q,j);
            plot(y,W(j,:));
            title(sprintf('mu=%d', mu(j)));
            y_lim=ylim;
            ylim([0 max(0.01,y_lim(2))])
        end
        saveas(h,sprintf('%s-decomp-%s',type,name{i}),'png');
    end
end