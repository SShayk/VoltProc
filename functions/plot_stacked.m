function [H] = plot_stacked(t,traces,scatter_k, titlestr, ystr, axis_off)
%PLOT_STACKED plot long traces stacked vertically for easy viewing
% Inputs:
%   t:          vector of time points in seconds (x-axis) [1 x #timepoints]
%   traces:     array of traces [#ROIs x #timepoints]
%   scatter_k:  indices of points to scatter [logical with size #ROIs x #timepoints, with 1s at desired scatter points]
%               - must be empty if not adding scatter points
%   titlestr:   figure name (string)
%   ystr:       y-axis label (string)
%   axis_off    (optional) 1 if x axis to be shown for all plots, 0 for
%                   only lowest plot
% Output:
%   H: figure handle

NR = size(traces,1);


H = figure('Name',titlestr);

if ~exist('axis_off','var')
    axis_off = 0;
end

for nr = 1:NR
    subplot(NR,1, nr), hold on
    
    plot(t,traces(nr,:,1),'k')
    
    if ~isempty(scatter_k) && nnz(scatter_k(nr,:,1))
        scatter(t(scatter_k(nr,:,1)), traces(nr,scatter_k(nr,:,1)),15,'r','filled')
    end

    if axis_off && nr~= NR, set(gca().XAxis,'Visible', 'off'); end
    box off
    ylabel(ystr)
end

xlabel('time (s)')

whitefig
end

