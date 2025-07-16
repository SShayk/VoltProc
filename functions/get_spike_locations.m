function [k_spikes, parameters] = get_spike_locations(F_det, F_AP, N_f, dF_ur,dF_dr, varargin)
%get_spike_locations returns indices of spike locations given qualifying conditions
% Inputs:
%   F_det: vector or 2D matrix of detrended voltage trace data [rows = rois/traces, cols = timepoints] 
%   F_AP: potential action potential magnitudes (same dimenstions as F_det)
%   N_f: baseline noise (same dimensions as F_det)
%   dF_ur,dF_dr: upward-and downward-recctified voltage traces (same dimensions as F_det)
%   Optional ('Name', value) inputs:
%       'fs': sampling frequency in Hz (default 800)
%       'TRectBaseline': time window in seconds used to get baseline [mean of upward-rectified differential]/[stdev of downward-rectified differential] trace for condition 1 (default 1)
%       'TDetBaseline': time window in seconds used to get baseline mean/stdev of non-rectified detrended trace for condition 2 (default 0.1)
%            'TURbaseline' and 'Tstdev' are the window width on either side of the current frame, so ~half of length of full window
%       'NFactor12': factor to multiply stdev by for thresholding in conditions 1 and 2 (default 3)
%       'NFactor3': factor to multiply noise by for thresholding in condition 3 (default 4)

% Outputs:
%   k_spikes: locations of spikes (logical, same dimensions as input traces)
%   parameters: struct containing parameters as subfields


% default parameters
fs = 800; % Hz, sample frequency
t_rect_baseline = 1;  % s (+/-), moving window to get mean/stdev of upward/downward-rectified differential  trace
t_det_baseline = 0.1; % s (+/-), moving window to get mean/stdev of detrended trace
N_factor_12 = 3; % factor for conditions 1 and 2
N_factor_3 = 4; % factor for condition 3

if nargin > 5
    p = inputParser;
    addRequired(p,'F_det',@isnumeric)
    addRequired(p,'N_f',@isnumeric)
    addRequired(p,'dF_ur',@isnumeric)
    addRequired(p,'dF_dr',@isnumeric)

    addParameter(p,'fs',fs, @(x)isnumeric(x));
    addParameter(p,'TRectBaseline',t_rect_baseline, @(x)isnumeric(x));
    addParameter(p,'TDetBaseline',t_det_baseline, @(x)isnumeric(x));
    addParameter(p,'NFactor12',N_factor_12, @(x)isnumeric(x));
    addParameter(p,'NFactor3',N_factor_3, @(x)isnumeric(x));


    parse(p, F_det, F_AP, N_f, dF_ur,dF_dr, varargin{:})


    fs = p.Results.fs;
    t_rect_baseline = p.Results.TRectBaseline;
    t_det_baseline = p.Results.TDetBaseline;
    N_factor_12 = p.Results.NFactor12;
    N_factor_3 = p.Results.NFactor3;
end



% condition 1
C1 = dF_ur > movmean(dF_ur,2*(t_rect_baseline*fs)) + N_factor_12*movstd(dF_dr,2*(t_rect_baseline*fs));
% condition 2
C2 = F_det > movmean(F_det,2*(t_det_baseline*fs),2) + N_factor_12*N_f;
% condition 3
C3 = F_AP > N_factor_3 *N_f;

k_spikes = C1 & C2 & C3; % spikes occur where all conditions are satisfied






parameters.fs =fs;
parameters.t_rect_baseline = t_rect_baseline;
parameters.t_det_baseline = t_det_baseline;
parameters.N_factor_12 = N_factor_12;
parameters.N_factor_3 = N_factor_3;
end