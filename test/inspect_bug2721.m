function inspect_bug2721

% WALLTIME 00:10:00
% MEM 1gb
% DEPENDENCY ft_multiplotTFR
% DATA private

load(dccnpath('/project/3031000.02/test/bug2721.mat'));

cfg = [];
cfg.marker       = 'on';
cfg.layout       = 'neuromag306mag.lay';
cfg.channel      = 'MEG*1';
cfg.parameter = 'powspctrm';
cfg.maskparameter = 'mask';

%%
% this is ok

cfg.maskstyle = 'saturation';
figure;
ft_multiplotTFR(cfg, TFR_diff_MEG);


%%
% this one shows green, but should be transparent

cfg.maskstyle = 'opacity';
figure;
ft_multiplotTFR(cfg, TFR_diff_MEG);


%%
% this one showed the outlines in the SCALE box

cfg.maskstyle = 'outline';
figure;
ft_multiplotTFR(cfg, TFR_diff_MEG);


%%
% do some additional checks with singleplot

cfg = [];
cfg.channel = 'MEG0431';
cfg.parameter = 'powspctrm';
cfg.maskparameter = 'mask';

cfg.maskstyle = 'saturation';
figure;
ft_singleplotTFR(cfg, TFR_diff_MEG);

cfg.maskstyle = 'opacity';
figure;
ft_singleplotTFR(cfg, TFR_diff_MEG);

cfg.maskstyle = 'outline';
figure;
ft_singleplotTFR(cfg, TFR_diff_MEG);

