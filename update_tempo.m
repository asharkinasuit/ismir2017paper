% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function resstruct = update_tempo(midstruct,tempo)
% updates the tempo of a given midi by removing the old tempo instructions
% (track) and replacing it with the given tempo track
resstruct = midstruct;
%remove all tempo instructions from the original
for i = 1:resstruct.ntracks
    x = 1;
    while true
        r = resstruct.tracks{i}(x);
        if r.event == MidiMsg.tempo
            resstruct.tracks{i}(x) = [];
            continue;
        end
        if r.event == MidiMsg.end_track
            break;
        end
        x = x + 1;
    end
end
% remove possibly empty tempo track
resstruct = cleanup_midi(resstruct);
% keep tempo track as first track, some programs prefer this
resstruct.ntracks = resstruct.ntracks + 1;
for i = resstruct.ntracks:-1:2
    resstruct.tracks{i} = resstruct.tracks{i-1};
    for j = 1:length(resstruct.tracks{i})
        resstruct.tracks{i}(j).track = i;
    end
end
resstruct.tracks{1} = tempo;
for j = 1:length(resstruct.tracks{1})
    resstruct.tracks{1}(j).track = 1;
end