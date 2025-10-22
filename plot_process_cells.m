addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage'))
% load data
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20250910/851/800Hz/analysis';
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20250930/Voltron_594/888/left_window/FOV1/800Hz/analysis';
% datadir =  '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20251006/888/right_window/800Hz_100p/analysis';
% datadir = '/ad/eng/research/eng_research_economo2/SFS/TICO2/20250802/871/FOV4/800Hz_SLM/analysis';

% datadir = '/ad/eng/research/eng_research_economo2/SFS/TICO2/20251019/948/fov1/800Hz_100p_SLM/analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov1\800Hz_100p_SLM\analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov2\z120_100p_800Hz\analysis';
datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov2\z80_100p_800Hz\analysis';
load(fullfile(datadir,'signal.mat'))
load(fullfile(datadir,'rois.mat'))

%%%
roimat = roimat(:,:,1);
%%%

NR = size(roimat,3);
nframes = size(tr,2);
tvec = (1:nframes)*(1/fs);

%%
F_proc = process_voltage(tr);
[F_proc.F_AP, F_proc.params_AP] = calc_APs(F_proc.F_det);

%% get spike locations
[F_proc.t_s, F_proc.parameters_kspikes] = get_spike_locations(F_proc.F_det, F_proc.F_AP, F_proc.N_f, F_proc.dF_ur, F_proc.dF_dr); 
    
%% get Vm and other baseline calculations
[F_proc.F_sub, F_proc.F_nospike, F_proc.F_0, F_proc.params_baselines] = get_subthreshold_trace(tr, F_proc.t_s);




%% plot traces

figure('Name','negative and detrended F')
for nr = 1:NR
    subplot(1,NR, nr)
    hold on
    plot(tvec,-tr(nr,:),'k')
    yyaxis right, plot(tvec,F_proc.F_det(nr,:),'b')
    xlabel('time (s)')
    if nr == 1
        legend('negative trace','highpass-filtered')
    end
end
%%
figure('Name','detrended F only')
for nr = 1:NR
    subplot(1,NR, nr)
    hold on
    plot(tvec,F_proc.F_det(nr,:),'k')
     if nnz(F_proc.t_s(nr,:))
        scatter(tvec(F_proc.t_s(nr,:)), F_proc.F_det(nr,logical(F_proc.t_s(nr,:))),30,'r','filled')
     end
     ylabel('F')
end


%%
figure('Name','highpass-filtered data')
YL = [0 0];
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,F_proc.F_hp(nr,:),'k')
    plot(tvec,F_proc.F_hp_mean(nr,:),'r')
    scatter(tvec(F_proc.t_s(nr,:)), F_proc.F_hp(nr,F_proc.t_s(nr,:)),'r','filled')
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
    if nr ==1
        legend('highpass filtered (detrended and Vm removed)','moving average', 'spikes')
    end
end


%% get SNR


snr_trace = F_proc.F_det./F_proc.N_f;
snr_AP = F_proc.F_AP./F_proc.N_f; % only valid at detected spikes

figure('Name','SNR (AP)')
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,:))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,:))), snr_AP(nr,logical(F_proc.t_s(nr,:))),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('SNR')


figure('Name','SNR (traces)')
YL = [0 0];
hold on
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,snr_trace(nr,:),'k')

     if nnz(F_proc.t_s(nr,:))
        scatter(tvec(F_proc.t_s(nr,:)), snr_trace(nr,logical(F_proc.t_s(nr,:))),30,'r','filled')
     end

    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
    ylabel('SNR')
    xlabel('time (s)')
end
for nr = 1:NR
    subplot(1,NR, nr)   
    ylim(YL)
end

%% get dF/F


dff_trace = -(tr-F_proc.F_0)./F_proc.F_0;
dff_AP = F_proc.F_AP./F_proc.F_0; % only valid at detected spikes

figure('Name','DFF (AP)')
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,:))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,:))), dff_AP(nr,logical(F_proc.t_s(nr,:))),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('DF/F')


figure('Name','DFF (traces)')
YL = [0 0];
hold on
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,dff_trace(nr,:),'k')

     if nnz(F_proc.t_s(nr,:))
        scatter(tvec(F_proc.t_s(nr,:)), dff_trace(nr,logical(F_proc.t_s(nr,:))),30,'r','filled')
     end

    xlim([1 tvec(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
    ylabel('\DeltaF/F')
    xlabel('time (s)')
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
    plot(tvec,snr_trace(nr,:),'k')
    scatter(tvec(F_proc.t_s(nr,:)), snr_trace(nr,F_proc.t_s(nr,:)),'r','filled')
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
    plot(tvec,F_proc.F_det(nr,:),'k')
    scatter(tvec(F_proc.t_s(nr,:)), F_proc.F_det(nr,F_proc.t_s(nr,:)),'r','filled')
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
d_p = tau*fs*(1-exp(-1/(tau*fs)))*F_proc.F_AP./sqrt(F_proc.F_0*fs);

figure
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,:))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,:))), d_p(nr,logical(F_proc.t_s(nr,:))),30,'filled')
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
    plot(tvec,F_proc.F_det(nr,:),'k')
    scatter(tvec(F_proc.t_s(nr,:)), F_proc.F_det(nr,F_proc.t_s(nr,:)),'r','filled')
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