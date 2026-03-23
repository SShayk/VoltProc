function [selectedIntervals, selectedIndices] = select1ExistingInterval(axHandle, fillHandles, intervals)
    % selectExistingIntervals - Click within shaded regions to select intervals
    %
    % Usage: [selectedIntervals, selectedIndices] = selectExistingIntervals(axHandle, fillHandles, intervals)
    %
    % Inputs:
    %   axHandle - axes handle
    %   fillHandles - array of fill object handles (from previous shading)
    %   intervals - Nx2 matrix of interval bounds [x_start, x_end]
    %
    % Outputs:
    %   selectedIntervals - Mx2 matrix of selected interval bounds
    %   selectedIndices - indices of selected intervals
    %
    % Controls:
    %   Left-click - Select/deselect interval
    %   Right-click or Enter - Finish selection

    if nargin < 1 || isempty(axHandle)
        axHandle = gca;
    end
    
    if nargin < 2 || isempty(fillHandles)
        % Try to find all fill objects in the axes
        fillHandles = findobj(axHandle, 'Type', 'patch');
    end
    
    if nargin < 3
        % Extract intervals from fill handles
        intervals = zeros(length(fillHandles), 2);
        for i = 1:length(fillHandles)
            xData = fillHandles(i).XData;
            intervals(i, :) = [min(xData), max(xData)];
        end
    end
    
    axes(axHandle);
    
    % Store original colors
    originalColors = cell(length(fillHandles), 1);
    originalAlphas = zeros(length(fillHandles), 1);
    for i = 1:length(fillHandles)
        originalColors{i} = fillHandles(i).FaceColor;
        originalAlphas(i) = fillHandles(i).FaceAlpha;
    end
    
    selectedIndices = [];
    
    % fprintf('Click within intervals to select/deselect them\n');
    % fprintf('Right-click or press Enter when done\n\n');
    
    % title(axHandle, 'Click intervals to select (highlighted in yellow)');
    
        [x, ~, ~] = ginput(1);
        
        
        % Find which interval was clicked
        for i = 1:size(intervals, 1)
            intervals(i,:) = sort(intervals(i,:));
            if x >= intervals(i,1) && x <= intervals(i,2)
                selectedIndices = i;
            end
        end
        
    
        % Return selected intervals
        selectedIntervals = intervals(selectedIndices, :);
    
        title(axHandle, '');
end