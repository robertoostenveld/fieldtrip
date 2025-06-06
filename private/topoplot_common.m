function cfg = topoplot_common(cfg, varargin)

% TOPOPLOT_COMMON is shared by FT_TOPOPLOTTFR, FT_TOPOPLOTER and FT_TOPOPLOTIC, which
% serve as placeholder for the documentation and for the pre/postamble.

% Copyright (C) 2005-2011, F.C. Donders Centre
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPERS NOTE: This code is organized in a similar fashion for multiplot/singleplot/topoplot
% and for ER/TFR and should remain consistent over those 6 functions.
% Section 1: general cfg handling that is independent from the data
% Section 2: data handling, this also includes converting bivariate (chan_chan and chancmb) into univariate data
% Section 3: select the data to be plotted and determine min/max range
% Section 4: do the actual plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Section 1: general cfg handling that is independent from the data

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'forbidden',  {'channels', 'trial'}); % prevent accidental typos
cfg = ft_checkconfig(cfg, 'unused',     {'cohtargetchannel'});
cfg = ft_checkconfig(cfg, 'renamed',    {'cohrefchannel' 'refchannel'});
cfg = ft_checkconfig(cfg, 'renamed',    {'zparam', 'parameter'});

% check for option-values to be renamed
cfg = ft_checkconfig(cfg, 'renamedval', {'electrodes',     'dotnum',      'numbers'});
cfg = ft_checkconfig(cfg, 'renamedval', {'zlim',           'absmax',      'maxabs'});
cfg = ft_checkconfig(cfg, 'renamedval', {'directionality', 'feedforward', 'outflow'});
cfg = ft_checkconfig(cfg, 'renamedval', {'directionality', 'feedback',    'inflow'});
cfg = ft_checkconfig(cfg, 'renamedval', {'highlight',      'yes',         'on'});

% check for renamed options
cfg = ft_checkconfig(cfg, 'renamed',     {'matrixside',    'directionality'});
cfg = ft_checkconfig(cfg, 'renamed',     {'electrodes',    'marker'});
cfg = ft_checkconfig(cfg, 'renamed',     {'emarker',       'markersymbol'});
cfg = ft_checkconfig(cfg, 'renamed',     {'ecolor',        'markercolor'});
cfg = ft_checkconfig(cfg, 'renamed',     {'emarkersize',   'markersize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'efontsize',     'markerfontsize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'hlmarker',      'highlightsymbol'});
cfg = ft_checkconfig(cfg, 'renamed',     {'hlcolor',       'highlightcolor'});
cfg = ft_checkconfig(cfg, 'renamed',     {'hlmarkersize',  'highlightsize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'maplimits',     'zlim'});

% old ft_checkconfig adapted partially from topoplot.m (backwards backwards compatability)
cfg = ft_checkconfig(cfg, 'renamed',     {'grid_scale',    'gridscale'});
cfg = ft_checkconfig(cfg, 'renamed',     {'interpolate',   'interpolation'});
cfg = ft_checkconfig(cfg, 'renamed',     {'numcontour',    'contournum'});
cfg = ft_checkconfig(cfg, 'renamed',     {'electrod',      'marker'});
cfg = ft_checkconfig(cfg, 'renamed',     {'electcolor',    'markercolor'});
cfg = ft_checkconfig(cfg, 'renamed',     {'emsize',        'markersize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'efsize',        'markerfontsize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'headlimits',    'interplimits'});

% check for forbidden options
cfg = ft_checkconfig(cfg, 'forbidden',  {'hllinewidth', ...
  'headcolor', ...
  'hcolor', ...
  'hlinewidth', ...
  'contcolor', ...
  'outline', ...
  'highlightfacecolor', ...
  'showlabels'});

if ft_platform_supports('griddata-v4')
  default_interpmethod = 'v4';
else
  % Octave does not support 'v4', and 'cubic' is not yet implemented
  default_interpmethod = 'linear';
end

% set other config defaults
cfg.xlim              = ft_getopt(cfg, 'xlim',             'maxmin');
cfg.ylim              = ft_getopt(cfg, 'ylim',             'maxmin');
cfg.zlim              = ft_getopt(cfg, 'zlim',             'maxmin');
cfg.style             = ft_getopt(cfg, 'style',            'both');
cfg.gridscale         = ft_getopt(cfg, 'gridscale',         67);
cfg.interplimits      = ft_getopt(cfg, 'interplimits',     'head');
cfg.interpolation     = ft_getopt(cfg, 'interpolation',     default_interpmethod);
cfg.contournum        = ft_getopt(cfg, 'contournum',        6);
cfg.colormap          = ft_getopt(cfg, 'colormap',         'default');
cfg.colorbar          = ft_getopt(cfg, 'colorbar',         'no');
cfg.colorbartext      = ft_getopt(cfg, 'colorbartext',    '');
cfg.shading           = ft_getopt(cfg, 'shading',          'flat');
cfg.comment           = ft_getopt(cfg, 'comment',          'auto');
cfg.fontsize          = ft_getopt(cfg, 'fontsize',          8);
cfg.fontweight        = ft_getopt(cfg, 'fontweight',       'normal');
cfg.baseline          = ft_getopt(cfg, 'baseline',         'no'); % to avoid warning in timelock/freqbaseline
cfg.trials            = ft_getopt(cfg, 'trials',           'all', 1);
cfg.interactive       = ft_getopt(cfg, 'interactive',      'yes');
cfg.hotkeys           = ft_getopt(cfg, 'hotkeys',          'yes');
cfg.renderer          = ft_getopt(cfg, 'renderer',          []); % let MATLAB decide on the default
cfg.marker            = ft_getopt(cfg, 'marker',           'on');
cfg.markersymbol      = ft_getopt(cfg, 'markersymbol',     'o');
cfg.markercolor       = ft_getopt(cfg, 'markercolor',       [0 0 0]);
cfg.markersize        = ft_getopt(cfg, 'markersize',        2);
cfg.markerfontsize    = ft_getopt(cfg, 'markerfontsize',    8);
cfg.highlight         = ft_getopt(cfg, 'highlight',        'off');
cfg.highlightchannel  = ft_getopt(cfg, 'highlightchannel', 'all', 1); % highlight may be 'on', making highlightchannel {} meaningful
cfg.highlightsymbol   = ft_getopt(cfg, 'highlightsymbol',  '*');
cfg.highlightcolor    = ft_getopt(cfg, 'highlightcolor',    [0 0 0]);
cfg.highlightsize     = ft_getopt(cfg, 'highlightsize',     6);
cfg.highlightfontsize = ft_getopt(cfg, 'highlightfontsize', 8);
cfg.labeloffset       = ft_getopt(cfg, 'labeloffset',       0.005);
cfg.maskparameter     = ft_getopt(cfg, 'maskparameter',     []);
cfg.component         = ft_getopt(cfg, 'component',         []);
cfg.directionality    = ft_getopt(cfg, 'directionality',    []);
cfg.channel           = ft_getopt(cfg, 'channel',          'all');
cfg.refchannel        = ft_getopt(cfg, 'refchannel',        []);
cfg.figurename        = ft_getopt(cfg, 'figurename',        []);
cfg.interpolatenan    = ft_getopt(cfg, 'interpolatenan',   'yes');
cfg.commentpos        = ft_getopt(cfg, 'commentpos',       'layout');
cfg.scalepos          = ft_getopt(cfg, 'scalepos',         'layout');
cfg.figure            = ft_getopt(cfg, 'figure',           'yes');

% the user can either specify a single group of channels for highlighting
% which are all to be plotted in the same style, or multiple groups with a
% different style for each group. The latter is used by ft_clusterplot.
if iscell(cfg.highlightchannel) && ~isempty(cfg.highlightchannel) && ischar(cfg.highlightchannel{1})
  % it is a single cell-array with channels names, e.g. {'C1', 'Cz', 'C2'}
  cfg.highlightchannel = {cfg.highlightchannel};
elseif isnumeric(cfg.highlightchannel)
  % it is a numeric selection of channels, e.g. [1 2 3 4]
  cfg.highlightchannel = {cfg.highlightchannel};
elseif ischar(cfg.highlightchannel)
  % it is a single channel or single channel group, e.g. 'all'
  cfg.highlightchannel = {{cfg.highlightchannel}};
end
if ~iscell(cfg.highlight)
  cfg.highlight = {cfg.highlight};
end
if ~iscell(cfg.highlightsymbol)
  cfg.highlightsymbol = {cfg.highlightsymbol};
end
if ~iscell(cfg.highlightcolor)
  cfg.highlightcolor = {cfg.highlightcolor};
end
if ~iscell(cfg.highlightsize)
  cfg.highlightsize = {cfg.highlightsize};
end
if ~iscell(cfg.highlightfontsize)
  cfg.highlightfontsize = {cfg.highlightfontsize};
end
% make sure all cell-arrays for options are sufficiently long
ncellhigh = length(cfg.highlightchannel);
if length(cfg.highlight)          < ncellhigh,   cfg.highlight{ncellhigh}          = [];  end
if length(cfg.highlightsymbol)    < ncellhigh,   cfg.highlightsymbol{ncellhigh}    = [];  end
if length(cfg.highlightcolor)     < ncellhigh,   cfg.highlightcolor{ncellhigh}     = [];  end
if length(cfg.highlightsize)      < ncellhigh,   cfg.highlightsize{ncellhigh}      = [];  end
if length(cfg.highlightfontsize)  < ncellhigh,   cfg.highlightfontsize{ncellhigh}  = [];  end
% make sure all cell-arrays for options are not too long
cfg.highlight         (ncellhigh+1:end) = [];
cfg.highlightsymbol   (ncellhigh+1:end) = [];
cfg.highlightcolor    (ncellhigh+1:end) = [];
cfg.highlightsize     (ncellhigh+1:end) = [];
cfg.highlightfontsize (ncellhigh+1:end) = [];
% then default all empty cells
for icell = 1:ncellhigh
  if isempty(cfg.highlight{icell}),          cfg.highlight{icell} = 'on';          end
  if isempty(cfg.highlightsymbol{icell}),    cfg.highlightsymbol{icell} = 'o';     end
  if isempty(cfg.highlightcolor{icell}),     cfg.highlightcolor{icell} = [0 0 0];  end
  if isempty(cfg.highlightsize{icell}),      cfg.highlightsize{icell} = 6;         end
  if isempty(cfg.highlightfontsize{icell}),  cfg.highlightfontsize{icell} = 8;     end
end

% for backwards compatability
if strcmp(cfg.marker, 'highlights')
  ft_warning('cfg.marker=''highlights'' is no longer supported, please use cfg.highlight')
  cfg.marker = 'off';
end

% check if the colormap is in the proper format
if ~isequal(cfg.colormap, 'default')
  if ischar(cfg.colormap)
    cfg.colormap = ft_colormap(cfg.colormap);
  elseif iscell(cfg.colormap)
    cfg.colormap = ft_colormap(cfg.colormap{:});
  elseif isnumeric(cfg.colormap) && size(cfg.colormap,2)~=3
    ft_error('cfg.colormap must be Nx3');
  end
  % the actual colormap will be set below
end

Ndata = numel(varargin);
dtype = cell(1,Ndata);
for i=1:Ndata
  varargin{i} = ft_checkdata(varargin{i}, 'datatype', {'comp', 'timelock', 'freq'});
  dtype{i}    = ft_datatype(varargin{i});
end

if Ndata>1 && all(strcmp(dtype, dtype{1}))
  % this is OK, one common dtype for multiple inputs
  dtype = dtype{1};
elseif Ndata>1
  ft_error('multiple data inputs into a topoplot function should be of the same datatype');
elseif Ndata==1
  dtype =dtype{1};
end

if strcmp(dtype, 'comp')
  if Ndata>1 && numel(cfg.component)~=1
    ft_error('with multiple component structures in the input a single component topography should be specified in the input cfg');
  elseif Ndata>1
    % make the subselection of the to be plotted data
    for i=1:Ndata
      varargin{i} = select_component(varargin{i}, cfg.component);
    end
  elseif Ndata==1
    comp          = varargin{1};

    % create a cell-array of data structures of the to be plotted data
    if isempty(cfg.component)
      cfg.component = 1:size(comp.topo,2);
    end
    cfg.component(cfg.component>size(comp.topo,2)) = [];
   
    varargin = cell(1,numel(cfg.component));
    for i=1:numel(cfg.component)
      varargin{i} = select_component(comp, cfg.component(i));
    end
  end
  Ndata = numel(varargin);
end

%% Section 2: data handling, this also includes converting bivariate (chan_chan and chancmb) into univariate data
hastime = isfield(varargin{1}, 'time');

% Set x/y/parameter defaults according to datatype and dimord
switch dtype
  case 'timelock'
    xparam = ft_getopt(cfg, 'xparam', 'time');
    yparam = ft_getopt(cfg, 'yparam', '');
    if isfield(varargin{1}, 'trial')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'trial');
    elseif isfield(varargin{1}, 'individual')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'individual');
    elseif isfield(varargin{1}, 'avg')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'avg');
    end
  case 'freq'
    if hastime
      xparam = ft_getopt(cfg, 'xparam', 'time');
      yparam = ft_getopt(cfg, 'yparam', 'freq');
      cfg.parameter = ft_getopt(cfg, 'parameter', 'powspctrm');
    else
      xparam = 'freq';
      yparam = '';
      cfg.parameter = ft_getopt(cfg, 'parameter', 'powspctrm');
    end
  case 'comp'
    xparam = 'comp';
    yparam = '';
    cfg.parameter = ft_getopt(cfg, 'parameter', 'topo');
    
  otherwise
    % if the input data is not one of the standard data types, or if the functional
    % data is just one value per channel: in this case xparam, yparam are not defined
    % and the user should define the parameter
    if ~isfield(varargin{1}, 'label'), ft_error('the input data should at least contain a label-field');         end
    if ~isfield(cfg,  'parameter'), ft_error('the configuration should at least contain a ''parameter'' field'); end
    if ~isfield(cfg,  'xparam')
      cfg.xlim = [1 1];
      xparam   = '';
      yparam   = '';
    end
end

hasrpt = false(Ndata,1);
isbivariate = false(Ndata,1);
for i=1:Ndata
  % with the data being of the same type, the dimords are not guaranteed to be the same across inputs
  dimord{i} = getdimord(varargin{i}, cfg.parameter);
  isbivariate(i) = contains(dimord{i}, 'chan_chan') || contains(dimord{i}, 'chancmb_');
  hasrpt(i) = contains(dimord{i}, 'rpt_') || contains(dimord{i}, 'subj_');
end

if any(~hasrpt)
  assert(isequal(cfg.trials, 'all') || isequal(cfg.trials, 1), 'incorrect specification of cfg.trials for data without repetitions');
elseif any(hasrpt)
  assert(~isempty(cfg.trials), 'empty specification of cfg.trials for data with repetitions');
end

% handle the bivariate case
if all(isbivariate)
  % convert the bivariate data to univariate and call the parent plotting function again
  s = dbstack;
  cfg.originalfunction = s(2).name;
  cfg.trials = 'all'; % trial selection has been taken care off
  bivariate_common(cfg, varargin{:});
  return
elseif any(isbivariate)
  ft_error('a mixture of bivariate and univariate input is not allowed');
end
 
makesubplots = false;
if Ndata==1 && isequal(cfg.figure, 'subplot')
  % overrule this setting
  cfg.figure = 'yes';
elseif Ndata>1 && isequal(cfg.figure, 'subplot')
  makesubplots = true;
end
  
for indx=1:Ndata
  if makesubplots
    if indx==1
      % the subplots can be drawn into a currently open figure, which might
      % have been produced by a previous call to topoplot_common, to avoid
      % downstream issues, clear the figure, and remove any previously
      % created stale axis handles
      clf;
      guidata(gcf, []);
    end

    % make multiple plots in a single figure
    nyplot = ceil(sqrt(Ndata));
    nxplot = ceil(Ndata./nyplot);
    cfg.figure = subplot(nxplot, nyplot, indx);
  end

  if iscell(cfg.dataname)
    dataname = cfg.dataname{indx};
  else
    dataname = cfg.dataname;
  end
  
  data = varargin{indx};
  dimord = getdimord(data, cfg.parameter);
  dimtok = tokenize(dimord, '_');
  hasrpt = any(ismember(dimtok, {'rpt', 'subj'}));

  if isequal(dtype, 'comp')
    % not sure why this needs to be here
    if ischar(dataname)
      cfg.title = sprintf('%s component %d', dataname, data.comp);
    end
  end
    
  % parse cfg.channel
  if isfield(cfg, 'channel') && isfield(data, 'label')
    cfg.channel = ft_channelselection(cfg.channel, data.label);
  elseif isfield(cfg, 'channel') && isfield(data, 'labelcmb')
    cfg.channel = ft_channelselection(cfg.channel, unique(data.labelcmb(:)));
  end
  
  % Apply baseline correction
  if ~strcmp(cfg.baseline, 'no')
    % keep mask-parameter if it is set
    if ~isempty(cfg.maskparameter)
      tempmask = data.(cfg.maskparameter);
    end
    tmpcfg = removefields(cfg, 'inputfile');
    if strcmp(xparam, 'time') && strcmp(yparam, 'freq')
      data = ft_freqbaseline(tmpcfg, data);
    elseif strcmp(xparam, 'time') && strcmp(yparam, '')
      data = ft_timelockbaseline(tmpcfg, data);
    end
    % put mask-parameter back if it is set
    if ~isempty(cfg.maskparameter)
      data.(cfg.maskparameter) = tempmask;
    end
  end
  
  % time and/or frequency should NOT be selected and averaged here, since a singleplot might follow in interactive mode
  tmpcfg = keepfields(cfg, {'channel', 'trials', 'showcallinfo', 'trackcallinfo', 'trackusage', 'trackdatainfo', 'trackmeminfo', 'tracktimeinfo', 'checksize'});
  if hasrpt
    tmpcfg.avgoverrpt = 'yes';
  else
    tmpcfg.avgoverrpt = 'no';
  end
  tmpvar = data;
  ws = ft_warning('off', 'FieldTrip:getdimord:warning_dimord_could_not_be_determined');
  [data] = ft_selectdata(tmpcfg, data);
  ft_warning(ws);
  % restore the provenance information
  [cfg, data] = rollback_provenance(cfg, data);
  
  if isfield(tmpvar, cfg.maskparameter) && ~isfield(data, cfg.maskparameter)
    % the mask parameter is not present after ft_selectdata, because it is
    % not included in all input arguments. Make the same selection and copy
    % it over
    tmpvar = ft_selectdata(tmpcfg, tmpvar);
    data.(cfg.maskparameter) = tmpvar.(cfg.maskparameter);
  end
  clear tmpvar tmpcfg hastime hasrpt
  
  % ensure that the preproc specific options are located in the cfg.preproc
  % substructure, but also ensure that the field 'refchannel' remains at the
  % highest level in the structure. This is a little hack by JM because the field
  % refchannel can relate to connectivity or to an EEG reference.
  
  if isfield(cfg, 'refchannel'), refchannelincfg = cfg.refchannel; cfg = rmfield(cfg, 'refchannel'); end
  cfg = ft_checkconfig(cfg, 'createsubcfg',  {'preproc'});
  if exist('refchannelincfg', 'var'), cfg.refchannel  = refchannelincfg; end
  
  if ~isempty(cfg.preproc)
    % preprocess the data, i.e. apply filtering, baselinecorrection, etc.
    fprintf('applying preprocessing options\n');
    if ~isfield(cfg.preproc, 'feedback')
      cfg.preproc.feedback = cfg.interactive;
    end
    data = ft_preprocessing(cfg.preproc, data);
  end
  
  % Apply channel-type specific scaling
  fn = fieldnames(cfg);
  fn = setdiff(fn, {'skipscale', 'showscale', 'gridscale'}); % these are for the layout and plotting, not for CHANSCALE_COMMON
  fn = fn(endsWith(fn, 'scale') | startsWith(fn, 'mychan') | strcmp(fn, 'channel') | strcmp(fn, 'parameter'));
  tmpcfg = keepfields(cfg, fn);
  data = chanscale_common(tmpcfg, data);
  
  %% Section 3: select the data to be plotted and determine min/max range
  
  % Create time-series of small topoplots
  if ~ischar(cfg.xlim) && length(cfg.xlim)>2 %&& any(ismember(dimtok, 'time'))
    % Switch off interactive mode:
    cfg.interactive = 'no';
    xlims = cfg.xlim;
    % Iteratively call topoplotER with different xlim values:
    nplots = numel(xlims)-1;
    nyplot = ceil(sqrt(nplots));
    nxplot = ceil(nplots./nyplot);
    tmpcfg = removefields(cfg, 'inputfile');
    for i=1:length(xlims)-1
      tmpcfg.figure = subplot(nxplot, nyplot, i);
      tmpcfg.xlim = xlims(i:i+1);
      ft_topoplotTFR(tmpcfg, data);
    end
    return
  end
  
  % Get physical min/max range of x
  if ~isempty(xparam)
    if strcmp(cfg.xlim, 'maxmin')
      xmin = min(data.(xparam));
      xmax = max(data.(xparam));
    else
      xmin = cfg.xlim(1);
      xmax = cfg.xlim(2);
    end
    xminindx = nearest(data.(xparam), xmin);
    xmaxindx = nearest(data.(xparam), xmax);
    xmin = data.(xparam)(xminindx);
    xmax = data.(xparam)(xmaxindx);
    selx = xminindx:xmaxindx;
  end
  
  % Get physical min/max range of y
  if ~isempty(yparam)
    if strcmp(cfg.ylim, 'maxmin')
      ymin = min(data.(yparam));
      ymax = max(data.(yparam));
    else
      ymin = cfg.ylim(1);
      ymax = cfg.ylim(2);
    end
    yminindx = nearest(data.(yparam), ymin);
    ymaxindx = nearest(data.(yparam), ymax);
    ymin = data.(yparam)(yminindx);
    ymax = data.(yparam)(ymaxindx);
    sely = yminindx:ymaxindx;
  end
  
  % Take subselection of channels, this only works if the interactive mode is switched off
  if exist('selchannel', 'var')
    sellab = match_str(data.label, selchannel);
    label  = data.label(sellab);
  else
    sellab = 1:numel(data.label);
    label  = data.label;
  end
  
  % Make data vector with one scalar value for each channel
  dat = data.(cfg.parameter);
  % get dimord dimensions
  ydim = find(strcmp(yparam, dimtok));
  xdim = find(strcmp(xparam, dimtok));
  zdim = setdiff(1:ndims(dat), [ydim xdim]);
  % and permute
  dat = permute(dat, [zdim(:)' ydim xdim]);
  
  if ~isempty(yparam)
    % time-frequency data
    dat = dat(sellab, sely, selx);
    dat = nanmean(nanmean(dat, 3), 2);
  elseif ~isempty(cfg.component)
    % component data, nothing to do
  else
    % time or frequency data
    dat = dat(sellab, selx);
    dat = nanmean(dat, 2);
  end
  dat = dat(:);
  
  if isfield(data, cfg.maskparameter)
    % Make mask vector with one value for each channel
    msk = data.(cfg.maskparameter);
    % get dimord dimensions
    ydim = find(strcmp(yparam, dimtok));
    xdim = find(strcmp(xparam, dimtok));
    zdim = setdiff(1:ndims(dat), [ydim xdim]);
    % and permute
    msk = permute(msk, [zdim(:)' ydim xdim]);
    
    if ~isempty(yparam)
      % time-frequency data
      msk = msk(sellab, sely, selx);
    elseif ~isempty(cfg.component)
      % component data, nothing to do
    else
      % time or frequency data
      msk = msk(sellab, selx);
    end
    
    if size(msk,2)>1 || size(msk,3)>1
      ft_warning('no masking possible for average over multiple latencies or frequencies -> cfg.maskparameter cleared')
      msk = [];
    end
    
  else
    msk = [];
  end
  
  % Select the channels in the data that match with the layout:
  [seldat, sellay] = match_str(label, cfg.layout.label);
  if isempty(seldat)
    ft_error('labels in data and labels in layout do not match');
  end
  
  dat = dat(seldat);
  if ~isempty(msk)
    msk = msk(seldat);
  end
  
  % Select x and y coordinates and labels of the channels in the data
  chanX = cfg.layout.pos(sellay,1);
  chanY = cfg.layout.pos(sellay,2);
  
  % Get physical min/max range of z:
  if strcmp(cfg.zlim, 'maxmin')
    zmin = min(dat);
    zmax = max(dat);
  elseif strcmp(cfg.zlim, 'maxabs')
    zmin = -max(max(abs(dat)));
    zmax = max(max(abs(dat)));
  elseif strcmp(cfg.zlim, 'zeromax')
    zmin = 0;
    zmax = max(dat);
  elseif strcmp(cfg.zlim, 'minzero')
    zmin = min(dat);
    zmax = 0;
  else
    zmin = cfg.zlim(1);
    zmax = cfg.zlim(2);
  end
  
  % Construct comment
  switch cfg.comment
    case {'auto' 'auto_nodate'}
      if isequal(cfg.comment, 'auto')
        comment = date;
      else
        comment = '';
      end
      if ~isempty(xparam)
        if xmin==xmax
          comment = sprintf('%0s\n%0s=%.3g', comment, xparam, xmax);
        else
          comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, xparam, xmin, xmax);
        end
      end
      if ~isempty(yparam)
        if ymin==ymax
          comment = sprintf('%0s\n%0s=%.3g', comment, yparam, ymin);
        else
          comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, yparam, ymin, ymax);
        end
      end
      if ~isempty(cfg.parameter)
        comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.parameter, zmin, zmax);
      end
    case 'xlim'
      comment = '';
      if xmin==xmax
        comment = sprintf('%0s\n%0s=%.3g', comment, xparam, xmax);
      else
        comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, xparam, xmin, xmax);
      end
    case 'ylim'
      comment = '';
      if ymin==ymax
        comment = sprintf('%0s\n%0s=%.3g', comment, yparam, ymin);
      else
        comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, yparam, ymin, ymax);
      end
    case 'zlim'
      comment = sprintf('%0s=[%.3g %.3g]', cfg.parameter, zmin, zmax);
    otherwise
      comment = cfg.comment; % allow custom comments (e.g., ft_clusterplot specifies custom comments)
  end % switch comment
  
  if ~isempty(cfg.refchannel)
    if iscell(cfg.refchannel)
      comment = sprintf('%s\nreference=%s %s', comment, cfg.refchannel{:});
    else
      comment = sprintf('%s\nreference=%s %s', comment, cfg.refchannel);
    end
  end
  
  % open a new figure, or add it to the existing one
  open_figure(keepfields(cfg, {'figure', 'position', 'visible', 'renderer', 'figurename', 'title'}));
  
  % apply the same colormap to all figures
  if ~isempty(cfg.colormap)
    set(gcf,  'colormap', cfg.colormap);
  end
  
  % Draw topoplot
  cla
  hold on
  
  % check for nans
  nanInds = isnan(dat);
  if strcmp(cfg.interpolatenan, 'yes') && any(nanInds)
    ft_warning('removing NaNs from the data');
    chanX(nanInds) = [];
    chanY(nanInds) = [];
    dat(nanInds)   = [];
    if ~isempty(msk)
      msk(nanInds) = [];
    end
  elseif strcmp(cfg.interpolatenan, 'no') && any(nanInds)
    if isempty(msk)
      msk = true(size(dat));
    end
    msk(nanInds) = false;
  end
  
  % Set ft_plot_topo specific options
  if strcmp(cfg.interplimits, 'head')
    interplimits = 'mask';
  else
    interplimits = cfg.interplimits;
  end
  if strcmp(cfg.style, 'both');            style = 'surfiso';     end
  if strcmp(cfg.style, 'straight');        style = 'surf';        end
  if strcmp(cfg.style, 'contour');         style = 'iso';         end
  if strcmp(cfg.style, 'fill');            style = 'isofill';     end
  if strcmp(cfg.style, 'straight_imsat');  style = 'imsat';       end
  if strcmp(cfg.style, 'both_imsat');      style = 'imsatiso';    end
  
  % Draw plot
  if strcmp(cfg.style, 'blank')
    ft_plot_layout(cfg.layout, 'box', 'no', 'label', 'no', 'point', 'no')
  else
    opt = {};
    opt = ft_setopt(opt, 'interpmethod',  cfg.interpolation);
    opt = ft_setopt(opt, 'interplim',     interplimits);
    opt = ft_setopt(opt, 'gridscale',     cfg.gridscale);
    opt = ft_setopt(opt, 'outline',       cfg.layout.outline);
    opt = ft_setopt(opt, 'shading',       cfg.shading);
    opt = ft_setopt(opt, 'isolines',      cfg.contournum);
    opt = ft_setopt(opt, 'mask',          cfg.layout.mask);
    opt = ft_setopt(opt, 'style',         style);
    opt = ft_setopt(opt, 'datmask',       msk);
    if strcmp(style, 'imsat') || strcmp(style, 'imsatiso')
      opt = ft_setopt(opt, 'clim',  [zmin zmax]);
    end
    ft_plot_topo(chanX, chanY, dat, opt{:});
  end
  
  % For Highlight (channel-selection)
  for icell = 1:length(cfg.highlight)
    if ~strcmp(cfg.highlight{icell}, 'off')
      cfg.highlightchannel{icell} = ft_channelselection(cfg.highlightchannel{icell}, data.label);
      [dum, layoutindex] = match_str(cfg.highlightchannel{icell}, cfg.layout.label);
      templay = [];
      templay.outline = cfg.layout.outline;
      templay.mask    = cfg.layout.mask;
      templay.pos     = cfg.layout.pos(layoutindex,:);
      templay.width   = cfg.layout.width(layoutindex);
      templay.height  = cfg.layout.height(layoutindex);
      templay.label   = cfg.layout.label(layoutindex);
      if strcmp(cfg.highlight{icell}, 'labels') || strcmp(cfg.highlight{icell}, 'numbers')
        labelflg = 1;
      else
        labelflg = 0;
      end
      if strcmp(cfg.highlight{icell}, 'numbers')
        for ichan = 1:length(layoutindex)
          templay.label{ichan} = num2str(match_str(data.label, templay.label{ichan}));
        end
      end
      
      ft_plot_layout(templay, 'box', 'no', 'label', labelflg, 'point', ~labelflg, ...
        'pointsymbol',  cfg.highlightsymbol{icell}, ...
        'pointcolor',   cfg.highlightcolor{icell}, ...
        'pointsize',    cfg.highlightsize{icell}, ...
        'fontsize',     cfg.highlightfontsize{icell}, ...
        'labeloffset',  cfg.labeloffset, ...
        'labelalignh', 'center', ...
        'labelalignv', 'middle');
    end
  end % for icell
  
  % For Markers (all channels)
  switch cfg.marker
    case {'off', 'no'}
      % do not show the markers
    case {'on', 'labels', 'numbers'}
      channelsToMark = 1:length(data.label);
      channelsToHighlight = [];
      for icell = 1:length(cfg.highlight)
        if ~strcmp(cfg.highlight{icell}, 'off')
          channelsToHighlight = [channelsToHighlight; match_str(data.label, cfg.highlightchannel{icell})];
        end
      end
      if strcmp(cfg.interpolatenan, 'no')
        channelsNotMark = channelsToHighlight;
      else
        channelsNotMark = union(find(isnan(dat)), channelsToHighlight);
      end
      channelsToMark(channelsNotMark) = [];
      [dum, layoutindex] = match_str(ft_channelselection(channelsToMark, data.label), cfg.layout.label);
      templay = [];
      templay.outline = cfg.layout.outline;
      templay.mask    = cfg.layout.mask;
      templay.pos     = cfg.layout.pos(layoutindex,:);
      templay.width   = cfg.layout.width(layoutindex);
      templay.height  = cfg.layout.height(layoutindex);
      templay.label   = cfg.layout.label(layoutindex);
      if strcmp(cfg.marker, 'labels') || strcmp(cfg.marker, 'numbers')
        labelflg = 1;
      else
        labelflg = 0;
      end
      if strcmp(cfg.marker, 'numbers')
        for ichan = 1:length(layoutindex)
          templay.label{ichan} = num2str(match_str(data.label,templay.label{ichan}));
        end
      end
      ft_plot_layout(templay, 'box', 'no', 'label', labelflg, 'point', ~labelflg, ...
        'pointsymbol',  cfg.markersymbol, ...
        'pointcolor',   cfg.markercolor, ...
        'pointsize',    cfg.markersize, ...
        'fontsize',     cfg.markerfontsize, ...
        'labeloffset',  cfg.labeloffset, ...
        'labelalignh', 'center', ...
        'labelalignv', 'middle');
    otherwise
      ft_error('incorrect value for cfg.marker');
  end
  
  if isfield(cfg, 'vector')
    % FIXME this is not documented
    vecX = nanmean(real(data.(cfg.vector)(:,selx)), 2);
    vecY = nanmean(imag(data.(cfg.vector)(:,selx)), 2);
    
    % scale quiver relative to largest gradiometer sample
    k = 0.15/max([max(abs(real(data.(cfg.vector)(:)))) max(abs(imag(data.(cfg.vector)(:))))]);
    quiver(chanX, chanY, k*vecX, k*vecY, 0, 'red');
  end
  
  % Write comment
  if strcmp(cfg.comment, 'no')
    comment_handle = [];
  elseif strcmp(cfg.commentpos, 'title')
    comment_handle = title(comment, 'FontSize', cfg.fontsize);
  elseif ~isempty(strcmp(cfg.layout.label, 'COMNT'))
    x_comment = cfg.layout.pos(strcmp(cfg.layout.label, 'COMNT'), 1);
    y_comment = cfg.layout.pos(strcmp(cfg.layout.label, 'COMNT'), 2);
    % 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom',
    comment_handle = ft_plot_text(x_comment, y_comment, comment, 'FontSize', cfg.fontsize, 'FontWeight', cfg.fontweight);
  else
    comment_handle = [];
  end
  
  % Set colour axis
  if ~strcmp(cfg.style, 'blank')
    if zmin==zmax
      clim([zmin-eps zmax+eps]);
    else
      clim([zmin zmax]);
    end
  end
  
  % Plot colorbar
  if isfield(cfg, 'colorbar')
    if strcmp(cfg.colorbar, 'yes')
      c = colorbar;
      ylabel(c, cfg.colorbartext);
    elseif ~strcmp(cfg.colorbar, 'no')
      c = colorbar('location', cfg.colorbar);
      ylabel(c, cfg.colorbartext);
    end
  end
  
  % set the figure window title, but only if the user has not changed it
  if isempty(get(gcf, 'Name'))
    if isfield(cfg, 'funcname')
      funcname = cfg.funcname;
    else
      funcname = mfilename;
    end
    if isempty(cfg.figurename)
      dataname_str = join_str(', ', dataname);
      set(gcf, 'Name', sprintf('%d: %s: %s', double(gcf), funcname, dataname_str));
      set(gcf, 'NumberTitle', 'off');
    else
      set(gcf, 'name', cfg.figurename);
      set(gcf, 'NumberTitle', 'off');
    end
  end
  
  axis off
  hold off
  axis equal
  
  if strcmp('yes', cfg.hotkeys)
    %  Attach data and cfg to figure and attach a key listener to the figure
    set(gcf, 'KeyPressFcn', {@key_sub, zmin, zmax})
  end
  
  % add the cfg/data/channel information to the figure under identifier linked to this axis,
  % this is now also needed in non-interactive mode for the post-hoc clim management
  ident                    = ['axh' num2str(round(sum(clock.*1e6)))]; % unique identifier for this axis
  set(gca, 'tag',ident);
     
  info                     = guidata(gcf);
  info.(ident).x           = cfg.layout.pos(:, 1);
  info.(ident).y           = cfg.layout.pos(:, 2);
  info.(ident).label       = cfg.layout.label;
  info.(ident).dataname    = dataname;
  info.(ident).cfg         = cfg;
  info.(ident).commenth    = comment_handle;
  if exist('linecolor', 'var')
    info.(ident).linecolor   = linecolor;
  end
  if ~isfield(info.(ident),'datvarargin')
    info.(ident).datvarargin = varargin(1:Ndata); % add all datasets to figure
  end

  info.(ident).datvarargin{indx} = data; % update current dataset (e.g. baselined, channel selection, etc)
  guidata(gcf, info);

  % Make the figure interactive
  if strcmp(cfg.interactive, 'yes')
    % ensure that the function that is called knows about the subplot setting
    if makesubplots
      cfg.subplottopo = 1;
    else
      cfg.subplottopo = 0;
    end
    info.(ident).cfg         = cfg; % update cfg and add updated info to figure
    guidata(gcf, info);

    if any(strcmp(dimord, {'chan_time', 'chan_freq', 'subj_chan_time', 'rpt_chan_time', 'chan_chan_freq', 'chancmb_freq', 'rpt_chancmb_freq', 'subj_chancmb_freq'}))
      set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonUpFcn'});
      set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonDownFcn'});
      set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonMotionFcn'});
    elseif any(strcmp(dimord, {'chan_freq_time', 'subj_chan_freq_time', 'rpt_chan_freq_time', 'rpttap_chan_freq_time', 'chan_chan_freq_time', 'chancmb_freq_time', 'rpt_chancmb_freq_time', 'subj_chancmb_freq_time'}))
      set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonUpFcn'});
      set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonDownFcn'});
      set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonMotionFcn'});
    else
      ft_warning('unsupported dimord "%s" for interactive plotting', dimord);
    end
  end
  
end % for numel(varargin)

if Ndata>1 && ~isequal(cfg.figure, 'yes')
  % lock the clim
  clims = zeros(Ndata,2);
  axh  = fieldnames(info);
  for i=1:Ndata
    clims(i,:) = get(info.(axh{i}).cfg.figure, 'CLim');
  end
  c = [min(clims(:,1)) max(clims(:,2))];
  for i=1:Ndata
    set(info.(axh{i}).cfg.figure, 'CLim', c);
    if isfield(info.(axh{i}), 'commenth') && ~isempty(info.(axh{i}).commenth)
      commentstr = get(info.(axh{i}).commenth, 'string');
      sel        = contains(commentstr, info.(axh{i}).cfg.parameter);
      if any(sel)
        commentstr{sel} = sprintf('%0s=[%.3g %.3g]', info.(axh{i}).cfg.parameter, c(1), c(2));
        set(info.(axh{i}).commenth, 'string', commentstr);
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotER(label)
ident       = get(gca, 'tag');
info        = guidata(gcf);
cfg         = info.(ident).cfg;
datvarargin = info.(ident).datvarargin;
linecolor   = ft_getopt(info.(ident), 'linecolor', lineattributes_common(cfg, datvarargin{:}));

if ~isempty(label)
  cfg = removefields(cfg, 'inputfile');       % the reading has already been done and varargin contains the data
  cfg.baseline = 'no';                        % make sure the next function does not apply a baseline correction again
  cfg.channel = label;
  cfg.dataname = info.(ident).cfg.dataname;   % put data name in here, this cannot be resolved by other means
  cfg.trials = 'all';                         % trial selection has already been taken care of
  cfg.xlim = 'maxmin';
  % if user specified a zlim, copy it over to the ylim of singleplot
  if isfield(cfg, 'zlim')
    cfg.ylim = cfg.zlim;
    cfg = rmfield(cfg, 'zlim');
  end
  fprintf('selected cfg.channel = {%s}\n', join_str(', ', cfg.channel));
  % ensure that the new figure appears at the same position, and also that 
  cfg.figure = 'yes';
  cfg.position = get(gcf, 'Position');
  
  selchan = match_str(datvarargin{1}.label, cfg.channel);
  cfg.linecolor = linecolor(selchan, :, :); % make a subselection for the correct inheritance of the line colors
  ft_singleplotER(cfg, datvarargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotTFR(label)
ident       = get(gca, 'tag');
info        = guidata(gcf);
cfg         = info.(ident).cfg;
datvarargin = info.(ident).datvarargin;
if ~isempty(label)
  cfg = removefields(cfg, 'inputfile');   % the reading has already been done and varargin contains the data
  cfg.baseline = 'no';                    % make sure the next function does not apply a baseline correction again
  cfg.channel = label;
  cfg.dataname = info.(ident).dataname;   % put data name in here, this cannot be resolved by other means
  cfg.trials = 'all';                     % trial selection has already been taken care of
  cfg.xlim = 'maxmin';
  cfg.ylim = 'maxmin';
  fprintf('selected cfg.channel = {%s}\n', join_str(', ', cfg.channel));
  % ensure that the new figure appears at the same position
  cfg.position = get(gcf, 'Position');
  if isfield(cfg, 'subplottopo') && istrue(cfg.subplottopo)
    figure('position', cfg.position);
    cfg.figure = 'subplot';
  else
    cfg.figure = 'yes';
  end
  ft_singleplotTFR(cfg, datvarargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which handles hot keys in the current plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key_sub(handle, eventdata, varargin)
ident       = get(gca, 'tag');
info        = guidata(gcf);

climits = clim;
incr_c  = abs(climits(2) - climits(1)) /10;

newz = climits;
if length(eventdata.Modifier) == 1 && strcmp(eventdata.Modifier{:}, 'control')
  % TRANSLATE by 10%
  switch eventdata.Key
    case 'pageup'
      newz = [climits(1)+incr_c climits(2)+incr_c];
    case 'pagedown'
      newz = [climits(1)-incr_c climits(2)-incr_c];
  end % switch
else
  % ZOOM by 10%
  switch eventdata.Key
    case 'pageup'
      newz = [climits(1)-incr_c climits(2)+incr_c];
    case 'pagedown'
      newz = [climits(1)+incr_c climits(2)-incr_c];
    case 'm'
      newz = [varargin{1} varargin{2}];
  end % switch
end % if

% update the color axis
clim(newz);

if ~isempty(ident) && isfield(info.(ident), 'commenth') && ~isempty(info.(ident).commenth)
  commentstr = get(info.(ident).commenth, 'string');
  sel        = contains(commentstr, info.(ident).cfg.parameter);
  if any(sel)
    commentstr{sel} = sprintf('%0s=[%.3g %.3g]', info.(ident).cfg.parameter, newz(1), newz(2));
    set(info.(ident).commenth, 'string', commentstr);
  end
end

function data = select_component(data, indx)

% Add a pseudo-axis with the component numbers
data.comp = 1:size(data.topo,2);

% make a selection of components
data.comp  = data.comp(indx);
data.topo  = data.topo(:,indx);
data.label = data.topolabel;
data.topodimord = 'chan_comp';
data = removefields(data, {'topolabel', 'unmixing', 'unmixingdimord'}); % not needed any more
