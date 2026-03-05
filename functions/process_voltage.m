function Fp = process_voltage(tr, varargin)
%process_voltage extracts signal components from Voltron voltage trace data
% Inputs: 
%   tr: vector or 2D matrix of raw voltage trace data [rows = rois/traces, cols = timepoints] 
%   Optional ('Name', value) inputs:
%       'fs': sampling frequency in Hz (default 800)
%       'fDetrend': frequency in Hz at which to highpass signal for detrending (default 1)
%       'fSubthreshold': frequency in Hz at which to highpass signal for removing Vm fluctuations (default 50)
%       'Tmean': time window in seconds used to get baseline of filtered trace (default 0.2)
%       'Tstdev': time window in seconds used to get standard deviation to calculate noise (default 1)
%           'Tmean' and 'Tstdev' are the window width on either side of the current frame, so ~half of length of full window
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
    addRequired(p,'tr',@isnumeric)
    addParameter(p,'fs',fs, @(x)isnumeric(x));
    addParameter(p,'fDetrend',f_hp_det, @(x)isnumeric(x));
    addParameter(p,'fSubthreshold',f_hp_vm, @(x)isnumeric(x));
    addParameter(p,'Tmean',t_av_hp, @(x)isnumeric(x));
    addParameter(p,'Tstdev',t_av_nf, @(x)isnumeric(x));
    addParameter(p,'highpasstype',0, @(x)islogical(x));
    parse(p, tr, varargin{:})

    fs = p.Results.fs;
    f_hp_det = p.Results.fDetrend;
    f_hp_vm = p.Results.fSubthreshold;
    t_av_hp = p.Results.Tmean;
    t_av_nf = p.Results.Tstdev;
    hp_type = p.Results.highpasstype;
end


if hp_type
       
    for nr = 1:size(tr,1)
       Fp.F_det(nr,:) = -tr(nr,:) - fastsmooth(-tr(nr,:), fs/f_hp_det,1,1);
       mvmn = fastsmooth(Fp.F_det(nr,:), round(fs/f_hp_vm),1,1);
       Fp.F_hp(nr,:) = Fp.F_det(nr,:) - mvmn;
   end
else
       Fp.F_det = -highpass(tr.',f_hp_det,fs).'; % detrend to remove bleaching decay, 
                                                % and invert so that Voltron spikes are positive
       Fp.F_hp = highpass(Fp.F_det.',f_hp_vm, fs).'; % highpass filter again to remove subthreshold activity
end
    Fp.F_hp_mean = movmean(Fp.F_hp.',2*round(t_av_hp*fs)).'; % get baseline of highpass filtered trace

    Fp.F_dr  = min(cat(3,Fp.F_hp, Fp.F_hp_mean),[],3); % get downward-rectified trace (noise only)
    Fp.F_ur =  max(cat(3,Fp.F_hp, Fp.F_hp_mean),[],3); % get upward-rectified trace (contains spikes)
    
    Fp.N_f = 2*movstd(Fp.F_dr.',2*round(t_av_nf*fs)).'; % calculate noise floor


    Fp.dF_ur = [zeros(size(tr,1),1), diff(Fp.F_ur.').']; %d/dt of upward-rectified trace
    Fp.dF_dr = [zeros(size(tr,1),1), diff(Fp.F_dr.').']; %d/dt of downward-rectified trace


% save parameters
Fp.parameters.fs = fs;
Fp.parameters.f_hp_det = f_hp_det;
Fp.parameters.f_hp_vm = f_hp_vm;
Fp.parameters.t_av_hp = t_av_hp;
Fp.parameters.t_av_nf = t_av_nf;
end