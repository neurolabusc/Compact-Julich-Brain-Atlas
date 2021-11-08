function julich2vue_C_collapse(sumnm, niinm)
if ~exist(sumnm,'file'), error('Unable to find %s', sumnm); end
if ~exist(niinm,'file'), error('Unable to find %s', niinm); end
hdr = spm_vol(sumnm);
img = spm_read_vols(hdr);
mx = max(img(:));
fprintf('Maximum number of regions associated with a single voxel: %d\n', mx);
fprintf('Fraction of voxels not associated with any regions: %g\n', sum(img(:) == 0)/numel(img))
imgProb = zeros(hdr.dim(1) * hdr.dim(2) * hdr.dim(3), mx); %probabilities associated with region
imgIdx = imgProb;
imgMx = zeros(hdr.dim(1), hdr.dim(2), hdr.dim(3));

hd = spm_vol(deblank(niinm));

for i = 1 : numel(hd)
    img = spm_read_vols(hd(i));
    if (mod(i, 10) == 0), fprintf('volume %d\n', i); end;
    for v = 1 : numel(img)
        if (img(v) <= 0), continue; end
        imgMx(v) = imgMx(v) + 1;
        imgProb(v, imgMx(v)) = img(v);
        imgIdx(v, imgMx(v)) = i;
        
    end
end
imgProb = reshape(imgProb, [hdr.dim(1), hdr.dim(2), hdr.dim(3), mx]);
saveimg('prob.nii', hdr, imgProb);
imgIdx = reshape(imgIdx, [hdr.dim(1), hdr.dim(2), hdr.dim(3), mx]);
saveimg('idx.nii', hdr, imgIdx);

function saveimg(fnm, hdr, img)
hdr.fname = fnm;
v = size(img,4);
for i = 1 : v
    hdr.n(1)=i;
    spm_write_vol(hdr,img(:,:,:,i));
end