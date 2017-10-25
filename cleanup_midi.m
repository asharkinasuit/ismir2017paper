% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function midstruct = cleanup_midi(mids)
% cleans up a midi by removing empty tracks and other unnecessary things
% (e.g. noteOff events with no matching noteOn event)
midistruct = mids;
% first take out orphaned Note_off events
for i = 1:mids.ntracks
    notes = false(1,128);
    x = 1;
    while true
        r = midistruct.tracks{i}(x);
        if r.event == MidiMsg.note_on_c
            notes(r.parameters(2)+1) = true;
        end
        if r.event == MidiMsg.note_off_c
            if notes(r.parameters(2)+1)
                notes(r.parameters(2)+1) = false;
            else
                midistruct.tracks{i}(x) = [];
                continue;
            end
        end
        if r.event == MidiMsg.end_track
            break;
        end
        x = x + 1;
    end
end
% then empty tracks
n = mids.ntracks;
midstruct = midistruct;
for i = 1:midistruct.ntracks
    if midistruct.tracks{i}(2).event == MidiMsg.end_track
        midstruct.tracks(i-(mids.ntracks-n)) = [];
        n = n - 1;
    end
end
midstruct.ntracks = n;