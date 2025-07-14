function vars = oep2mat(path, details, savepath, savefilename, savefile)
%OEP2MAT Transform OpenEphys directory to .mat files, in the .otb+ format.
%   Load files within OpenEphys directory and save each recording into a
%   different .mat file following the .otb+ format.
%
%   Only continuous data is stored.
%
%
%   :param path: char, path to folder in which files are stored.
%   :param details: string, containing metadata for each channel (optional).
%   :param savepath: char, path to folder in which files will be stored (if
%   empty, same as path).
%   :param savefilename: char, name of resulting .mat file (if empty, save 
%   as filename). Filename will be followed by '_recording0_oep.mat'.
%   :param savefile: boolean, = 1 save .mat, = 0 return vars without saving.
%
%   :return: structure, with substrucutures corresponding to each recording,
%   each containing the variables following .otb+ format.
%
%   :usage: oep2mat('C:\Users\myuser\mydir', [], [], [], 1)
%   :version: MATLAB R2025a
%
% Created by Blanca Delgado (bdelgado@unizar.es)
% June 2025, last edit: 2025-06-26

%addpath(genpath('C:\Users\usuario\Documents\Open Ephys\open-ephys-matlab-tools-main'))
addpath(genpath('C:\Users\usuario\OneDrive - unizar.es\Work\Code\Processing\open-ephys-matlab-tools\open_ephys'))

if isempty(savepath), savepath = path; end
if isempty(savefilename), [~, savefilename,~] = fileparts(path); 
end

session = Session(path);
node = session.recordNodes{1};

vars = struct;
for r = 1:length(node.recordings)
    recording = node.recordings{1,r};
    
    streamNames = recording.ttlEvents.keys();
    streamName = streamNames{1};
    
    %events = recording.ttlEvents(streamName);
    data = recording.continuous(streamName);

    vari.Data = double(data.samples)';
    vari.SamplingFrequency = data.metadata.sampleRate;
    vari.Details = details;

    vari.OEDirectory = session.directory;
    vari.OEExperiment = recording.experimentIndex;
    vari.OERecording = recording.recordingIndex;

    vars.('recording'+string(r)) = vari;

    if savefile
        fprintf('Saving data: %s channels\n', string(size(data, 2)))
        name = savefilename + "_recording"+string(r) + "_oep.mat";
        save(fullfile(savepath, name), '-struct', 'vari', '-v7.3')
    end
      
end
end