function test_bug2365

% MEM 1gb
% WALLTIME 00:10:00
% DEPENDENCY ft_freqanalysis
% DATA private

filename = dccnpath('/project/3031000.02/test/bug2365.mat');
load(filename); % loads variable 'data'

cfg = [];
cfg.method = 'mtmconvol';
cfg.taper = 'hanning';
cfg.foi = 1:40;
cfg.t_ftimwin = 4 ./ cfg.foi;
cfg.toi = 'all';
cfg.keeptrials = 'yes';
cfg.output = 'pow';

convol = ft_freqanalysis(cfg, data);

cfg.output = 'fourier'; % does not work
convol2 = ft_freqanalysis(cfg, data);
