function [freq] = ft_appendfreq(cfg, varargin)

% FT_APPENDFREQ concatenates multiple frequency or time-frequency data structures
% that have been processed separately. If the input data structures contain different
% channels, it will be concatenated along the channel direction. If the channels are
% identical in the input data structures, the data will be concatenated along the
% repetition dimension.
%
% Use as
%  combined = ft_appendfreq(cfg, freq1, freq2, ...)
%
% The configuration should contain
%   cfg.parameter  = string, the name of the field to concatenate
%
% The configuration can optionally contain
%   cfg.appenddim  = string, the dimension to concatenate over (default is automatic)
%   cfg.tolerance  = scalar, tolerance to determine how different the frequency and/or
%                    time axes are allowed to still be considered compatible (default = 1e-5)
%
% To facilitate data-handling and distributed computing you can use
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a
% *.mat file on disk and/or the output data will be written to a *.mat file.
% These mat files should contain only a single variable, corresponding with
% the input/output structure.
%
% If you encounter difficulties with memory usage, you can use
%   cfg.memory = 'low' or 'high', whether to be memory or computationally efficient, respectively (default = 'high')
%
% See also FT_FREQANALYSIS, FT_DATATYPE_FREQ, FT_APPENDDATA, FT_APPENDTIMELOCK,
% FT_APPENDSENS

% Copyright (C) 2011-2017, Robert Oostenveld
% Copyright (C) 2018-, Jan-Mathijs Schoffelen and Robert Oostenveld
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

% these are used by the ft_preamble/ft_postamble function and scripts
ft_revision = '$Id$';
ft_nargin   = nargin;
ft_nargout  = nargout;

% do the general setup of the function
ft_defaults
ft_preamble init
ft_preamble debug
ft_preamble loadvar    varargin
ft_preamble provenance varargin

% the ft_abort variable is set to true or false in ft_preamble_init
if ft_abort
  return
end

% check if the input data is valid for this function
for i=1:length(varargin)
  varargin{i} = ft_checkdata(varargin{i}, 'datatype', {'freq+comp', 'freq'}, 'feedback', 'yes');
end

% set the defaults
cfg.channel    = ft_getopt(cfg, 'channel', 'all');
cfg.channelcmb = ft_getopt(cfg, 'channelcmb', {'all' 'all'});
cfg.parameter  = ft_getopt(cfg, 'parameter', []);
cfg.appenddim  = ft_getopt(cfg, 'appenddim', []);
cfg.tolerance  = ft_getopt(cfg, 'tolerance',  1e-5); % this is passed to append_common, which passes it to ft_selectdata
cfg.appendsens = ft_getopt(cfg, 'appendsens', 'no');
cfg.memory     = ft_getopt(cfg, 'memory', 'high');

hastime = isfield(varargin{1}, 'time');
hasfreq = isfield(varargin{1}, 'freq');

if isempty(cfg.appenddim) || strcmp(cfg.appenddim, 'auto')
  if hastime && hasfreq
    if checkchan(varargin{:}, 'identical') && checkfreq(varargin{:}, 'identical', cfg.tolerance) && checktime(varargin{:}, 'identical', cfg.tolerance)
      cfg.appenddim = 'rpt';
    elseif checkfreq(varargin{:}, 'unique', cfg.tolerance) && checktime(varargin{:}, 'identical', cfg.tolerance)
      cfg.appenddim = 'freq';
    elseif checktime(varargin{:}, 'unique', cfg.tolerance) && checkfreq(varargin{:}, 'identical', cfg.tolerance)
      cfg.appenddim = 'time';
    elseif checkchan(varargin{:}, 'unique')
      cfg.appenddim = 'chan';
    else
      ft_error('cfg.appenddim should be specified');
    end
  else
    if checkchan(varargin{:}, 'identical') && checkfreq(varargin{:}, 'identical', cfg.tolerance)
      cfg.appenddim = 'rpt';
    elseif checkfreq(varargin{:}, 'unique', cfg.tolerance)
      cfg.appenddim = 'freq';
    elseif checkchan(varargin{:}, 'unique')
      cfg.appenddim = 'chan';
    else
      ft_error('cfg.appenddim should be specified');
    end
  end
end
ft_info('concatenating over the "%s" dimension\n', cfg.appenddim);

if isempty(cfg.parameter)
  fn = fieldnames(varargin{1});
  for i=2:numel(varargin)
    fn = intersect(fn, fieldnames(varargin{i}));
  end
  cfg.parameter = setdiff(fn, ignorefields('appendfreq'));
elseif ischar(cfg.parameter)
  cfg.parameter = {cfg.parameter};
end
assert(~isempty(cfg.parameter), 'cfg.parameter should be specified');

% use a low-level function that is shared with the other ft_appendxxx functions
if strcmp(cfg.memory, 'high') || numel(varargin)<=2
  freq = append_common(cfg, varargin{:});
elseif strcmp(cfg.memory, 'low')
  freq = varargin{1};
  for i=2:numel(varargin)
    freq = append_common(cfg, freq, varargin{i});
  end
end

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble previous   varargin
ft_postamble provenance freq
ft_postamble history    freq
ft_postamble savevar    freq
