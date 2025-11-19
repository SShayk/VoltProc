function [H] = scatter_AP(scatter_k,scatter_val, titlestr, ystr)
%PLOT_STACKED scatter desired metric for relevant indices, separated by ROI
% Inputs:
%   scatter_k:  indices of points to scatter [logical with size #ROIs x #timepoints, with 1s at desired scatter points]
%   scatter_val:values of scatter points (values where scatter_k is 1 will be plotted)
%   titlestr:   figure name (string)
%   ystr:       y-axis label (string)
% Output:
%   H: figure handle

NR = size(scatter_k,1);


H = figure('Name',titlestr);

hold on
for nr = 1:NR
    if nnz(scatter_k(nr,:))
        scatter(nr*ones(1,nnz(scatter_k(nr,:))), scatter_val(nr,scatter_k(nr,:)),30,'filled','k')
    end
end
xlim([0.5, NR + 0.5])
xticks(1:NR)
ylim([0 max(ylim)])
ylabel(ystr)
xlabel('ROI')
whitefig


end

