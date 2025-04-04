function test_issue2044

% WALLTIME 00:10:00
% DATA private
% MEM 1gb

%%

filename = {
  dccnpath('/project/3031000.02/test/original/meg/yokogawa64/2011_01_28_0354_ME053_AEF.con')
  dccnpath('/project/3031000.02/test/original/meg/yokogawa160/Continuous1.con')
  dccnpath('/project/3031000.02/test/original/meg/yokogawa208/03AS_01.con')
  dccnpath('/project/3031000.02/test/original/meg/yokogawa440/S1_MEG_Epoch.raw')
  };

%%

for i=1:4
  filetype{i} = ft_filetype(filename{i});
  hdr{i}      = ft_read_header(filename{i});
  grad{i}     = ft_read_sens(filename{i});
  senstype{i} = ft_senstype(rmfield(grad{i}, 'type'));
end

assert(isequal(senstype, {'yokogawa64', 'yokogawa160', 'yokogawa208', 'yokogawa440'}))
