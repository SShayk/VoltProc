
slit_widths = {'10','16','24','open_400','24_SLM','open_400_SLM'}; % 20250713
% slit_widths = {'5','10','16','24','open_400','16_SLM'}; % 20250712

NS = length(slit_widths);

slit_pix = [10 16 24 400 24 400];% 20250713
% slit_pix = [5 10 16 24 400 16]; % 20250712
slit_um = slit_pix*0.83;
tr_all = cell(1,NS);
rois_all = cell(1,NS);
fs = 800;


for ns = 1:NS
    datadir{ns} = sprintf('/ad/eng/research/eng_research_economo2/SFS/TICO2/20250713/730_left/slit_%s/analysis',slit_widths{ns});
    load(fullfile(datadir{ns},'signal.mat'))
    load(fullfile(datadir{ns},'rois.mat'))
    tr_all{ns} = tr;
    rois_all{ns} = roimat;
    clearvars tr roimat
end


%%
win_detect = -round(fs*.003):-1;
    nos_window = -round(.001*fs):round(.002*fs);

for ns = 1:NS
f_det{ns} = zeros(size(tr_all{ns}));
f_hp{ns} = zeros(size(tr_all{ns}));
f_hp_mean{ns} = zeros(size(tr_all{ns}));
f_dr{ns} = zeros(size(tr_all{ns}));
f_ur{ns} = zeros(size(tr_all{ns}));
N_f{ns} = zeros(size(tr_all{ns}));
F_AP{ns} = zeros(size(tr_all{ns}));

roimat = rois_all{ns};
NR = size(roimat,3);

for nr = 1:NR
    f_det{ns}(nr,:) = highpass(squeeze(-tr_all{ns}(nr,:)),1,fs); % detrend
    f_hp{ns}(nr,:) = highpass(squeeze(f_det{ns}(nr,:)),50,fs); % remove subthreshold activity
    f_hp_mean{ns}(nr,:)  = movmean(f_hp{ns}(nr,:).',2*round(0.2*fs));
    f_dr{ns}(nr,:)  = min([f_hp{ns}(nr,:); f_hp_mean{ns}(nr,:)]);
    f_ur{ns}(nr,:)  = max([f_hp{ns}(nr,:); f_hp_mean{ns}(nr,:)]);
    N_f{ns}(nr,:) = 2*movstd(f_dr{ns}(nr,:).',2*round(1*fs));
    F_0{ns}(nr,:) = lowpass(tr_all{ns}(nr,:),1,fs);


    for nt = (-win_detect(1)+1):length(f_det{ns})
        F_AP{ns}(nr,nt) = max(f_det{ns}(nr,nt) - f_det{ns}(nr,nt + win_detect));
    end



end
    dF_ur{ns} = [zeros(NR,1), diff(f_ur{ns}.').'];
    dF_dr{ns} = [zeros(NR,1), diff(f_dr{ns}.').'];

    %% get spike locations
    t_s{ns} = zeros(size(tr_all{ns}));

    C1 = dF_ur{ns} > movmean(dF_ur{ns},2*(1*fs)) + 3*movstd(dF_dr{ns},2*(1*fs));
    C2 = f_det{ns} > movmean(f_det{ns},2*(0.1*fs),2) + 3*N_f{ns};
    C3 = F_AP{ns} > 4*N_f{ns};
    t_s{ns} = C1 & C2 & C3;


        F_nospike{ns} = tr_all{ns};
        for nr = 1:NR
            cur_mm = movmean(tr_all{ns}(nr,:),round(.005*fs));
            for ks = find(t_s{ns}(nr,:))
                F_nospike{ns}(nr,ks+nos_window) = cur_mm(ks+nos_window);
            end
                F_sub{ns}(nr,:) = bandpass(F_nospike{ns}(nr,:),[1 50], fs);
        end




    snr_trace{ns} = f_det{ns}./N_f{ns};
    snr_AP{ns} = F_AP{ns}./N_f{ns};

    dff_trace{ns} = -(tr_all{ns}-F_0{ns})./F_0{ns};
    dff_AP{ns} = F_AP{ns}./F_0{ns}; % only valid at detected spikes



end




%% show SNR

compare_ns = 1:4;% %[3 5] [4 6]
figure
hold on
for ns = 1:length(compare_ns)
    k_ns = compare_ns(ns);
    if nnz(t_s{k_ns}(:))
        scatter(ns*ones(1,nnz(t_s{k_ns}(:))), snr_AP{k_ns}(logical(t_s{k_ns}(:))),30,'k','filled')
    end
end
title('SNR')

% xlim([0.5, NR + 0.5])
% ylim([0 max(ylim)])

xticks(1:length(compare_ns))

for nref = 1:length(compare_ns)
    tickstr{nref} = sprintf('%.1f um (%s)',slit_um(compare_ns(nref)), strrep(slit_widths{compare_ns(nref)},'_',' '));
end
xticklabels(tickstr)
xlabel('slit width')
xlim([min(xlim)-0.5,max(xlim)+0.5])

ylabel('SNR')


%% get dF/F
compare_ns = 1:4;%1:4; % [3 5] [4 6]

figure
hold on
for ns = 1:length(compare_ns)
    k_ns = compare_ns(ns);
    if nnz(t_s{k_ns})
        scatter(ns*ones(1,nnz(t_s{k_ns})), dff_AP{k_ns}(logical(t_s{k_ns}(:))),30,'filled')
    end
end
% xlim([0.5, NR + 0.5])
ylim([0 max(ylim)])
title('DF/F')

xticks(1:length(compare_ns))

for nref = 1:length(compare_ns)
    tickstr{nref} = sprintf('%.1f um (%s)',slit_um(compare_ns(nref)), strrep(slit_widths{compare_ns(nref)},'_',' '));
end
xticklabels(tickstr)

xlim([min(xlim)-0.5,max(xlim)+0.5])

ylabel('\DeltaF/F')
%%
for ns = 1:NS
figure('Name',slit_widths{ns})
YL = [0 0];
tvec = (1:size(snr_trace{ns},2))*(1/fs);
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,snr_trace{ns}(nr,:),'k')
    scatter(tvec(t_s{ns}(nr,:)), snr_AP{ns}(nr,t_s{ns}(nr,:)),'r','filled')
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
end


%% 
figure
YL = [0 0];
for nr = 1:NR
    subplot(1,NR, nr)   
    hold on
    plot(tvec,f_det{ns}(nr,:),'k')
    scatter(tvec(t_s{ns}(nr,:)), f_det{ns}(nr,t_s{ns}(nr,:)),'r','filled')
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