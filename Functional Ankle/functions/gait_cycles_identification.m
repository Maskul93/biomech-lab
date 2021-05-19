
subjects = fieldnames(OUT_STEREO);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};

timings = [ ];

for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    
    for gt = 1 : length(gaits)
        gait = char(gaits(gt));
        
        PD = OUT_STEREO.(subj).KIN.(gait).OP1.CAL1.angles(:,1);
        plot(PD);
        [x,~] = ginput(2);
        pause
        close
        
        smp = round(x);
        timings = [timings; {subj}, {gait}, {smp(1)}, {smp(2)}];
        
    end
end