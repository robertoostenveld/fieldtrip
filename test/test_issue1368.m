function test_issue1368

% WALLTIME 00:10:00
% MEM 1gb
% DEPENDENCY ft_plot_sens mesh_cylinder
% DATA private

load(dccnpath('/project/3031000.02/test/issue1368/hull.mat'))
load(dccnpath('/project/3031000.02/test/issue1368/elec.mat'))

%%

ft_plot_sens(elec, 'elecshape', 'point', 'headshape', []);
ft_plot_sens(elec, 'elecshape', 'point', 'headshape', hull);

%%

ft_plot_sens(elec, 'elecshape', 'circle', 'headshape', []);
ft_plot_sens(elec, 'elecshape', 'circle', 'headshape', hull);

%%

ft_plot_sens(elec, 'elecshape', 'square', 'headshape', []);
ft_plot_sens(elec, 'elecshape', 'square', 'headshape', hull);

%%

ft_plot_sens(elec, 'elecshape', 'sphere', 'headshape', []);
ft_plot_sens(elec, 'elecshape', 'sphere', 'headshape', hull);

%%

ft_plot_sens(elec, 'elecshape', 'disc', 'headshape', []);
ft_plot_sens(elec, 'elecshape', 'disc', 'headshape', hull);
