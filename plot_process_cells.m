% load data
datadir = '/ad/eng/research/eng_research_economo2/SFS/TICO2/20250713/730_left/slit_24/analysis';
load(fullfile(datadir,'signal.mat'))
load(fullfile(datadir,'rois.mat'))

NR = size(roimat,3);
nframes = size(tr,2);
tvec = (1:nframes)*(1/fs);
%%

f_det = zeros(size(tr));
f_hp = zeros(size(tr));
f_hp_mean = zeros(size(tr));
f_dr = zeros(size(tr));
f_ur = zeros(size(tr));
N_f = zeros(size(tr));
F_AP = zeros(size(tr));
for nr = 1:NR
    f_det(nr,:) = highpass(squeeze(-tr(nr,:)),1,fs); % detrend
    f_hp(nr,:) = highpass(squeeze(f_det(nr,:)),50,fs); % remove subthreshold activity
    f_hp_mean(nr,:)  = movmean(f_hp(nr,:).',2*round(0.2*fs));
    f_dr(nr,:)  = min([f_hp(nr,:); f_hp_mean(nr,:)]);
    f_ur(nr,:)  = max([f_hp(nr,:); f_hp_mean(nr,:)]);
    N_f(nr,:) = 2*movstd(f_dr(nr,:).',2*round(1*fs));
    
end
%%
win_detect = -round(fs*.003):-1;
for nr = 1:NR
    for nt = (-win_detect(1)+1):length(f_det)
        F_AP(nr,nt) = max(f_det(nr,nt) - f_det(nr,nt + win_detect));
    end
end
dF_ur = [zeros(NR,1), diff(f_ur.').'];
dF_dr = [zeros(NR,1), diff(f_dr.').'];

%% get spike locations
    t_s = zeros(size(tr));

    C1 = dF_ur > movmean(dF_ur,2*(1*fs)) + 3*movstd(dF_dr,2*(1*fs));
    C2 = f_det > movmean(f_det,2*(0.1*fs),2) + 3*N_f;
    C3 = F_AP > 4*N_f;
    t_s = C1 & C2 & C3;


    
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