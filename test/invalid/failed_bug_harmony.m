function failed_bug_harmony

% WALLTIME 00:45:00
% MEM 4gb
% DEPENDENCY

% this is to test the implementation of the frequency domain harmony reconstruction
% see also bug2822

%% Start-up
%path_ft = '/home/electromag/lucamb/fieldtrip-dev';
%addpath(path_ft)

%% Load data (dataFIC)
path_to_load = dccnpath('/home/common/matlab/fieldtrip');
%load(dccnpath([path_to_load, '/data/test/dataFIC.mat']))

% find the interesting segments of data
cfg = [];
cfg.dataset                 = dccnpath('/project/3031000.02/external/download/test/ctf/Subject01.ds');       % name of CTF dataset
cfg.trialdef.eventtype      = 'backpanel trigger';
cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 2;
cfg.trialdef.eventvalue     = 3;                    % event value of FIC
cfg = ft_definetrial(cfg);

% remove the trials that have artifacts from the trl
cfg.trl([15, 36, 39, 42, 43, 49, 50, 81, 82, 84],:) = [];

% preprocess the data
cfg.channel   = {'MEG', '-MLP31', '-MLO12'};        % read all MEG channels except MLP31 and MLO12
cfg.demean    = 'yes';                              % do baseline correction with the complete trial

dataFIC = ft_preprocessing(cfg);

%% Frequency analysis

cfg              = [];
cfg.output       = 'powandcsd';
cfg.channel      = 'MEG';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 18;
freq = ft_freqanalysis(cfg, dataFIC);

%% Fake Headmodel and leadfield

load(dccnpath([path_to_load, '/template/headmodel/standard_singleshell.mat']))

% use 'icosahedron' private function to generate the mash
mesh = [];
[mesh.pnt, mesh.tri] = icosahedron642;
mesh.pnt = 5*mesh.pnt - repmat([ 0 3 -1.5],size(mesh.pnt,1),1);


%% Plot head model

% load vol                                       % volume conduction model
figure;hold on;
ft_plot_headmodel(vol, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(mesh, 'edgecolor', 'none'); camlight
ft_plot_sens(dataFIC.grad, 'style', '*b');

%% Source analysis HARMONY

cfg = [];
cfg.method = 'harmony';
%cfg.rawtrial = 'yes';
cfg.harmony.filter_order = 1;
cfg.harmony.filter_bs = 1;
cfg.harmony.number_harmonics = 150;
cfg.harmony.connected_components = 1;
cfg.frequency = 18;
cfg.sourcemodel      = mesh;
cfg.headmodel = vol;
cfg.harmony.noisecov = 10^-15*eye(149);
cfg.harmony.lambda = 0.001;
source_freq_mne = ft_sourceanalysis(cfg, freq);

%% Plot

figure,
ft_plot_mesh(mesh, 'vertexcolor', source_freq_mne.avg.pow);
