   addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage'))
addpath(genpath('\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage'))

addpath '/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/utilities'

% TODO
%   make motion detection easier
%   save invalid time points
%   clear datadirs

% load data
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20250910/851/800Hz/analysis';
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20250930/Voltron_594/888/left_window/FOV1/800Hz/analysis';
% datadir =  '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20251006/888/right_window/800Hz_100p/analysis';
% datadir = '/ad/eng/research/eng_research_economo2/SFS/TICO2/20250802/871/FOV4/800Hz_SLM/analysis';

% datadir = '/ad/eng/research/eng_research_economo2/SFS/TICO2/20251019/948/fov1/800Hz_100p_SLM/analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov1\800Hz_100p_SLM\analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov2\z120_100p_800Hz\analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251019\948\fov2\z80_100p_800Hz\analysis';
 
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251103\948\analysis_800Hz_60p_SLM';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251106\948\FOV1\analysis';

% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO1/20250829/948/800Hz/20250829-151115/analysis';
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO1/20250829/850/FOV1/800Hz/20250829-152857/analysis';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251106\831_2\FOV3_potential_reVolt\analysis_narrowed_slit';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251106\831_2\FOV3_potential_reVolt\analysis_slit_3';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251106\831_2\FOV1\analysis';

datadir = 'U:\eng_research_economo2\SFS\TICO2\20251117\892_1\FOV5\analysis_acq_800Hz_100p_slit2_SLM';

load(fullfile(datadir,'signal.mat'))
load(fullfile(datadir,'rois.mat'))
nframes = size(tr,2);
tvec = (1:nframes)*(1/fs);

%%%% 
% ROIs to view 
roi_use = 1:size(roimat,3);
% roi_use = [1 2 3 5 7 9];
roimat = roimat(:,:,roi_use);
tr = tr(roi_use,:);

% valid timepoints
k_valid = true(size(tvec));
k_valid(tvec<0.8) = 0;
k_valid(tvec>29) = 0;
% 
% k_valid(tvec>52&tvec<53) = 0;
% k_valid(tvec>1&tvec<2.5) = 0;
% k_valid(tvec>41.1&tvec<41.4) = 0;
% k_valid(tvec>48&tvec<48.5) = 0;
% k_valid(tvec>13.9&tvec<14) = 0;
% k_valid(tvec>17.6&tvec<18) = 0;

%%%

tvec_valid = tvec(k_valid);
NR = size(roimat,3);


%% get F values 
F_proc = process_voltage(tr);
[F_proc.F_AP, F_proc.params_AP] = calc_APs(F_proc.F_det);

%% get spike locations
[F_proc.t_s, F_proc.parameters_kspikes] = get_spike_locations(F_proc.F_det, F_proc.F_AP, F_proc.N_f, F_proc.dF_ur, F_proc.dF_dr); 
    
%% get Vm and other baseline calculations
[F_proc.F_sub, F_proc.F_nospike, F_proc.F_0, F_proc.params_baselines] = get_subthreshold_trace(tr, F_proc.t_s);

%% plot all traces (use to find motion timepoints, etc)
figure('Name','raw F')
plot(tvec,-tr)
xlabel('time (s)') 
ylabel('-F')
whitefig
%% plot traces

figure('Name','negative and detrended F')
for nr = 1:NR
    subplot(NR,1, nr)
    hold on
    plot(tvec_valid,-tr(nr,k_valid),'k')
            ylabel('-F')
    yyaxis right, plot(tvec_valid,F_proc.F_det(nr,k_valid),'b')
    ax = gca;
    ax.YAxis(1).Color = [0 0 0];

    ax.YAxis(2).Color = [0 0 1];
    box off

    if nr~= NR, set(gca().XAxis,'Visible', 'off'); end
    if nr == 1
        legend('negative trace','highpass-filtered')
    end
end
xlabel('time (s)')
whitefig
%% plot detrended F

plot_stacked(tvec_valid,F_proc.F_det(:,k_valid),F_proc.t_s(:,k_valid),...
F_proc.F_det(:,k_valid),'detrended F only','-F')

%% plot only bleaching trend
figure('Name','trend only'), hold on
for nr = 1:NR
    plot(tvec_valid,F_proc.F_0(nr,k_valid),'DisplayName',['ROI',num2str(nr)])
end
ylabel('F0'), xlabel('time (s)'), whitefig

%% plot only Vm
plot_stacked(tvec_valid,F_proc.F_sub(:,k_valid),[],[],'Vm','F0')


%% plot filtered data with spikes
figure('Name','highpass-filtered data')
YL = [0 0];
for nr = 1:NR
    subplot(NR,1, nr)   
    hold on
    plot(tvec_valid,F_proc.F_hp(nr,k_valid),'k')
    plot(tvec_valid,F_proc.F_hp_mean(nr,k_valid),'r')
    scatter(tvec_valid(F_proc.t_s(nr,k_valid)), F_proc.F_hp(nr,F_proc.t_s(nr,:)&k_valid),'r','filled')
    xlim([1 tvec_valid(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
         ylabel('-F')
 if nr~= NR, set(gca().XAxis,'Visible', 'off'); end

end
     xlabel('time (s)')

     

for nr = 1:NR
    subplot(NR,1, nr)   
    ylim(YL)
    if nr ==1
        legend('highpass filtered (detrended and Vm removed)','moving average', 'spikes')
    end
end
whitefig


%% get SNR


snr_trace = F_proc.F_det./F_proc.N_f;
snr_AP = F_proc.F_AP./F_proc.N_f; % only valid at detected spikes

figure('Name','SNR (AP)')
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,k_valid))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,k_valid))), snr_AP(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
    end
end
xlabel('roi')
xticks(1:NR)
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('SNR')
whitefig


figure('Name','SNR (traces)')
YL = [0 0];
hold on
for nr = 1:NR
    subplot(NR,1, nr)   
    hold on
    plot(tvec_valid,snr_trace(nr,k_valid),'k')

     if nnz(F_proc.t_s(nr,:))
        scatter(tvec_valid(F_proc.t_s(nr,k_valid)), snr_trace(nr,logical(F_proc.t_s(nr,:)&k_valid)),15,'r','filled')
     end
    if nr~= NR, set(gca().XAxis,'Visible', 'off'); end
    xlim([1 tvec_valid(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
    ylabel('SNR')
end
    xlabel('time (s)')
for nr = 1:NR
    subplot(NR,1, nr)   
    ylim(YL)
end
whitefig

%% get dF/F


dff_trace = -(tr-F_proc.F_0)./F_proc.F_0;
dff_AP = F_proc.F_AP./F_proc.F_0; % only valid at detected spikes

figure('Name','DFF (AP)')
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,:))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,k_valid))), dff_AP(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
    end
end
xlim([0.5, NR + 0.5])
xticks(1:NR)
ylim([0 max(ylim)])
title('DF/F')
whitefig


figure('Name','DFF (traces)')
YL = [0 0];
hold on
for nr = 1:NR
    subplot(NR,1, nr)   
    hold on
    plot(tvec_valid,dff_trace(nr,k_valid),'k')

     if nnz(F_proc.t_s(nr,:))
        scatter(tvec_valid(F_proc.t_s(nr,k_valid)), dff_trace(nr,logical(F_proc.t_s(nr,:)&k_valid)),10,'r','filled')
     end
 if nr~= NR, set(gca().XAxis,'Visible', 'off'); end

    xlim([1 tvec_valid(end)-1])
    if min(ylim)<YL(1)
        YL(1) = min(ylim);
    end
    if max(ylim)>YL(2)
        YL(2) = max(ylim);
    end
    ylabel('-\DeltaF/F')

end
    xlabel('time (s)')
for nr = 1:NR
    subplot(NR,1, nr)   
    ylim(YL)
end
whitefig


%% get d'
gain = 0.25; % camera gain. to calculate photon count
tau = 0.8*1e-3; % decay time [s] (assumed 0.8 ms for Voltron2 and ReVolt, as in TICO paper)


d_p = zeros(size(F_proc.t_s));
for nr = 1:NR
    NP = nnz(roimat(:,:,nr)); % calculate total photons
    d_p(nr,:) = tau*fs*(1-exp(-1/(tau*fs)))*F_proc.F_AP(nr,:)*gain*NP./sqrt(F_proc.F_0(nr,:)*gain*NP);
end
% d_p = sqrt(((F_proc.F_AP.^2)./(F_proc.F_0*fs)));
figure('Name','d prime')
hold on
for nr = 1:NR
    if nnz(F_proc.t_s(nr,:))
        scatter(nr*ones(1,nnz(F_proc.t_s(nr,k_valid))), d_p(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
    end
end
xticks(1:NR)
xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('d''')
whitefig

% %%
% figure
% subplot(4,1,1), hold on
% for nr = 1:NR
%     scatter(tvec(logical(F_proc.t_s(nr,:)&k_valid)), dff_AP(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
% end
% ylabel('\DeltaF/F')
% 
% subplot(4,1,2), hold on
% for nr = 1:NR
%     scatter(tvec(logical(F_proc.t_s(nr,:)&k_valid)), d_p(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
% end
% ylabel('d''')
% 
% subplot(4,1,3), hold on
% for nr = 1:NR
%     scatter(tvec(logical(F_proc.t_s(nr,:)&k_valid)), F_proc.F_0(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
% end
% ylabel('F_{0}')
% 
% subplot(4,1,4), hold on
% for nr = 1:NR
%     scatter(tvec(logical(F_proc.t_s(nr,:)&k_valid)), F_proc.F_AP(nr,logical(F_proc.t_s(nr,:)&k_valid)),30,'filled')
% end
% ylabel('F_{AP}')
% xlabel('time (s)')

% whitefig


 %% for flipping through individual spikes
% for nr = 1:NR
%     subplot(NR,1,nr)
%     for nk =  find(F_proc.t_s(nr,:)&k_valid)
%         xlim(tvec(nk)+[-.04 .04])
%         pause
%     end
% end


%% plot snippets on top of each other
YL_F = [-1 1];
YL_DFF = [-0.01 0.01];
figure('Name','snippets')
k_snip = -16:16;
t_snip = k_snip*(1/fs);
for nr = 1:NR
    subplot(2,NR,nr), hold on
    for nk =  find(F_proc.t_s(nr,:)&k_valid)
        plot(t_snip, F_proc.F_hp(nr,nk + k_snip))
        YL_F(1) = min([YL_F(1), min(ylim)]);
        YL_F(2) = max([YL_F(2), max(ylim)]);
    end
    title(['ROI ', num2str(nr)])
    if nr ==1, ylabel('-F'), end
    subplot(2,NR,NR+nr), hold on
    for nk =  find(F_proc.t_s(nr,:)&k_valid)
        plot(t_snip, dff_trace(nr,nk + k_snip))
        YL_DFF(1) = min([YL_DFF(1), min(ylim)]);
        YL_DFF(2) = max([YL_DFF(2), max(ylim)]);
    end
    if nr ==1, ylabel('-\DeltaF/F'), end
    xlabel('time (s)')
end
whitefig
for nr = 1:NR
    subplot(2,NR,nr), ylim(YL_F)
     subplot(2,NR,NR+nr), ylim(YL_DFF)
end
%% 
Nspikes = zeros(1,nr);
for nr = 1:NR
Nspikes(nr) = nnz(F_proc.t_s(nr,:)&k_valid);
end