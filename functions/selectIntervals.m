function intervals = selectIntervals(axHandle)
    % selectIntervals - Interactively select x-axis intervals on a plot
    %
    % Usage: intervals = selectIntervals(axHandle)
    %
    % Left-click to mark interval boundaries (pairs of clicks)
    % Right-click or press Enter when done
    %
    % Returns: intervals - Nx2 matrix where each row is [x_start, x_end]

    if nargin < 1
        axHandle = gca;
    end
    
    axes(axHandle); % Make this the current axes
    hold(axHandle, 'on');
    
    intervals = [];
    shadeHandles = [];
    
    % fprintf('Select intervals:\n');
    % fprintf('  - Left-click twice to define each interval\n');
    % fprintf('  - Right-click or press Enter when done\n\n');
    
    clickCount = 0;
    tempX = [];
    
    % while true
        % [x, ~, button] = ginput(1);
        [x, ~, button] = ginput(2);

        % Right-click or Enter to finish
        % if isempty(button) || button ~= 1
            % break;
        % end
        
        % clickCount = clickCount + 1;
        % tempX = [tempX; x];
        
        % Plot vertical line at click point
        yLim = ylim(axHandle);
        plot(axHandle, [x(1) x(1)], yLim, 'r--', 'LineWidth', 1);
        plot(axHandle, [x(2) x(2)], yLim, 'r--', 'LineWidth', 1);
        % Every second click completes an interval
        % if mod(clickCount, 2) == 0
            % Get the last two clicks
            % x1 = min(tempX(end-1:end));
            % x2 = max(tempX(end-1:end));
            
            % Add interval
            % intervals = [intervals; x1, x2];
            intervals = [intervals; x(1), x(2)];
            % Shade the region
            h = fill(axHandle, [x(1) x(2) x(2) x(1)], ...
                     [yLim(1) yLim(1) yLim(2) yLim(2)], ...
                     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            shadeHandles = [shadeHandles; h];
            
            % fprintf('Interval %d: [%.3f, %.3f]\n', ...
                    % size(intervals,1), x(1), x(2));
            
            % Clear temp storage
            % tempX = [];
        % end
    % end
    
    % fprintf('\nSelection complete!\n');
    % fprintf('Total intervals selected: %d\n', size(intervals,1));
end