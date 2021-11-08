## About

The [Julich-Brain Atlas](https://search.kg.ebrains.eu/instances/ab191c17-8cd8-4622-aaac-eee11b2fa670) is a whole-brain collection of cytoarchitectonic probabilistic maps. The current release maps 296 regions. The raw data is provided as a [NIfTI](https://nifti.nimh.nih.gov) format 4D dataset with 193×229×193 voxels, with each voxel a 32-bit float. Decompressed, this requires 9.4Gb of memory (while this compresses to 88mb on disk, the entire dataset must be extracted for analyses). Since each region is saved as a contiguous 3D volume, determining which brain regions contribute to a specific voxel is inefficient. Therefore, while the distributed data uses a simple format, it is not suitable for some applications. This repository includes a Matlab script for dramatically reducing these demands. The script can be run each time a new release of the Atlas is provided.

The scripts here generate a file that requires less than 23mb. It losslessly preserves the spatial precision, while probabilities are rounded to the nearest percent. Given that the current data is based on 23 brains, this level of precision seems sufficient.

An alternative approach is used by [FSLeyes](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLeyes) which is currently distributed with a 121 region version of the Julich atlas. The probabilities are downsampled to 8-bit precision (256 levels, with the tool reporting the nearest percent) and requires 873mb when extracted into memory.

## Processing steps

 1. Sum: create a 3D image (sum.nii) that counts the number of regions that contribute to each voxel. Currently, this identifies that no voxel is associated with more than 14 regions. **Optionally, since the data comes from just 23 brains, we can round data to the nearest percent, this will reduce the maximum overlap to just 13 regions.** The software includes the option to round or not, but for explicit values listed below we assume rounding.
 2. Crop: eliminate border rows, columns and slices that where the sum is zero. Currently, this creates a cropped images (csum.nii, catlas.nii) with a resolution of 148×185×143 voxels (from 9631mb to 4421mb).
 3. Collapse: Create two images of size 148×185×143×13: one contains the region numbers contributing to a voxel (idx.nii), the other the probabilities (prob.nii) associated with each of these regions. Together these require 4.1% of the original decompressed size. Note order of volumes is ordered based on region index, not probability. (from 9631mb to 338 mb)
 4. Uniqueness: There is a tremendous number of redundancy in these images: even after cropping 61% of voxels are outside the brain (no regions contribute). Likewise, there are neighboring voxels that have precisely the same regions contributing the same proportions. Here we identify all the unique patterns seen in the dataset, this reduces the size to 24% of the results from step 3. The data is now 2.1% of the input file size. There are 957268 unique patterns.
 We now save all the patterns contiguously. Only a tiny portion of the voxels really include regions from 13 different regions. Each pattern is saved as 2+2*n bytes, where n is the number of regions contributing. The format of the lookup table is:
 	- 16 bits (0..65535): number of regions in pattern (required range: 0..14)
 	  - 9 bits (0..511): probability of region (required range: 1..296)
 	  - 7 bits (0..127): probability of region (required range 1..100%)
 5. The above process will lead us to a lookup table of 7.84mb. This integer can be precisely encoded as a [32-bit float](https://www.mathworks.com/help/matlab/ref/flintmax.html)). This is crucial, because the NIfTI header specifies [vox_offset](https://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h) as a float32. Therefore, this lookup table can be encoded inside the NIfTI header, and the NIfTI image data can use the DT_FLOAT datatype to refer to the lookup table. The NIfTI image with the embedded lookup table requires less than 23mb. Compared to the original dataset, we have reduced the data by a factor of 422! Further, all data for regions stored contiguously, which dramatically improves memory performance (we read cache lines). 