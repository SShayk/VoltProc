function intervals = selectIntervalsAdvanced(axHandle)
    if nargin < 1
        axHandle = gca;
    end
    
    axes(axHandle);
    hold(axHandle, 'on');
    
    intervals = [];
    
    % Instructions
    title(axHandle, 'Press SPACE to start new interval, ENTER to finish');
    fprintf('Controls:\n');
    fprintf('  SPACE - Start selecting a new interval\n');
    fprintf('  ENTER - Finish and return intervals\n');
    fprintf('  ESC   - Cancel current interval\n\n');
    
    fig = axHandle.Parent;
    
    while true
        % Wait for keypress
        waitforbuttonpress;
        key = get(fig, 'CurrentCharacter');
        
        if double(key) == 13 % Enter - done
            break;
        elseif double(key) == 32 % Space - new interval
            % Select two points
            title(axHandle, 'Click START of interval...');
            [x1, ~] = ginput(1);
            if isempty(x1), continue; end
            
            yLim = ylim(axHandle);
            line1 = plot(axHandle, [x1 x1], yLim, 'g-', 'LineWidth', 2);
            
            title(axHandle, 'Click END of interval...');
            [x2, ~] = ginput(1);
            if isempty(x2)
                delete(line1);
                continue;
            end
            
            % Sort endpoints
            xStart = min(x1, x2);
            xEnd = max(x1, x2);
            
            % Shade region
            fill(axHandle, [xStart xEnd xEnd xStart], ...
                 [yLim(1) yLim(1) yLim(2) yLim(2)], ...
                 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            
            delete(line1);
            plot(axHandle, [xStart xStart], yLim, 'r--', 'LineWidth', 1);
            plot(axHandle, [xEnd xEnd], yLim, 'r--', 'LineWidth', 1);
            
            intervals = [intervals; xStart, xEnd];
            
            title(axHandle, sprintf('Interval %d: [%.2f, %.2f] | Press SPACE for next, ENTER to finish', ...
                   size(intervals,1), xStart, xEnd));
        end
    end
    
    title(axHandle, 'Selection complete');
end