function inspect_ft_electroderealign

% MEM 1gb
% WALLTIME 00:10:00
% DEPENDENCY ft_electroderealign ft_read_mri ft_read_sens ft_prepare_mesh ft_warp_apply
% DATA public

[ftver, ftpath] = ft_version;
templatedir  = fullfile(ftpath, 'template');

%% load mri, segmentation and electrode definition
mri = ft_read_mri(dccnpath('/project/3031000.02/external/download/test/ctf/Subject01.mri'));
load(dccnpath('/project/3031000.02/external/download/tutorial/headmodel_eeg/segmentedmri.mat'));
elec = ft_read_sens(fullfile(templatedir, 'electrode', 'standard_1020.elc'));
temp = ft_read_sens(fullfile(templatedir, 'electrode', 'standard_1005.elc'));

% create a bem and a fem mesh

cfg = [];
cfg.tissue = {'brain', 'skull', 'scalp'};
cfg.numvertices = [3000 2000 1000];
bem = ft_prepare_mesh(cfg, segmentedmri);

cfg = [];
cfg.method = 'hexahedral';
cfg.tissue = {'brain', 'skull', 'scalp'};
fem = ft_prepare_mesh(cfg, segmentedmri);

%% method: fiducial

nas = mri.hdr.fiducial.mri.nas;
lpa = mri.hdr.fiducial.mri.lpa;
rpa = mri.hdr.fiducial.mri.rpa;

% they are in voxels, hence need to be transformed to head coordinates
nas = ft_warp_apply(mri.transform, nas, 'homogenous');
lpa = ft_warp_apply(mri.transform, lpa, 'homogenous');
rpa = ft_warp_apply(mri.transform, rpa, 'homogenous');

fiducials.chanpos  = [nas; lpa; rpa];
fiducials.label    = {'Nz', 'LPA', 'RPA'};
fiducials.unit     = mri.unit;
fiducials.coordsys = mri.coordsys;

cfg = [];
cfg.method = 'fiducial';
cfg.template = fiducials;
cfg.elec = elec;
cfg.channel = 'all';
cfg.fiducial = {'Nz', 'LPA', 'RPA'};
elec_realigned1 = ft_electroderealign(cfg);

figure
ft_plot_sens(elec_realigned1, 'label', 'on');
ft_plot_axes(elec_realigned1, 'fontcolor', 'k');

%% method: template

cfg = [];
cfg.method = 'template';
cfg.template = elec_realigned1;
cfg.elec = elec;
elec_realigned2 = ft_electroderealign(cfg);

figure
ft_plot_sens(elec_realigned2, 'label', 'on');
ft_plot_axes(elec_realigned2, 'fontcolor', 'k');

%% method: interactive

% rotate    [0 0 -90]
% translate [35 0 40]

cfg = [];
cfg.method = 'interactive';
cfg.headshape = bem(3);
cfg.elec = elec;
elec_realigned3 = ft_electroderealign(cfg);

figure
ft_plot_sens(elec_realigned3, 'label', 'on');
ft_plot_axes(elec_realigned3, 'fontcolor', 'k');

%% method: headshape

cfg = [];
cfg.method = 'headshape';
cfg.headshape = bem(1);
cfg.elec = elec_realigned3;
elec_realigned4 = ft_electroderealign(cfg);

figure
ft_plot_sens(elec_realigned4, 'label', 'on');
ft_plot_axes(elec_realigned4, 'fontcolor', 'k');
