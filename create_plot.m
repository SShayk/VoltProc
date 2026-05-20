clear

% datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\988_2_20260309_FOV2_800Hz_70p\analysis_2\analysis.mat';
% R_plot = [2 3 9 11];
% t_plot = [23.5 25.5];

% datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\989_1_20260309_FOV2_800Hz_100p_SLM\analysis_1\analysis.mat';
% R_plot = [1 2 7];
% t_plot = [10 12];

% datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\989_1_20260309_FOV2_800Hz_35p\analysis_1\analysis.mat';
% R_plot = [1 2 7];
% t_plot = [6 8];
 
% datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\988_1_20260309_FOV2_800Hz_70p\analysis_1\analysis.mat';
% R_plot = [3 7 9];
% t_plot = [10 12];

% datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\990_20260309_FOV1_800Hz_70p\analysis_1\analysis.mat';
% R_plot = 2;
% t_plot = [16 20];


datadir = '\\ad\eng\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\analysis\991_20260309_FOV1_800Hz_70p\analysis_1\analysis.mat';
R_plot = [1 3 4];
t_plot = [14 16];
%%
dat = load(datadir);

fs = dat.F_proc.parameters.fs;
dff_win = 2;

    rawdat = load(fullfile(dat.datadir,'signal.mat'));
    tr = rawdat.tr;
    t_s_cur = dat.F_proc.t_s;

% calculate df/f
for nr = R_plot
    % F0_cur = movmean(dat.F_proc.F_nospike(nr,:), (dff_win*fs),'omitnan');
    F_cur = tr(nr,:);
    vec_use = true(1,length(F_cur));
    for ns = find(t_s_cur(nr,:))
        vec_use(max(1, ns-2):min(length(F_cur), ns+2)) = false ;
    end
    F_cur(~dat.k_valid) = NaN;
    F_cur_nospikes = F_cur;
    F_cur_nospikes(~vec_use) = NaN;
    F0_cur = movmean(F_cur_nospikes, (dff_win*fs),'omitnan');

    DFF_cur(nr,:) = -(F_cur-F0_cur)./F0_cur;
end        


%% display

YL = [-0.08 0.15];

plot_stacked(dat.tvec_valid,DFF_cur(R_plot,dat.k_valid),[],'','-\DeltaF/F');

for nr = 1:length(R_plot)
    subplot(length(R_plot),1,nr)
    ax = gca;
    xlim(t_plot)
    if nr<length(R_plot)
        ax.XAxis.Visible='off';
    end
    title(sprintf('ROI %.0f', R_plot(nr)))
    ylim(YL)
end

%%
            
strparts = strsplit(dat.datadir,{'/','\'});
imfile = [strparts{end}(10:end),'.raw'];
reader = FrameReader(fullfile(strparts{1:end-1},imfile));

load(fullfile(dat.datadir,'mask.mat'))
load(fullfile(dat.datadir,'rois.mat'))
load(fullfile(dat.datadir,'translation.mat'))
    
im = double(reader.getFrames(100));
    
translation = gather(translation);
for k = 1:size(im,3)
    im_t(:,:,k) = circshift(im(:,:,k), translation(k,:));
end
im_av = mean(im_t,3);
        
cents = zeros(2,size(dat.dff_AP,1));
for nr = 1:size(dat.dff_AP,1)
    cents(:,nr) = gray_centroid(roimat(:,:,nr));
end
if strcmp(reader.dtype,'uint16')
    bg = 100;
    gain = 0.25;
else
    bg = 20;
    gain = 1.15;
end

figure
imagesc((im_av-bg)*gain)
axis image
colormap gray
axis off

for nr = R_plot
    text(cents(2,nr), cents(1,nr)-30,num2str(nr),'Color','y')
end
            