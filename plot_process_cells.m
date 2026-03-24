   addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage'))
addpath(genpath('\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage'))

addpath '/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/utilities'
addpath '\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\utilities'

clear
close all

highpass_movfilter = 0;
if highpass_movfilter
    disp('using moving mean for highpass calculation')
end
% TODO
%   make motion detection easier
%   save invalid time points
%   clear datadirs

% load data
%%% datadir = 'U:\eng_research_economo2\SFS\TICO2\20250910\851\800Hz\analysis';
% datadir = '/net/engnas/Research/eng_research_economo2/SFS/TICO2/20250930/Voltron_594/888/left_window/FOV1/800Hz/analysis';
% datadir =  '/net/engnas/Research/eng_research_economo2/SFS/TICO2/2post0251006/888/right_window/800Hz_100p/analysis';
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

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251126\898_4\FOV2\analysis_800Hz_100p';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251202\831_1\FOV1\analysis_800Hz_z40_100p';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251208\887\FOV2\analysis_800Hz_100p_SLM';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251208\892_2_animals\reg_headbar_left_window_no_snip\FOV2\analysis_800Hz_100p_SLM';

% datadir =  'U:\eng_research_economo2\SFS\TICO2\20251124\887\FOV5\analysis_800Hz_slit14_p80_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251210\892_2\FOV4\analysis_800Hz_100p_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251117\891_1\FOV2\analysis_acq_800Hz_100p_slit2_SLM';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251226\887\FOV4\analysis_800Hz_100p_SLM';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251226\892_leftwindow_regheadbar\FOV2\analysis_800Hz_100p_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251122\992\FOV1\analysis_800H_slit15_p100_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251126\898_4\FOV4\analysis_800Hz_100p';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251117\892_1\FOV5_replenished_water\analysis_acq_800Hz_100p_slit3_SLM';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251117\892_1\FOV5\analysis_acq_800Hz_100p_slit3_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20260109\878_2\FOV1\analysis_800Hz_100p_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20260109\887\FOV2\analysis_800Hz_70p_SLM';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20260109\887\FOV3\analysis_longacq_70p';
% datadir = 'U:\eng_research_economo2\SFS\TICO2\20251103\831_1\analysis';

% datadir = 'U:\eng_research_economo2\SFS\TICO2\20260117\887\FOV4\analysis_800Hz_100p_SLM';


% datadir = 'U:\eng_research_economo2\SFS\TICO2\20260202\878_4\FOV2\analysis_800Hz_80p_SLM';

datadir = pwd;
datadir = strrep(datadir,'\\ad\eng\research\','U:\');

strparts = strsplit(datadir,{'/','\'});
titlestr = [strparts{end-2},'/',strparts{end-3},'/',strparts{end-1},'/',strparts{end}(10:end)];
%%
load(fullfile(datadir,'signal.mat'))
load(fullfile(datadir,'rois.mat'))
nframes = size(tr,2);
fs = 800;
tvec = (1:nframes)*(1/fs);

%%%% 
% ROIs to view 
roi_use = 1:size(roimat,3);
% roi_use = [1 4 6];
roimat = roimat(:,:,roi_use);
tr = tr(roi_use,:);

% valid timepoints
k_valid = true(size(tvec));
k_valid(tvec<1) = 0;
k_valid(tvec>(tvec(end)-1)) = 0;
% k_valid(tvec>(29.5)) = 0;
k_valid(tvec<4.3) = 0;
k_valid(tvec>8.9 & tvec <13.4) = 0;
% k_valid(tvec>12 & tvec <13) = 0;
% k_valid(tvec>15.5 & tvec <16.5) = 0;
% k_valid(tvec>19.5 & tvec <21.3) = 0;
% k_valid(tvec>24.5) = 0;

%%%

tvec_valid = tvec(k_valid);
NR = size(roimat,3);


%% get F values 
F_proc = process_voltage(tr,'highpasstype',logical(highpass_movfilter));
[F_proc.F_AP, F_proc.params_AP] = calc_APs(F_proc.F_det);

%% get spike locations
[F_proc.t_s, F_proc.parameters_kspikes] = get_spike_locations(F_proc.F_det, F_proc.F_AP, F_proc.N_f, F_proc.dF_ur, F_proc.dF_dr); 
    
%% get Vm and other baseline calculations
  [F_proc.F_sub, F_proc.F_nospike, F_proc.F_0, F_proc.params_baselines] = get_subthreshold_trace(tr, F_proc.t_s);

%% plot all traces (use to find motion timepoints, etc)
figure('Name','raw F')
plot(tvec,-tr), xlabel('time (s)'), ylabel('-F')
whitefig

title(titlestr)
disp('check if timepoints need to be removed')
pause() % pause in case valid timepoints need to be adjusted

% %% show bleaching
% figure('Name','trend')
% plot(tvec,scale2max(lowpass(tr.',1,fs),2)), xlabel('time (s)'), ylabel('-F')
% whitefig
%% plot traces

plot_stacked(tvec_valid,-tr(:,k_valid),[],['negative and detrended F      ',titlestr],'-F');
for nr = 1:NR
    subplot(NR,1, nr)
     yyaxis right, plot(tvec_valid,F_proc.F_det(nr,k_valid),'b')
    ax = gca;
    ax.YAxis(1).Color = [0 0 0];

    ax.YAxis(2).Color = [0 0 1];

    if nr == 1
        legend('negative trace','highpass-filtered')
    end
end

%% plot detrended only F

plot_stacked(tvec_valid,F_proc.F_det(:,k_valid),F_proc.t_s(:,k_valid),['detrended F only      ',titlestr],'-F',0);
plot_stacked(tvec_valid,F_proc.F_det(:,k_valid),[],['detrended F only (no spikes)      ',titlestr],'-F',0);

%{
%% plot only bleaching trends
figure('Name','trend only'), hold on
for nr = 1:NR
    plot(tvec_valid,F_proc.F_0(nr,k_valid),'DisplayName',['ROI',num2str(nr)])
end
ylabel('F0'), xlabel('time (s)'), whitefig
title(titlestr)
%% plot only Vm
plot_stacked(tvec_valid,F_proc.F_sub(:,k_valid),[],['Vm      ',titlestr],'F0');
%}

%% plot filtered data with spikes

H_hp=plot_stacked(tvec_valid,F_proc.F_hp(:,k_valid),F_proc.t_s(:,k_valid),['highpass-filtered data      ',titlestr],'-F');
for nr = 1:NR
    subplot(NR,1, nr)   
    hold on
    plot(tvec_valid,F_proc.F_hp_mean(nr,k_valid),'r')
    if nr ==1
        legend('highpass filtered (detrended and Vm removed)','moving average', 'spikes')
    end
end
standardize_ylims(H_hp, [NR 1], [0 0]);


%% get SNR

snr_trace = F_proc.F_det./F_proc.N_f;
snr_AP = F_proc.F_AP./F_proc.N_f; % only valid at detected spikes

scatter_AP(F_proc.t_s(:,k_valid),snr_AP(:,k_valid),['SNR (AP)      ',titlestr],'SNR');

H_snr_trace = plot_stacked(tvec_valid,snr_trace(:,k_valid),F_proc.t_s(:,k_valid),['SNR(traces)      ',titlestr],'SNR');
standardize_ylims(H_snr_trace, [NR 1], [0 0]);


%% get dF/F

dff_trace = -(tr-F_proc.F_0)./F_proc.F_0;
dff_AP = F_proc.F_AP./F_proc.F_0; % only valid at detected spikes

scatter_AP(F_proc.t_s(:,k_valid),dff_AP(:,k_valid),['DFF (AP)      ',titlestr],'\DeltaF/F');

H_dff_trace = plot_stacked(tvec_valid,dff_trace(:,k_valid),F_proc.t_s(:,k_valid),['DFF(traces)      ',titlestr],'-\DeltaF/F');
standardize_ylims(H_dff_trace, [NR 1], [0 0]);

%{
%% get d'
gain = 0.25; % camera gain. to calculate photon count
tau = 0.8*1e-3; % decay time [s] (assumed 0.8 ms for Voltron2 and ReVolt, as in TICO paper)


d_p = zeros(size(F_proc.t_s));
for nr = 1:NR
    NP = nnz(roimat(:,:,nr)); % calculate total photons
    d_p(nr,:) = tau*fs*(1-exp(-1/(tau*fs)))*F_proc.F_AP(nr,:)*gain*NP./sqrt(F_proc.F_0(nr,:)*gain*NP);
end
% d_p = sqrt(((F_proc.F_AP.^2)./(F_proc.F_0*fs)));

scatter_AP(F_proc.t_s(:,k_valid),d_p(:,k_valid),['d prime      ',titlestr],'d');
%}
%%
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


%% plot superimposed snippets
YL_F = [-1 1];
YL_DFF = [-0.01 0.01];
YL_SNR = [0 8];
figure('Name',['snippets      ',titlestr])
k_snip = -16:16;
t_snip = k_snip*(1/fs);
for nr = 1:NR
    subplot(3,NR,nr), hold on
    for nk =  find(F_proc.t_s(nr,:)&k_valid)
        plot(t_snip, F_proc.F_hp(nr,nk + k_snip))
        YL_F(1) = min([YL_F(1), min(ylim)]);
        YL_F(2) = max([YL_F(2), max(ylim)]);
    end
    title(['ROI ', num2str(roi_use(nr))])
    if nr ==1, ylabel('-F'), end
    subplot(3,NR,NR+nr), hold on
    for nk =  find(F_proc.t_s(nr,:)&k_valid)
        plot(t_snip, dff_trace(nr,nk + k_snip))
        YL_DFF(1) = min([YL_DFF(1), min(ylim)]);
        YL_DFF(2) = max([YL_DFF(2), max(ylim)]);
    end
    if nr ==1, ylabel('-\DeltaF/F'), end
    xlabel('time (s)')

    subplot(3,NR,2*NR+nr), hold on
    for nk =  find(F_proc.t_s(nr,:)&k_valid)
        plot(t_snip, snr_trace(nr,nk + k_snip))
        YL_SNR(1) = min([YL_SNR(1), min(ylim)]);
        YL_SNR(2) = max([YL_SNR(2), max(ylim)]);
    end
    if nr ==1, ylabel('SNR'), end
    xlabel('time (s)')
end
whitefig
for nr = 1:NR
    subplot(3,NR,nr), ylim(YL_F)
     subplot(3,NR,NR+nr), ylim(YL_DFF)
     subplot(3,NR,2*NR+nr), ylim(YL_SNR)
end
%% 
Nspikes = zeros(1,nr);
for nr = 1:NR
Nspikes(nr) = nnz(F_proc.t_s(nr,:)&k_valid);
end

%% show grayscale image with ROIs labeled
imfile = [strparts{end}(10:end),'.raw'];
reader = FrameReader(fullfile(strparts{1:end-1},imfile));

load(fullfile(datadir,'mask.mat'))
load(fullfile(datadir,'rois.mat'))
load(fullfile(datadir,'translation.mat'))

im = double(reader.getFrames(100));

translation = gather(translation);
for k = 1:size(im,3)
        im_t(:,:,k) = circshift(im(:,:,k), translation(k,:));
end
im_av = mean(im_t,3);

cents = zeros(2,NR);
for nr = 1:NR
    cents(:,nr) = gray_centroid(roimat(:,:,roi_use(nr)));
end


%%
figure('Name','ROI display')
imagesc(im_av-100), axis image, colormap gray
title(titlestr)

for nr = 1:NR
    text(cents(2,nr), cents(1,nr)-30,num2str(roi_use(nr)),'Color','y')
end
whitefig


%% show photons per cell per frame

phot_im = (im_av - 100)*0.25;

figure('Name',['photons per cell per frame       ',titlestr])
subplot(1,2,1)
imagesc(phot_im), colorbar, title('photon count'), axis image, axis off
subplot(1,2,2)
imagesc(phot_im.*sum(roimat,3)), axis image, axis off
colorbar
title('photons per cell')
hold on
cell_phot_singleframe = zeros(1,size(roimat,3));
pixcount = zeros(1,size(roimat,3));
for kr = 1:size(roimat,3)
    c = gray_centroid(roimat(:,:,kr));
    cell_phot_singleframe (kr) = sum(phot_im(find(roimat(:,:,kr))));
    pixcount(kr) = nnz(roimat(:,:,kr));
    text(round(c(2))+15,round(c(1)),sprintf('%d e-/frame', cell_phot_singleframe (kr)),'Color','c')
    text(round(c(2))+15,round(c(1))-15,sprintf('%d pix', pixcount(kr)),'Color','m')
end
set(gca,'YDir','reverse')
whitefig
%

%%
F_proc.highpass_movfilter = highpass_movfilter;

nfile = 1;
while exist(fullfile(datadir,['analysis_',num2str(nfile)]),'dir')
    nfile = nfile +1;
end
folderstr = ['analysis_',num2str(nfile)];

mkdir(fullfile(datadir,folderstr))

save(fullfile(datadir,folderstr,'analysis.mat'),'F_proc','roi_use','datadir','tvec_valid','dff_AP','snr_AP','k_valid','cell_phot_singleframe','pixcount')

figHandles = findall(0, 'Type', 'figure');
for iFig = 1:length(figHandles)
    currentFig = figHandles(iFig);
    
    % Get figure number to use in filename
    figName = strrep(num2str(get(currentFig, 'Name')),'/','_');
    

    % Save as a .fig file to be able to modify it later in MATLAB
    savefig(currentFig, fullfile(datadir,folderstr,[figName '.fig']));
end
