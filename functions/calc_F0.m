function [F0, parameters] = calc_F0(F_in, varargin)
%calc_F0 calculate fluorescence (bleaching) trend by lowpass filtering
% calc_F0(F_in) filters at 1 Hz, assuming a sampling frequency of 800 Hz
% calc_F0(F_in, f_lp) filters at chosen frequency f_lp, assuming a sampling frequency of 800 Hz 
% calc_F0(F_in, f_lp, fs) filters at chosen frequency f_lp Hz
%
% Inputs: 
%   F_in: vector or 2D matrix of spike-removed voltage trace data [rows = rois/traces, cols = timepoints] 
%   Optional inputs:
%       f_lp: lowpass cutoff frequency in Hz (default 1)
%       fs: sampling frequency in Hz (default 800)
% Outputs:
%   F_0: extracted trend (same dimensions as F_in)
%   parameters: struct containing parameters as subfields
 
p = inputParser;
addRequired(p,'F_in')
addOptional(p,'f_lp', 1, @(x)isnumeric(x))
addOptional(p,'fs', 800, @(x)isnumeric(x))
parse(p,F_in,varargin{:})
f_lp = p.Results.f_lp;
fs = p.Results.fs;

F0 = lowpass(F_in.',f_lp,fs).';


parameters.fs = fs;
parameters.f_lp = f_lp;
end
