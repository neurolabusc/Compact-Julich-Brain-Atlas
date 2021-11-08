function julich2vue_B_crop(fnm, shadowfnm)
%nii_tight_crop('sum.nii', 'JULICH_BRAIN_CYTOARCHITECTONIC_MAPS_2_9_MNI152_2009C_NONL_ASYM.pmaps.nii')
%discard exterior rows/columns/slices that are zeros, output has 'z' prefix
% fnms : file name of image (optional)
%Examples
% nii_tight_crop; %use GUI
% nii_tight_crop('img.nii');

if ~exist('fnm','var') %no filename specified
	fnm = spm_select(1,'image','Select image[s] for crop'); 
end
%load image
hdr = spm_vol(deblank(fnm));
img = spm_read_vols(hdr);
if size(img,4) > 1
    error('%s designed for 3D images with only a single volume\n',mfilename);
end
img(isnan(img)) = 0;%zero nans
xyzLo = zeros(3,1);
xyzHi = zeros(3,1);
v = (sum(img,[2,3]) > 0) + 0.0;
xyzLo(1) = find(v,1,'first');
xyzHi(1) = find(v,1,'last');
v = (sum(img,[1,3]) > 0) + 0.0;
xyzLo(2) = find(v,1,'first');
xyzHi(2) = find(v,1,'last');
v = (sum(img,[1,2]) > 0) + 0.0;
xyzLo(3) = find(v,1,'first');
xyzHi(3) = find(v,1,'last');
%abort if there are no voxels to crop
if (sum(xyzLo(:)) == 3) && (sum(size(img)'-xyzHi) == 0)
    fprintf('Unable to crop this image: positive intensity observed to all edges\n');
    return
end
fprintf(" %d..%d %d..%d %d..%d\n", xyzLo(1), xyzHi(1), xyzLo(2), xyzHi(2), xyzLo(3), xyzHi(3))
applycrop(fnm, xyzLo, xyzHi);
if ~exist('shadowfnm','var'), return; end
if ~exist(shadowfnm, 'file'), error('Unable to find %s', shadowfnm); end
applycrop(shadowfnm, xyzLo, xyzHi);

return;
%save cropped image
%fprintf(" %d..%d %d..%d %d..%d\n", xlo, xhi, ylo, yhi, zlo, zhi)
%frac =  (size(img,1) * size(img,2) * size(img,3))/(hdr.dim(1) * hdr.dim(2) * hdr.dim(3));
%fprintf("input size %d %d %d, output size %d %d %d = %g%%\n", hdr.dim(1), hdr.dim(2), hdr.dim(3), size(img,1),size(img,2),size(img,3), 100*frac)

function applycrop(fnm, xyzLo, xyzHi)
hd = spm_vol(deblank(fnm));
%img = spm_read_vols(hd);
%img = img(xyzLo(1):xyzHi(1), xyzLo(2):xyzHi(2), xyzLo(3):xyzHi(3), 1:end);
%hd is an array, hdr is first header:
hdr = hd(1);
img = spm_read_vols(hd(1));
img = img(xyzLo(1):xyzHi(1), xyzLo(2):xyzHi(2), xyzLo(3):xyzHi(3));
v2m = hdr.mat;
cropLo = xyzLo - 1;
origin= cropLo'*v2m(1:3,1:3)' + v2m(1:3,4)';
hdr.mat(1:3,4) = origin;
hdr.dim(1) = size(img,1);
hdr.dim(2) = size(img,2);
hdr.dim(3) = size(img,3);
[pth nm ext] = spm_fileparts(fnm);
hdr.fname = fullfile(pth, ['c' nm ext]); 
for i = 1 : numel(hd)
    img = spm_read_vols(hd(i));
    img = img(xyzLo(1):xyzHi(1), xyzLo(2):xyzHi(2), xyzLo(3):xyzHi(3));
    hdr.n(1)=i;
    spm_write_vol(hdr,img);
    if (mod(i, 10) == 0), fprintf('Cropped volume %d\n', i); end;
end
%end nii_tight_crop()