function test_bug2734

% MEM 1gb
% WALLTIME 00:10:00
% DEPENDENCY ft_read_cifti
% DATA private


cd(dccnpath('/project/3031000.02/test/bug2734'));

cii = ft_read_cifti('tstat1.dtseries.nii');

assert(size(cii.pos,1)==96854);
assert(numel(cii.dtseries)==96854);
assert(numel(unique(cii.brainstructurelabel))==max(cii.brainstructure));
