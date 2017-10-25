% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function midistruct = read_midicsv(filename)
% midistruct = readmidicsv(filename): read a file containing MIDI data in
%   midicsv format into a struct with the following format:
%  {format: integer specifying the midi format
%   ntracks: the number of tracks
%   division: #clock pulses per quarter note
%   tracks: cell array with ntracks tracks, each a struct of:
%   { track: track number
%     time: time index (in clock ticks)
%     event: event identifier
%     parameters: an array of integer parameter values or a string (for
%     some meta-events)
%   }
%  }
%  all events are included, also pure file structure like Start_track etc

f = fopen(filename);
l = fgetl(f);
if l ~= -1
    [fmt,ntracks,div] = getheader(l);
    tracks = cell(1,ntracks);
    midistruct = struct('format',fmt,'ntracks',ntracks,'division',div,'tracks',0);
else
    error('Empty file.');
end

x = 2; % line count for error reporting
while l ~= -1
    l = fgetl(f);
    x = x + 1;
    [track,time,evt,pars] = getrecord(l,x);
    if track == 0
        if evt ~= MidiMsg.end_of_file
            error('On line %u: track 0 is reserved for Header and End_of_file events, but found %s event',x,evt);
        else
            break;
        end
    else
        tracks{track}(end+1) = struct('track',track,'time',time,'event',evt,'parameters',pars);
    end
end

midistruct.tracks = tracks;

fclose(f);

function [fmt,ntracks,div] = getheader(l)
tokens = regexpi(l,'^0,\s*0,\s*Header,\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
if length(tokens) ~= 1
    error('Invalid header. Remember the first line must be the header.');
else
    fmt = str2double(tokens{1}{1});
    ntracks = str2double(tokens{1}{2});
    div = str2double(tokens{1}{3});
end

function [track,time,event,parameters] = getrecord(l,x)
tokens = regexpi(l,'^(\d+),\s*(\d+),\s*(\w+)(|,.+)$','tokens');
tokens = tokens{1};
event_type = MidiMsg(tokens{3}); %MidiMsg(lower(tokens{3}));
event = tokens{3};
track = str2double(tokens{1});
time = str2double(tokens{2});
parameters = [];
switch(event_type)
    case MidiMsg.end_of_file
        track = 0;
        time = 0;
        parameters = [];
    case MidiMsg.start_track
        if time ~= 0
            warning('On line %u: time is supposed to be 0 for Start_track events.',x);
        end
    %case MidiMsg.end_track
        %nop
    case {MidiMsg.title_t MidiMsg.copyright_t MidiMsg.instrument_name_t MidiMsg.marker_t MidiMsg.cue_point_t MidiMsg.lyric_t MidiMsg.text_t}
        event = tokens{3};
        txt = regexpi(tokens{4},',\s*"(.*)"$','tokens');
        parameters = txt{1}{1};
    case MidiMsg.sequence_number
        if time ~= 0
            warning('On line %u: sequence number should appear at the start of the track. Ignoring time (fingers crossed)...',x);
            time = 0;
        end
        toks = regexpi(tokens{4},'^,\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Sequence_number event',x);
        end
        parameters = str2double(toks{1}{1});
        if exceeds(parameters,0,65535)
            error('On line %u: Sequence_number must be between 0 and 65535',x);
        end
    case MidiMsg.midi_port
        toks = regexpi(tokens{4},'^,\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for MIDI_port event',x);
        end
        parameters = str2double(toks{1}{1});
        if exceeds(parameters,0,255)
            error('On line %u: MIDI_port must be between 0 and 255',x);
        end
    case MidiMsg.channel_prefix
        toks = regexpi(tokens{4},'^,\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Channel_prefix event',x);
        end
        parameters = str2double(toks{1}{1});
        checkCh(parameters,x);
    case MidiMsg.time_signature
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Time_signature event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        if any(parameters < 0) || any(parameters > 255)
            error('On line %u: Time_signature parameter(s) must be between 0 and 255',x);
        end
        if parameters(2) > 7
            warning('On line %u: are you sure the time signature is correctly formatted? Denominator > 2^7 is unheard of.',x);
        end
    case MidiMsg.key_signature
        toks = regexpi(tokens{4},'^,\s*([-0-9]+),\s*(''major''|''minor''|"major"|"minor")$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized Key_signature parameter(s)',x);
        end
        accs = str2double(toks{1}{1});
        if abs(accs) > 7
            error('On line %u: Key_signature accidental count must be between -7 and 7 inclusive',x);
        end
        parameters = [accs contains(toks{1}{2},'minor')];
    case MidiMsg.tempo
        toks = regexpi(tokens{4},'^,\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Tempo event',x);
        end
        parameters = str2double(toks{1}{1});
        if exceeds(parameters,1,16777215)
            error('On line %u: Tempo event''s parameter must be between 1 and 16777215',x);
        end
    case MidiMsg.smpte_offset % could add some more checks on parameters
        if time ~= 0
            warning('On line %u: time must be 0 for SMPTE_offset events. Ignoring time (fingers crossed)...',x);
        end
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for SMPTE_offset event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        if exceeds(parameters(5),0,99)
            error('On line %u: fractional frame time must be between 0 and 99',x);
        end
    case MidiMsg.sequencer_specific
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(.*)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Sequencer_specific event',x);
        end
        len = str2double(toks{1}{1});
        if exceeds(len,0,2^28-1)
            error('On line %u: length of Sequencer_specific data must be between 0 and 2^28-1 bytes',x);
        end
        if len ~= length(toks{1}{2})
            warning('On line %u: length indicated does not match actual data length',x);
        end
        parameters = cellfun(@uint8,toks{1}{2});
    case MidiMsg.unknown_meta_event
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(.*)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Unknown_meta_event event',x);
        end
        len = str2double(toks{1}{2});
        if exceeds(len,0,2^28-1)
            error('On line %u: length of Unknown_meta_event must be between 0 and 2^28-1 bytes',x);
        end
        if len ~= length(toks{1}{3})
            warning('On line %u: length indicated does not match actual data length',x);
        end
        parameters = [str2double(toks{1}{1}) cellfun(@uint8,toks{1}{3})];
    case MidiMsg.note_on_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unknown parameter format for Note_on_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: Note value must be between 0 and 127',x);
        end
        if exceeds(parameters(3),0,127)
            error('On line %u: Velocity must be between 0 and 127',x);
        end
        if parameters(3) == 0
            event = 'Note_off_c';
        end
    case MidiMsg.note_off_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Note_off_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: Note value must be between 0 and 127',x);
        end
        parameters(3) = 0;
    case MidiMsg.pitch_bend_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Pitch_bend_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,16383)
            error('On line %u: pitch bend value must be between 0 and 16383',x);
        end
    case MidiMsg.control_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Control_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: control number must be between 0 and 127',x);
        end
        if exceeds(parameters(3),0,127)
            error('On line %u: control value must be between 0 and 127',x);
        end
    case MidiMsg.program_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Program_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: program number must be between 0 and 127',x);
        end
    case MidiMsg.channel_aftertouch_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Channel_aftertouch_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: channel aftertouch value must be between 0 and 127',x);
        end
    case MidiMsg.poly_aftertouch_c
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(\d+),\s*(\d+)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for Poly_aftertouch_c event',x);
        end
        parameters = cellfun(@str2double,toks{1});
        checkCh(parameters(1),x);
        if exceeds(parameters(2),0,127)
            error('On line %u: note value must be between 0 and 127',x);
        end
        if exceeds(parameters(3),0,127)
            error('On line %u: aftertouch value must be between 0 and 127',x);
        end
    case MidiMsg.system_exclusive
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(.*)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for System_exclusive event',x);
        end
        len = str2double(toks{1}{1});
        if exceeds(len,0,2^28-1)
            error('On line %u: length of System_exclusive data must be between 0 and 2^28-1 bytes',x);
        end
        if len ~= length(toks{1}{2})
            warning('On line %u: length indicated does not match actual data length',x);
        end
        parameters = cellfun(@uint8,toks{1}{2});
    case MidiMsg.system_exclusive_packet
        toks = regexpi(tokens{4},'^,\s*(\d+),\s*(.*)$','tokens');
        if length(toks) ~= 1
            error('On line %u: unrecognized parameter format for System_exclusive_packet event',x);
        end
        len = str2double(toks{1}{1});
        if exceeds(len,0,2^28-1)
            error('On line %u: length of System_exclusive_packet data must be between 0 and 2^28-1 bytes',x);
        end
        if len ~= length(toks{1}{2})
            warning('On line %u: length indicated does not match actual data length',x);
        end
        parameters = cellfun(@uint8,toks{1}{2});
end            

function exceeds = exceeds(n,lo,hi)
exceeds = n < lo || n > hi;

function [] = checkCh(n,x)
if exceeds(n,0,255)
    error('On line %u: channel must be between 0 and 255',x);
end
if n > 15
    warning('On line %u: channel greater than 15 is undefined',x);
end