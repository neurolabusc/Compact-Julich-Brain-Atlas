function julich2vue_C_collapse(idxnm, probnm)
if ~exist(idxnm,'file'), error('Unable to find %s', idxnm); end
if ~exist(probnm,'file'), error('Unable to find %s', probnm); end
tic
hdr = spm_vol(idxnm);
imgIdx = spm_read_vols(hdr);
hdr = spm_vol(probnm);
imgProb = spm_read_vols(hdr);

img = cat(4, imgIdx,imgProb);
dim = size(img);
img = reshape(img, [prod(dim(1:3)), dim(4)]);

u = unique(img, 'rows');
fprintf('number of voxels %d unique features %d: reduction factor %g\n', size(img,1), size(u,1), size(u,1)/size(img,1));
mx = floor(size(u,2) / 2);
pct1 = mx + 1;
%first pass: determine size
sum = 0;
bytes = 0;
for i = 1 : size(u,1)
    
    roi = u(i,1:mx);
    pct = u(i,pct1:end);
    idx = find(pct > 0);
    pct = pct(idx);
    roi = roi(idx);
    n = numel(pct);
    if n == 0
        fprintf('empty! (hopefully only one)\n');
    end
    sum = sum + n;
    bytes = bytes + 2 + (2 * n);
end
sum
bytes


toc
%fprintf('number of voxels %d number of unique features %d reduction factor %\n', size(img,1) size(u,1) );%3964032x28 -> 1524811x28