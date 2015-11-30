function Mean_Comp(average, name) 
%http://stats.stackexchange.com/questions/64880/software-to-produce-confidence-interval-error-bars-from-summary-statistics-witho
figure;
for i = 1:size(average,1)                                       % connect upper and lower bound with a line
    line([i i],[average(i,1) average(i,2)], 'LineWidth',2)
    hold on;
end
plot(1:size(average,1),average(:,3),'o','markersize', 10,'MarkerFaceColor','r')           % plot the mean
hold on;
plot(1:size(average,1),average(:,1),'v','markersize', 10,'color','r')              % plot lower CI boundary
hold on;
plot(1:size(average,1),average(:,2),'^','markersize', 10,'color','r')              % plot upper CI boundary
hold on;
axis([ 0 size(average,1)+1  min(average(:,1))*0.8 max(average(:,2))*1.1])  % scale axis
set(gca,'XTick',1:size(average,1));
set(gca,'XTickLabel',name,'FontSize',26);
% title('Average Comparison');
box off;