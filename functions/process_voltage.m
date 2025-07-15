function Fp = process_voltage(tr, varargin)
%process_voltage extracts signal components from Voltron voltage trace data
% Inputs: 
%   tr: vector or 2D matrix of raw voltage trace data [rows = rois/traces, cols = timepoints] 
%   Optional ("Name", value) inputs
%   
% Outputs:
%   Fp: struct containing each trace/component as a field, as well as a
%   parameters field with each parameter as a subfield


% default parameters
fs = 800; % Hz, sample frequency
f_hp_det = 1; % Hz, frequency at which to detrend
f_hp_vm = 50; % Hz, frequency at which to filter out Vm fluctuations

t_av_hp = 0.2; % s (+/-), moving average window to get baseline of highpass filtered trace
t_av_nf = 1; % s (+/-), moving stdev window to get noise floor of trace

if nargin > 1
    p = inputParser;
end

    Fp.F_det = -highpass(tr.',f_hp_det,fs).'; % detrend to remove bleaching decay, 
                                                % and invert so that Voltron spikes are positive

    Fp.F_hp = highpass(Fp.F_det.',f_hp_vm, fs).'; % highpass filter again to remove subthreshold activity
    Fp.F_hp_mean = movmean(Fp.F_hp.',2*round(t_av_hp*fs)).'; % get baseline of highpass filtered trace

    Fp.F_dr  = min(cat(3,Fp.F_hp, Fp.F_hp_mean),[],3); % get downward-rectified trace (noise only)
    Fp.F_ur =  max(cat(3,Fp.F_hp, Fp.F_hp_mean),[],3); % get upward-rectified trace (contains spikes)
    
    Fp.N_f = 2*movstd(Fp.F_dr.',2*round(t_av_nf*fs)).'; % calculate noise floor


% save parameters
Fp.parameters.fs = fs;
Fp.parameters.f_hp_det = f_hp_det;
Fp.parameters.f_hp_vm = f_hp_vm;
Fp.parameters.t_av_hp = t_av_hp;
Fp.parameters.t_av_nf = t_av_nf;
end