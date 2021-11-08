function julich2vue
%Download and decompress latest version
% https://search.kg.ebrains.eu/instances/ab191c17-8cd8-4622-aaac-eee11b2fa670
basenm = 'JULICH_BRAIN_CYTOARCHITECTONIC_MAPS_2_9_MNI152_2009C_NONL_ASYM';
niinm = [basenm, '.pmaps.nii'];
%if ~exist(niinm, 'file'), error('%s Unable to find %s\n', mfilename, niinm); end
txtnm = [basenm, '.txt'];
if ~exist(txtnm, 'file'), error('%s Unable to find %s\n', mfilename, txtnm); end
%niinm = round2pct(niinm);
niinm = 'pct.nii';
julich2vue_A_sum(niinm);
%fprintf('skipping stage A');
sumnm = 'sum.nii';
%step 2: crop image: reduce 10.1Gb -> 4.69Gb
%julich2vue_B_crop(sumnm, niinm);
sumnm = ['c', sumnm];
niinm = ['c', niinm];
julich2vue_C_collapse(sumnm, niinm);
julich2vue_D_unique('idx.nii','prob.nii')

