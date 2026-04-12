% part of signal extraction that must be interactive (can't be scripted on
% HPC)
addpath(genpath('\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\SpikeTriggeredPlots'))
addpath(genpath('\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage'))
addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage'))
addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/SpikeTriggeredPlots'))

[filename, filedir] = uigetfile('*.raw','Select reference file');
impath = fullfile(filedir, filename);

reader = FrameReader(impath);
im_ref = mean(double(reader.getFrames(100)),3);

k_dot = strfind(filename,'.');
savedir = fullfile(filedir,['analysis_',filename(1:k_dot-1)]);
if ~exist(savedir), mkdir(savedir),end

%%
if exist('maskmat','var')
    figure
    imagesc(im_ref.*(1- double(maskmat).*0.2) );axis image;axis off;colormap(gray);
elseif exist(fullfile(savedir,'mask.mat'),'file')
    load(fullfile(savedir,'mask.mat'))
    disp('loaded mask')
    figure
    imagesc(im_ref.*(1- double(maskmat).*0.2) );axis image;axis off;colormap(gray);
else    
    [file,location] = uigetfile('.mat', 'select SLM ROIs, or cancel to hand-select ROIs');
    
    if isnumeric(file)
    maskmat = zeros(size(im_ref)); 
    
    H = figure; imagesc(im_ref), axis image, colormap gray, axis off, drawnow

    e = drawrectangle;
    while isvalid(H)
        
        pause
        bw = createMask(e);
        if nnz(bw)
            maskmat = maskmat | bw;
            imagesc(im_ref.*(1 - double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
        end
        e = drawrectangle;
    end

    else
        R = load(fullfile(location,file));
        maskmat = any(reshape(cell2mat(R.ROIs),size(im_ref,1),size(im_ref,2),[]),3);
        figure
        imagesc(im_ref.*(1- double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
    end
end

%%
if exist('roimat','var')
    figure
    imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4)- double(maskmat).*0.2 );axis image;axis off;colormap(gray);
elseif exist(fullfile(savedir,'rois.mat'),'file')
    load(fullfile(savedir,'rois.mat'))
    disp('loaded ROIs')
    figure('Name','loaded ROIs'), imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4- double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
else

    H = figure; imagesc(im_ref.*(1-double(maskmat).*0.2)), axis image, colormap gray, axis off
    roimat = [];
    e = drawellipse;
    while isvalid(H)
        pause
        bw = createMask(e);
        if nnz(bw)
            roimat = cat(3, roimat,bw);
            imagesc(im_ref.*(1 - double(any(roimat,3)).*0.4- double(maskmat).*0.2) );axis image;axis off;colormap(gray);drawnow
        end
        e = drawellipse;
    end
end


%%
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

% add filename to list
fpath_desktop = '\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\MC_file.txt';
if exist(fpath_desktop,'file')
    fid = fopen(fpath_desktop,'a');
else
    fid = fopen('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage/MC_file.txt','a');
end
fprintf(fid,[strrep([filedir,filename(1:k_dot-1)],'\','\\'),'\n']);
fclose(fid);
disp('added to MC text file')
