% expects traces formatted into a matrix named tr (with dimensions ROIs x timepoints) 

% each function assumes sample frequency of 800 Hz - pass optional parameter
% tDo change this and other filtering parameters

fs = 800;
nframes = size(tr,2);
Nrois = size(tr,1);
tvec = (1:nframes)*(1/fs);

%% extract F values
F_proc = process_voltage(tr);
% get action potential values from detrended data
[F_proc.F_AP, F_proc.params_AP] = calc_APs(F_proc.F_det);

%% get spike locations
[F_proc.t_s, F_proc.parameters_kspikes] = get_spike_locations(F_proc.F_det, F_proc.F_AP, F_proc.N_f, F_proc.dF_ur, F_proc.dF_dr); 
    
%% get Vm and other baseline calculations
[F_proc.F_sub, F_proc.F_nospike, F_proc.F_0, F_proc.params_baselines] = get_subthreshold_trace(tr, F_proc.t_s);










%% plot traces
figure('Name','raw F')
plot(tvec,-tr), xlabel('time (s)'), ylabel('-F')
whitefig

%% plot detrended F with spikes
plot_stacked(tvec_valid,F_proc.F_det(:,k_valid),F_proc.t_s(:,k_valid),['detrended F only      ',titlestr],'-F',0);

%% plot DF/F with spikes
dff_trace = -(tr-F_proc.F_0)./F_proc.F_0;
dff_AP = F_proc.F_AP./F_proc.F_0; % calculation only valid at detected spikes

H_dff_trace = plot_stacked(tvec,dff_trace,F_proc.t_s,'DFF(traces)','-\DeltaF/F');
standardize_ylims(H_dff_trace, [Nrois 1], [0 0]);
