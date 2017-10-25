% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function tempo = path_to_tempo(midistruct,path,basetempo)
% tempo = path_to_tempo(midistruct,path,basetempo)
%   create a tempo track for the given midi_struct that incorporates the
%   information in the given warping path; path must be in differentiated
%   form; a base tempo may be given, which will be assumed as the constant
%   tempo baseline to be modified by the path (use the midi value tempo =
%   60,000,000/bpm)
%   also, the track number will be assumed to be one higher than the
%   current number of tracks in the structure
n = length(path);
tmax = maxtime(midistruct);
step = tmax/n;
tempo = struct('track',cell(1,n+2),'time',cell(1,n+2),'event',cell(1,n+2),'parameters',cell(1,n+2));
x = 0;
if nargin < 3
    basetempo = 1000000; % default to 60 bpm
end
tempo(1).track = midistruct.ntracks+1;
tempo(1).time = 0;
tempo(1).event = 'Start_track';
[oldtempo,cnt,uniform] = get_tempo(midistruct);
if ~uniform
    warning('Existing midi has tempo events in multiple tracks, this may give undesired results.');
end
if cnt > 0
    % technically should add new tempo event also to modify old ones, with
    % interpolated path value, but path is usually dense enough that the
    % current implementation should do
    y = 1;
    if oldtempo(y).time == 0
        currentTempo = oldtempo(y).parameters;
    else
        currentTempo = basetempo;
    end
    for i = 1:n
        tempo(i+1).track = midistruct.ntracks+1;
        tempo(i+1).time = round(x);
        tempo(i+1).event = 'Tempo';
        tempo(i+1).parameters = round(currentTempo*path(i));
        x = x + step;
        if y + 1 < length(oldtempo) && oldtempo(y + 1).time < x
            y = y + 1;
            currentTempo = oldtempo(y).parameters;
        end
    end
else
    for i = 1:n
        tempo(i+1).track = midistruct.ntracks+1;
        tempo(i+1).time = round(x);
        tempo(i+1).event = 'Tempo';
        tempo(i+1).parameters = round(basetempo*path(i));
        x = x + step;
    end
end
tempo(end).track = midistruct.ntracks+1;
tempo(end).time = round(x-step);
tempo(end).event = 'End_track';

function maxtime = maxtime(midistruct)
maxtime = 0;
for i = 1:midistruct.ntracks
    maxtime = max(maxtime,midistruct.tracks{i}(end).time);
end

function [tempo_events,evtcnt,uniform] = get_tempo(midistruct)
tempo_events = struct('track',{},'time',{},'event','Tempo','parameters',{});
evtcnt = 0;
tempo_in_track = zeros(1,midistruct.ntracks);
for i = 1:midistruct.ntracks
    for j = 1:length(midistruct.tracks{i})
        if midistruct.tracks{i}(j).event == MidiMsg.tempo
            evtcnt = evtcnt + 1;
            tempo_events(evtcnt) = midistruct.tracks{i}(j);
            tempo_in_track(i) = 1;
        end
    end
end
uniform = sum(tempo_in_track) <= 1;