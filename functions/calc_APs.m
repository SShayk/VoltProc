function [F_AP, parameters]  = calc_APs(F_in, varargin)
%calc_APs calculates potential spike magnitudes at each timepoint
% Inputs:  
%   F_in: vector or 2D matrix of detrended voltage trace data [rows = rois/traces, cols = timepoints] 
%   Optional ('Name', value) inputs:
%       'fs': sampling frequency in Hz (default 800)
%       'Tdetect': window in seconds over which to calculate minimum (default .003 sec)
% Outputs:
%   F_AP: potential spike magnitude at each timepoint (same dimensions as F_in)
%   parameters: struct containing parameters as subfields
 

% default parameters
fs = 800; % Hz, sample frequency
T_detect = .003; % seconds, maximum time before current timepoint to calculate difference
win_detect = -round(fs*T_detect):-1;

if nargin>1
    p = inputParser;
    addRequired(p,'F_in',@isnumeric)
    addParameter(p,'fs',fs, @(x)isnumeric(x));
    addParameter(p,'Tdetect',T_detect, @(x)isnumeric(x) && isinteger(x));
    parse(p,F_in,varargin{:})

    fs = p.Results.fs;
    T_detect = p.Results.Tdetect;
    win_detect = -round(fs*T_detect):-1;

end

F_AP = zeros(size(F_in));
for nt = (-win_detect(1)+1):length(F_in)
        F_AP(:,nt) = max(F_in(:,nt) - F_in(:,nt + win_detect),[],2);
end


parameters.fs = fs;
parameters.T_detect = T_detect;
parameters.win_detect = win_detect;
end