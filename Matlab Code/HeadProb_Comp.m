function HeadProb_Comp(head_prob, name) 
%http://stats.stackexchange.com/questions/64880/software-to-produce-confidence-interval-error-bars-from-summary-statistics-witho
figure;
for i = 1:size(head_prob,1)                                       % connect upper and lower bound with a line
    line([head_prob(i,1) head_prob(i,2)], [i i],'LineWidth',2)
    hold on;
end
plot(head_prob(:,3),1:size(head_prob,1),'o','markersize', 5,'MarkerFaceColor','r')           % plot the mean
hold on;
plot(head_prob(:,1),1:size(head_prob,1),'<','markersize', 4,'color','r')              % plot lower CI boundary
hold on;
plot(head_prob(:,2),1:size(head_prob,1),'>','markersize', 4,'color','r')              % plot upper CI boundary
hold on;
box off;
axis([min(head_prob(:,1))*0.5 max(head_prob(:,2))*1.25 0 size(head_prob,1)+1 ])  % scale axis
set(gca,'YTick',1:size(head_prob,1));
set(gca,'YTickLabel',name);
title('Head Probability Comparison');