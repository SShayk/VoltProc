% load data
datadir = '/ad\eng/research/eng_research_economo2/SFS/TICO2/20250713/730_left/slit_24/analysis';
load(fullfile(datadir,'signal.mat'))
load(fullfile(datadir,'rois.mat'))

NR = size(roimat,3);
nframes = size(tr,2);
tvec = (1:nframes)*(1/fs);

%%
F_proc = process_voltage(tr);
[F_proc.F_AP, F_proc.params_AP] = calc_APs(F_proc.F_det);

%% get spike locations
[F_proc.t_s, F_proc.parameters_kspikes] = get_spike_locations(F_proc.F_det, F_proc.F_AP, F_proc.N_f, F_proc.dF_ur, F_proc.dF_dr); 
    
%% get Vm
[F_proc.F_sub, F_proc.F_nospike, F_proc.params_baselines] = get_subthreshold_trace(tr, F_proc.t_s);

%% get baselines
[F_proc.F_0, F_proc.params_0] = calc_F0(F_proc.F_nospike);

%% get baselines
    F_nospike = tr;
    nos_window = -round(.001*fs):round(.002*fs);
    for nr = 1:NR
        cur_mm = movmean(tr(nr,:),round(.005*fs));
        for ks = find(t_s(nr,:))
            F_nospike(nr,ks+nos_window) = cur_mm(ks+nos_window);
        end
    end

    for nr = 1:NR
        F_0(nr,:) = lowpass(tr(nr,:),1,fs);
        F_sub(nr,:) = bandpass(F_nospike(nr),[1 50], fs);
    end


%% plot traces


figure
for nr = 1:NR
  
    subplot(1,NR, nr)
    hold on
    plot(-tr(nr,:),'k')
    yyaxis right, plot(f_det(nr,:),'b')
end

%%
figure
YL = [0 0];
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,f_hp(nr,:),'k')
    plot(tvec,f_hp_mean(nr,:),'r')
    scatter(tvec(t_s(nr,:)), f_hp(nr,t_s(nr,:)),'r','filled')
    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
end

for nr = 1:NR
    subplot(1,NR, nr)   
    ylim(YL)
end
title('highpass-filtered data')

%% get SNR


snr_trace = f_det./N_f;
snr_AP = F_AP./N_f; % only valid at detected spikes

figure
hold on
for nr = 1:NR
    if nnz(t_s(nr,:))
        scatter(nr*ones(1,nnz(t_s(nr,:))), snr_AP(nr,logical(t_s(nr,:))),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('SNR')


%% get dF/F




dff_trace = -(tr-F_0)./F_0;
dff_AP = F_AP./F_0; % only valid at detected spikes

figure
hold on
for nr = 1:NR
    if nnz(t_s(nr,:))
        scatter(nr*ones(1,nnz(t_s(nr,:))), dff_AP(nr,logical(t_s(nr,:))),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('DF/F')

%%
figure
YL = [0 0];

for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,snr_trace(nr,:),'k')
    scatter(tvec(t_s(nr,:)), snr_trace(nr,t_s(nr,:)),'r','filled')
    xlabel('time (s)')
    ylabel('SNR')
    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
end

for nr = 1:NR
    subplot(1,NR, nr)   
    ylim(YL)
end


%% 
figure
YL = [0 0];
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,f_det(nr,:),'k')
    scatter(tvec(t_s(nr,:)), f_det(nr,t_s(nr,:)),'r','filled')
    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
end

for nr = 1:NR
    subplot(1,NR, nr)   
    ylim(YL)
end

%% get d'
tau = 0.8;
d_p = tau*fs*(1-exp(-1/(tau*fs)))*F_AP./sqrt(F_0*fs);

figure
hold on
for nr = 1:NR
    if nnz(t_s(nr,:))
        scatter(nr*ones(1,nnz(t_s(nr,:))), d_p(nr,logical(t_s(nr,:))),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('d''')

%%

figure
YL = [0 0];
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,f_det(nr,:),'k')
    scatter(tvec(t_s(nr,:)), f_det(nr,t_s(nr,:)),'r','filled')
    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
    ylabel('detrended data')
end

for nr = 1:NR
    subplot(1,NR, nr)   
    ylim(YL)
end