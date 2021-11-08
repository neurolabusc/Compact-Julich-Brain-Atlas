function julich2vue_C_maxprob(fnm)
if ~exist(fnm,'file'), error('Unable to find %s', fnm); end
hd = spm_vol(deblank(fnm));
hdr = hd(1);
imgProb = zeros(hdr.dim(1), hdr.dim(2), hdr.dim(3)); %probability of region with highest probabilty
imgIdx = imgProb; %index of region with highest probabilty
%imgCnt = imgProb; %count: how many regions contribute to each voxel - sum
for i = 1 : numel(hd)
    img = spm_read_vols(hd(i));
    %imgCnt(img > 0) = imgCnt(img > 0) + 1;
    imgIdx(img > imgProb) = i;
    imgProb = max(img, imgProb);
    imgProb = max(img, imgProb);
    imgProb = max(img, imgProb);
    fprintf('volume %d\n', i)
end
[pth nm ext] = spm_fileparts(fnm);
hdr.fname = fullfile(pth, ['maxProb' ext]);
spm_write_vol(hdr,imgProb);
hdr.fname = fullfile(pth, ['maxIdx' ext]);
spm_write_vol(hdr,imgIdx);
%fprintf('count: maximum number of regions that contribute to a single voxel: %d\n', max(imgCnt(:)))
%hdr.fname = fullfile(pth, ['maxCnt' ext]);
%spm_write_vol(hdr,imgCnt);