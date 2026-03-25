function [interval, shadehandle, linehandles] = select1Interval(axHandle, yLim)
    % select1Interval - Interactively select x-axis intervals on a plot
    %
    % Usage: interval = select1Interval(axHandle) (ylim argument optional)
    %
    % Left-click to mark interval boundaries (pairs of clicks)
    % Right-click or press Enter when done
    %
    % Returns: intervals - Nx2 matrix where each row is [x_start, x_end]
    %          shadehandle: handle to area object for current interval
    %          linehandles: handle to line objects for either side of interval
    %  
    if nargin < 1
        axHandle = gca;
    end

    if nargin <2
        yLim = ylim(axHandle);
    end
    
    axes(axHandle); % Make this the current axes
    hold(axHandle, 'on');
    
    
    [x, ~, ~] = ginput(2);
    
    % Plot vertical line at click point
    
    linehandles(1) = plot(axHandle, [x(1) x(1)], yLim, 'r--', 'LineWidth', 1,'HandleVisibility','off');
    linehandles(2) =plot(axHandle, [x(2) x(2)], yLim, 'r--', 'LineWidth', 1,'HandleVisibility','off');
        
    % Add interval
    interval = [x(1), x(2)];
    % Shade the region
    shadehandle = fill(axHandle, [x(1) x(2) x(2) x(1)], ...
             [yLim(1) yLim(1) yLim(2) yLim(2)], ...
             'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none','HandleVisibility','off');
            
end