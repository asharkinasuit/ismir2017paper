% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function [] = write_midicsv(midistruct,filen)

f = fopen(filen,'w');
fprintf(f,'0,0,Header,%u,%u,%u\n',midistruct.format,midistruct.ntracks,midistruct.division);
for i = 1:midistruct.ntracks
    for j = 1:length(midistruct.tracks{i})
        thisline = midistruct.tracks{i}(j);
        if thisline.event == MidiMsg.key_signature
            if thisline.parameters(2)
                fprintf(f,'%u,%u,%s,%u,"minor"\n',thisline.track,thisline.time,thisline.event,thisline.parameters(1));
            else
                fprintf(f,'%u,%u,%s,%u,"major"\n',thisline.track,thisline.time,thisline.parameters(1));
            end
        else
            if endsWith(thisline.event,'_t')
                fprintf(f,'%u,%u,%s,"%s"\n',thisline.track,thisline.time,thisline.event,thisline.parameters);
            else
                fprintf(f,'%u,%u,%s%s\n',thisline.track,thisline.time,thisline.event,strrep(num2str(thisline.parameters,',%u'),' ',''));
            end
        end
    end
end
fprintf(f,'0,0,End_of_file');