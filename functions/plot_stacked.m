function [H] = plot_stacked(t,traces,scatter_k,scatter_val, titlestr, ystr)
%plot_stacked plot long traces stacked vertically for easy viewing
% Inputs:
%   t: vector of time points in seconds (x-axis) [1 x #timepoints]
%   traces: array of traces [#ROIs x #timepoints]
%   scatter_k: indices of points to scatter [logical with size #ROIs x #timepoints, with 1s at desired scatter points]
%       must be empty if not adding scatter points
%   scatter_val: values of scatter points (values where scatter_k is 1 will be plotted)
%       can be empty if not adding scatter points
%   titlestr: figure name (string)
%   ystr: y-axis label (string)
% Output:
%   H: figure handle

NR = size(traces,1);


figure('Name',titlestr)


for nr = 1:NR
    subplot(NR,1, nr), hold on
    
    plot(t,traces(nr,:,1),'k')
    
    if ~isempty(scatter_k) && nnz(scatter_k(nr,:,1))
        scatter(t(scatter_k(nr,:,1)), scatter_val(nr,scatter_k(nr,:,1)),15,'r','filled')
    end

    if nr~= NR, set(gca().XAxis,'Visible', 'off'); end
    box off
    ylabel(ystr)
end

xlabel('time (s)')

whitefig
end

