function test_ft_read_sens(datainfo, writeflag, version)

% MEM 1gb
% WALLTIME 00:20:00
% DEPENDENCY ft_read_sens
% DATA private

% writeflag determines whether the output should be saved to disk
% version determines the output directory

if nargin<1
  datainfo = ref_datasets;
end
if nargin<2
  writeflag = 0;
end
if nargin<3
  version = 'latest';
end

[ftver, ftpath] = ft_version;
addpath([ftpath '/test']);

% make a subselection of the MEG datasets
use      = match_str({datainfo.datatype}, {'bti148' 'bti248' 'bti248grad' 'ctf151' 'ctf275' 'itab153' 'neuromag122' 'neuromag306'});
datainfo = datainfo(use);

for k = 1:numel(datainfo)
  dataset  = datainfo(k);
  filename = fullfile(dataset.origdir, 'original', dataset.type, dataset.datatype, dataset.filename);
  
  % get sensor information
  if ~isempty(dataset.dataformat)
    sens = ft_read_sens(filename, 'headerformat', dataset.dataformat);
  else
    sens = ft_read_sens(filename);
  end
  
  if writeflag
    outputfile = fullfile(dataset.origdir,version,'sens',[dataset.senstype, '.mat']);
    save(outputfile, 'sens');
  end
  
end % for

% read all the electrode files
d = dir(dccnpath('/project/3031000.02/test/original/electrodes/'));
for i=1:numel(d)
  if d(i).isdir && numel(d(i).name)>1
    f = dir(fullfile(d(i).folder, d(i).name));
    f = f(~[f.isdir]);
    f = f(~startsWith({f.name}, '.')); % exclude files like .DS_Store
    for j=1:numel(f)
      elec = ft_read_sens(fullfile(f(j).folder, f(j).name));
    end
  end
end
