clear, close all

addpath(genpath('/ad/eng/users/s/s/sshayk/My Documents/MATLAB/SpikeTriggeredPlots'))
addpath(genpath('\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\SpikeTriggeredPlots'))

impath = '\\engnas.bu.edu\research\eng_research_economo2\SFS\TICO2\20251122\992\FOV1\800H_slit15_p100_SLM.raw';


[filedir, filename, filetype] = fileparts(impath);
savedir = fullfile(filedir,['analysis_',filename]);
if ~exist(savedir, 'dir'), mkdir(savedir), end

all_files = sort({dir(fullfile(filedir,[filename,'*',filetype])).name});

fs = 800;
bg = 100;


%% 
reader = FrameReader(impath);
im_ref = mean(double(reader.getFrames(100)),3);
       
%% select ROIs
if exist(fullfile(savedir,'rois.mat'),'file')
    load(fullfile(savedir,'rois.mat'))
    disp('loaded ROIs')
    figure('Name','loaded ROIs'), imagesc(im_ref.*(1 - double(any(roimat,3)).*0.2) );axis image;axis off;colormap(gray);drawnow
else

    H = figure; imagesc(im_ref), axis image, colormap gray, axis off
    roimat = [];
    e = drawellipse;
    while isvalid(H)
        pause
        bw = createMask(e);
        if nnz(bw)
            roimat = cat(3, roimat,bw);
            imagesc(im_ref.*(1 - double(any(roimat,3)).*0.2) );axis image;axis off;colormap(gray);drawnow
        end
        e = drawellipse;
    end
end


%% for motion correction
if exist(fullfile(savedir,'mask.mat'),'file')
    load(fullfile(savedir,'mask.mat'))
    disp('loaded mask')
else    
    [file,location] = uigetfile('.mat', 'select SLM ROIs, or cancel to hand-select ROIs');
    
    if isnumeric(file)
    maskmat = zeros(size(im_ref)); 
    
    H = figure; imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4)), axis image, colormap gray, axis off, drawnow

    e = drawrectangle;
    while isvalid(H)
        
        pause
        bw = createMask(e);
        if nnz(bw)
            maskmat = maskmat | bw;
            imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4 - double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
        end
        e = drawrectangle;
    end

    else
        R = load(fullfile(location,file));
        maskmat = any(reshape(cell2mat(R.ROIs),size(im_ref,1),size(im_ref,2),[]),3);
        figure
        imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4 - double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
    end
end
%%



%%
NR = size(roimat,3);
tr = [];
translation =[];


%% get traces for each file
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
if ~exist(fullfile(savedir,'rois.mat'),'file')
    save(fullfile(savedir,'rois.mat'),'roimat')
    disp('saved ROIs')
else
    disp('did not save ROIs')
end

if ~exist(fullfile(savedir,'mask.mat'),'file') && exist('maskmat','var')
    save(fullfile(savedir,'mask.mat'),'maskmat')
    disp('saved MC mask')
else
    disp('did not save MC mask')
end

if ~exist(fullfile(savedir,'translation.mat'),'file') && exist('translation','var')
    save(fullfile(savedir,'translation.mat'),'translation')
    disp('saved translation')
else
    disp('did not save translation')
end

if ~exist(fullfile(savedir,'signal.mat'),'file')
    save(fullfile(savedir,'signal.mat'),'tr','fs')
    disp('saved signal')
else
    disp('did not save signal')
end


