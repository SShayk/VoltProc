function [YL] = standardize_ylims(H,sz_subplots, YL)
%STANDARDIZE_YLIMS set all y-axes to the same setting (based on
% maxima/minima of all subplots)
% Inputs:
%   H:          figure handle
%   sz_subplots:2-element vector, where 1st value is # of subplot rows in
%               the figure and 2nd value is # of columns
%   YL:         2-element vector of y-axis limits to compare
%               maximum/minimum to
% Outputs:
%   YL:         resulting y-axis limits 

figure(H)

NR = sz_subplots(1);
NC = sz_subplots(2);
for nr = 1:NR
    for nc = 1:NC
        subplot(NR,NC, nc + (nr-1)*NC)
        if min(ylim)<YL(1)
            YL(1) = min(ylim);
        end
        if max(ylim)>YL(2)
            YL(2) = max(ylim);
        end
    end
end

for nr = 1:NR
    for nc = 1:NC
        subplot(NR,NC, nc + (nr-1)*NC)
        ylim(YL)
    end
end

end