function [F_subthresh, F_nospike, F0, parameters] = get_subthreshold_trace(F_raw,k_spikes, varargin)
%get_subthreshold_trace extracts subthreshold fluctuations after removing spikes
% Inputs:
%   F_raw: vector or 2D matrix of voltage trace data [rows = rois/traces, cols = timepoints] 
%   k_spikes: locations of spikes (logical, same dimensions as F_raw)
%   Optional ('Name', value) inputs:
%       'fs': sampling frequency in Hz (default 800)
%       'TNoSpike': time window in seconds to remove around spike [pre- and post-spike] (default [.001 .002])
%       'TReplace': time window in seconds to average over to get moving mean (on either side of frame) for replacement (default .005)
%       'fBandpass': bandpass frequency in Hz [upper and lower bounds] (default [1 50])
%       'fLowpass': lowpass frequency in Hz used to calculate F0 from spike-removed data (default 1)
% Outputs:
%   F_subthresh: subthreshold voltage traces (same dimensions as F_raw)
%   F_nospike: spike-removed voltage traces (same dimensions as F_raw)
%   F0: extracted baseline trend (same dimensions as F_raw)
%   parameters:  struct containing parameters as subfields

% default values
fs = 800; % Hz, sampling frequency
T_nospike_minus = .001; % s, pre-timepoint component of window removed around each spike
T_nospike_plus = .002; % s, post-timepoint component of window removed around each spike
T_replace = .005; % s (+/-), moving average window to get average trace to replace spike window with
F_bp = [1 50]; % Hz, bandpass frequencies to extract subthreshold fluctuations
F_lp = 1; % Hz,  lowpass cutoff frequency to extract baseline trend


if nargin >2
    p = inputParser;
    addRequired(p,'F_raw', @(x)isnumeric(x))
    addRequired(p,'k_spikes', @(x)islogical(x))

    addParameter(p,'fs',fs, @(x)isnumeric(x))
    addParameter(p,'TNoSpike', [T_nospike_minus T_nospike_plus], @(x)isnumeric(x)&&length(x)==2)
    addParameter(p,'TReplace',T_replace, @(x)isnumeric(x))
    addParameter(p,'fBandpass',F_bp, @(x)isnumeric(x)&&length(x)==2)
    addParameter(p,'fLowpass',F_lp, @(x)isnumeric(x)&&length(x)==2)

    parse(p,F_raw,k_spikes,varargin{:})
    
    fs = p.Results.fs;
    T_nospike_minus = p.Results.TNoSpike(1);
    T_nospike_plus = p.Results.TNoSpike(2);
    T_replace = p.Results.TReplace;
    F_bp = p.Results.fBandpass;
    F_lp = p.Results.fLowpass;

end


nos_window = -round(abs(T_nospike_minus)*fs):round(T_nospike_plus*fs); % window to replace around each spike
mm_all = movmean(F_raw.',round(T_replace*fs)).'; % moving average at all points

F_nospike = F_raw;
for nr = 1:size(F_raw,1)
    for ks = find(k_spikes(nr,:))
        % replace window around current spike with moving average
        F_nospike(nr,ks+nos_window) = mm_all(nr,ks+nos_window);
    end
end

% bandpass to get Vm
F_subthresh = bandpass(F_nospike.', F_bp, fs).';

F0 = lowpass(F_nospike.',F_lp,fs).';


parameters.fs = fs;
parameters.T_nospike_minus = T_nospike_minus;
parameters.T_nospike_plus = T_nospike_plus;
parameters.T_replace = T_replace;
parameters.F_bp = F_bp;
parameters.F_lp = F_lp;
end