% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

classdef MidiMsg
    %MidiMsg Enumerates MIDI message types used in MIDICSV
    % using all lower case since MIDICSV is case insensitive
    enumeration
       % file structure
       header
       end_of_file
       start_track
       end_track
       % meta events (_t takes text argument)
       title_t
       copyright_t
       instrument_name_t
       marker_t
       cue_point_t
       lyric_t
       text_t
       sequence_number
       midi_port
       channel_prefix
       time_signature
       key_signature
       tempo
       smpte_offset
       sequencer_specific
       unknown_meta_event
       % channel events (with _c to distinguish as such)
       note_on_c
       note_off_c
       pitch_bend_c
       control_c
       program_c
       channel_aftertouch_c
       poly_aftertouch_c
       % system exclusive events
       system_exclusive
       system_exclusive_packet
    end
    methods
        function tf = eq(a,b)
            tf = strcmpi(string(a),string(b));
        end
        function tf = ne(a,b)
            tf = ~strcmpi(string(a),string(b));
        end
    end
end

