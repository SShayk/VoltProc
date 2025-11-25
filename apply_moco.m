function im_t = apply_moco(filedir, filename)

reader = FrameReader(fullfile(filedir,[filename,'.raw']));
im = double(reader.getFrames(reader.maxFrames));

load(fullfile(filedir,['analysis_',filename],'translation.mat'))

im_t = zeros(size(im));
for k = 1:size(im,3)
        im_t(:,:,k) = circshift(im(:,:,k), translation(k,:));
end

end