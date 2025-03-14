function test_bug3190

% MEM 1gb
% WALLTIME 00:10:00
% DEPENDENCY ft_sourceinterpolate ft_sourceparcellate ft_volumereslice
% DATA private

[ftver, ftpath] = ft_version;
templatedir  = fullfile(ftpath, 'template');

%% Lets load atlas, sourcemodel, and a connectivity structure
atlas = ft_read_atlas(fullfile(templatedir, 'atlas', 'aal', 'ROI_MNI_V4.nii'));
load(fullfile(templatedir, 'sourcemodel', 'standard_sourcemodel3d10mm.mat')); % 'sourcemodel'
load(dccnpath('/project/3031000.02/test/bug3190.mat'));

source_pco  = ft_convert_units(source_pco, 'cm');
atlas       = ft_convert_units(atlas, 'cm');
sourcemodel = ft_convert_units(sourcemodel, 'cm');

%% For parcellation we need an atlas that corresponds to our sourcemodel
cfg_int = [];
cfg_int.interpmethod = 'nearest';
cfg_int.parameter = 'tissue';
atlas_templ = ft_sourceinterpolate(cfg_int, atlas, sourcemodel);

%% All of these have to be identical
source_pco.pos  = sourcemodel.pos;
atlas_templ.pos = sourcemodel.pos;

%% Now the parcellation works
cfg     = [];
cfg.parcellation  = 'tissue';
cfg.parameter   = 'powcorrspctrm';
source_pco_parc   = ft_sourceparcellate(cfg, source_pco, atlas_templ);
imagesc(source_pco_parc.powcorrspctrm)

%% This subsequently failed
% see http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=3190#c6
mri = ft_read_mri(fullfile(templatedir, 'anatomy', 'single_subj_T1_1mm.nii'));

cfg            = [];
cfg.resolution = 1;
cfg.dim        = [256 256 256];
mrirs          = ft_volumereslice(cfg, mri);
