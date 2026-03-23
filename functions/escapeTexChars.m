function escapedStr = escapeTexChars(inputStr)
    % Escape backslash first (must be done separately)
    escapedStr = regexprep(inputStr, '\\', '\\\\');
    
    % Escape other TeX special characters: ^ _ { } $ % & # ~
    escapedStr = regexprep(escapedStr, '([\^_{}$%&#~])', '\\$1');
end