function sumfnm = julich2vue_A_sum(fnm)
hdr = spm_vol(fnm);
imgSum = spm_read_vols(hdr(1));
imgSum(:) = 0;
for i = 1 : numel(hdr)
    imgSum = imgSum + ((spm_read_vols(hdr(i)) > 0) + 0.0);
    if (mod(i, 10) == 0), fprintf('Sum volume %d\n', i); end;
end
fprintf('%d regions, %d max overlap\n', numel(hdr), max(imgSum(:)))
hd = hdr(1);
sumfnm = 'sum.nii';
hd.fname = sumfnm;
spm_write_vol(hd,imgSum);