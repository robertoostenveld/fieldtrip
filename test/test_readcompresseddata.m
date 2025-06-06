function test_readcompresseddata

% MEM 2gb
% WALLTIME 00:10:00
% DEPENDENCY inflate_file ft_read_data ft_read_header test_readcompresseddata
% DATA private

% test these data sets
datasets = {
  dccnpath('/project/3031000.02/test/original/meg/ctf151/Subject01.ds.zip')
  dccnpath('/project/3031000.02/test/original/eeg/brainvision/MischaCompressed.zip')
};

for k = 1:numel(datasets)
  cfg = [];
  cfg.continuous = 'yes';
  cfg.dataset = datasets{k};
  data = ft_preprocessing(cfg);
end

% and this mri
mri = ft_read_mri(dccnpath('/project/3031000.02/test/latest/mri/dicom/dicomzipped.zip'));

end
