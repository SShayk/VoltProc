function [] = MC_and_extract(filedir, filename)

% todo: make error/progress log file
%   make usable for same file/different ROI files

savedir = fullfile(filedir,['analysis_',filename]);
if ~exist(savedir, 'dir'), mkdir(savedir), end

all_files = fullfile(filedir,[filename,'.raw']);

all_files = [all_files,sort({dir(fullfile(filedir,[filename,'_0*','.raw'])).name})];


reader = FrameReader(fullfile(filedir,[filename,'.raw']));
im_ref = mean(double(reader.getFrames(100)),3);
 
load(fullfile(savedir,'rois.mat'))
load(fullfile(savedir,'mask.mat'))

bg = 100;
NR = size(roimat,3);
tr = [];
translation =[];

tic
for nfile = 1:length(all_files)
    
    reader = FrameReader(fullfile(filedir,all_files{nfile}));

    im = double(reader.getFrames(reader.maxFrames));
    % motion correct
    translation_cur = masked_phase_cross_correlation(im, im_ref,maskmat);
    im_t = zeros(size(im));
    for k = 1:size(im,3)
        im_t(:,:,k) = circshift(im(:,:,k), translation_cur(k,:));
    end
        toc


tr_cur = zeros(NR, size(im,3));
for nf = 1:size(tr_cur,2)
    cur_im = im_t(:,:,nf);
    for nr = 1:NR
        tr_cur(nr,nf) = mean(cur_im(logical(roimat(:,:,nr))));
    end
end
    tr = [tr, tr_cur];
    translation = cat(1, translation, translation_cur);
    clearvars tr_cur translation_cur
end
tr = tr- bg;



%% save

if ~exist(fullfile(savedir,'translation.mat'),'file') && exist('translation','var')
    save(fullfile(savedir,'translation.mat'),'translation')
    disp('saved translation')
else
    disp('did not save translation')
end

if ~exist(fullfile(savedir,'signal.mat'),'file')
    save(fullfile(savedir,'signal.mat'),'tr')
    disp('saved signal')
else
    disp('did not save signal')
end



end