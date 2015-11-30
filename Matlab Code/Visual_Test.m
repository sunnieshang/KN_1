function Visual_Test(real_y, axis, predict_density, name)
    figure;
    [n,x]=hist(real_y,axis(1:2:end));
    bar(x,n/length(real_y)/diff(x(1:2)));
    hold on;
    matrix2 = predict_density;
    matrix = quantile(matrix2,[0.025,0.975],1);
    matrix = [matrix;mean(matrix2,1)];
    plot(axis, matrix(3,:),'--r',axis,matrix(1:2,:),'cyan','LineWidth',2);
    title(name);
    savefig(name);
    %saveas(h,sprintf('%s-Den-%s',type, name{i}),'png');     
end