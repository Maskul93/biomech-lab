subjects = fieldnames(DATA_RAW);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};
cals = {'CAL1', 'CAL2', 'CAL3'};
ops = {'OP1', 'OP2', 'OP3'};
posts = {'POST1', 'POST2', 'POST3'};
steps = {'STEP1', 'STEP2', 'STEP3'};

fs = 1200;

h = waitbar(0,'0%', 'Name', 'P favòr spitt...');
cycles = length(subjects) * length(gaits) * length(ops) * length(cals);
iter = 1;

for sb = 2 : length(subjects)
    subj = char(subjects(sb));
    
    for ts = 1 : length(gaits)
        gait = char(gaits(ts));
        step = char(steps(ts));
        post = char(posts(ts));
        
        GAIT = DATA_RAW.(subj).TASK.(gait);
        STEP = DATA_RAW.(subj).TASK.(step);
        POSTURE = DATA_RAW.(subj).POST.(post);
        
        for p = 1 : length(ops)
            op = char(ops(p));
            
            for cl = 1 : length(cals)
                cal = char(cals(cl));
                CALIBRATION = DATA_RAW.(subj).FAN.(op).(cal);
                
                OUT_MIMU.(subj).KIN.(gait).(op).(cal).angles = fan_protocol_MIMU(GAIT, CALIBRATION.FOOT, POSTURE, STEP, fs);
                waitbar(iter / cycles, h, [num2str(floor((iter/cycles)*100)), '%'])
                iter = iter + 1;
            end
        end
    end
    
end
close(h)