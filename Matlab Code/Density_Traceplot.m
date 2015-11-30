function Density_Traceplot(density_info, density_estimates,n_chain, type)
% plot the traceplot of density
    max_chain = 300;
    [iter, y_length] = size(density_estimates(1).density);
    iter = iter/n_chain;
    sub = zeros(1, n_chain);
    for i=1:n_chain
        sub(i) = 1+(i-1)*iter;
    end
    if iter>max_chain
        iter_gap = floor(iter/max_chain);
    else 
        iter_gap = 1;
    end
    name = {density_info(:).name};
    n_plot = length(name);       
    n_y = 12;
    y_gap = floor(y_length/(n_y-1));
    for i = 1:n_plot
        matrix = density_estimates(i).density;
        y = density_estimates(i).y;
        h=figure;
        for j = 1:n_y
            h=subplot(4, 3, j);
            set(gcf, 'DefaultAxesColorOrder',...
                [1,0,0;0,1,0;0,0,1;1,1,0;1,0,1;0,1,1; 0,0,0;0.4,0.6,1]);
            estimate_matrix = reshape(matrix(:,1+(j-1)*y_gap), iter, n_chain);
            plot(1:iter_gap:iter, estimate_matrix(1:iter_gap:iter,:));
            title(sprintf('y=%d', y(1+(j-1)*y_gap)));  
            set(h,'xlim',[1 iter]);
            if j<n_y
                set(h,'xticklabel',' ');
            end
        end
        saveas(h,sprintf('%s-Den-Trace-%s',type, name{i}),'png');
    end
end