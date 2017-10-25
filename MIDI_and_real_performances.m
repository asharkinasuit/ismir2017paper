%% Analysis based on MIDI and actual audio examples
% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

% assumptions:
% - MIRtoolbox version 1.6.1 is available on the MATLAB path
% - folder RECORDING_FOLDER contains *.wav recordings of multiple performances
%   of the same piece
% - for this piece, a *.mid file also is available. For the Mazurka data,
%   we used MIDIs included in the Mazurka data set, see http://mazurka.org.uk/

%% Read the MIDI

% One way to read MIDI information into MATLAB is through an intermediate
% library that enables conversion to and from a specially formatted CSV file;
% in our case, we used MIDICSV 1.1 by John Walker (http://www.fourmilab.ch/).
% We include some files that enable the reading and writing of CSV files that
% this tool can use. To read a given CSV:
midi_struct = read_midicsv(CSV);

% Once the MIDI file has been read, it can be modified, for instance using our
% analysis:

%% Computing chroma features for each of the performance recordings

% First, build the cell array of chroma data; each cell contains a 12 x m matrix
% with the chroma vectors (assuming we use chroma vectors of length 12). We used
% windows of 200 ms, which convention we maintain here. (This can be changed via
% the 'Frame' parameter, see the MIRtoolbox documentation for details.)

wave_files = dir([RECORDING_FOLDER '/*.wav']);
n = length(wave_files); % the number of recordings found
chroma = cell(1,n);
for i = 1:n
    chroma{i} = mirgetdata(mirchromagram(wave_files(i).name,'Frame',0.2,'s',1,'/1'));
end

%% Calculating warping paths and averages

% For the purposes of applying a warping path to the MIDI file loaded above, we
% need the derivative of the average warping path (the warping path itself won't
% do because we need to apply _differences_ in tempo to the existing tempo).
% This can be done simply via the following call:
p = avgdpath(chroma,false);
% The second argument indicates whether to warp all recordings to all, but this
% empirically results in a very small derivative that would result in minimally
% noticeable changes to the tempo, so we stick with warping to the last 
% recording (which is the default, as the MIDI rendition was stored in the last
% cell by convention).

%% If desired, one can compute a PCA as well using the following call, although
% we do not at this time support applying it to a given MIDI:
eigenvectors = paths_pca(chroma,derivative);
% derivative is a boolean indicating whether to take the PCA over the paths or
% over their derivative

%% Apply the path and write the modified CSV

% Once the paths have been computed, the CSV can be modified and written to a
% file to be converted back to MIDI by MIDICSV:
tempo_track = path_to_tempo(midi_struct,p);
midstruct = update_tempo(midi_struct,tempo_track);
midstruct = cleanup_midi(midi_struct);
write_midicsv(CSV_MODIFIED);

% We used TiMidity v. 2.13.0 to render the resulting MIDI file(s) as WAV file(s)