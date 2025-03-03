function test_bug62

% MEM 1gb
% WALLTIME 00:10:00
% DEPENDENCY ft_read_mri ft_volumenormalise
% DATA public

% spm_brainwarp is missing from external/spm2
% this should cause ft_volumenormalise to crash
% if cfg.nonlinear = 'yes';
 
% reproduce bug
mrifile = dccnpath('/project/3031000.02/external/download/test/ctf/Subject01.mri');
mri     = ft_read_mri(mrifile);

cfg           = [];
cfg.nonlinear = 'yes';
mri2          = ft_volumenormalise(cfg, mri);

% this gives the error:
%
% converting input coordinates from CTF into approximate SPM coordinates
% performing the normalisation
% warping the invdividual anatomy to the template anatomy
% Smoothing by 0 & 8mm..
% Coarse Affine Registration..
% Fine Affine Registration..
% 3D CT Norm...
%  iteration  1: ??? Undefined function or method 'spm_brainwarp' for input arguments of type 'struct'.
%
% Error in ==> spm_normalise>snbasis at 288
%        [Alpha,Beta,Var,fw] =
%        spm_brainwarp(VG,VF,Affine,basX,basY,basZ,dbasX,dbasY,dbasZ,T,fwhm,VWG, VWF);
%
% Error in ==> spm_normalise at 185
%        Tr = snbasis(VG1,VF1,VWG,VWF,Affine,...
%
% Error in ==> ft_volumenormalise at 209
%  params    = spm_normalise(VG,VF);

%now copy the spm_brainwarp into external/spm2 and repeat
cfg           = [];
cfg.nonlinear = 'yes';
mri2          = ft_volumenormalise(cfg, mri);

% now it works
