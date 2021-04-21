clear all

load('OUT.mat')
load('OUT_STEREO.mat')

subjects = fieldnames(OUT_STEREO);
Fs = 100;


for sb = 1 : length(subjects)
    current_subject = char(subjects(sb));
    
    tasks = fieldnames(OUT_STEREO.(current_subject).KIN);
    tasks = tasks(1:3); % Gait only
    
    for ts = 1 : length(tasks)
        current_task = char(tasks(ts));
        operators = fieldnames(OUT_STEREO.(current_subject).KIN.(current_task));
        
        for op = 1 : length(operators)
            current_op = char(operators(op));
            calibrations = fieldnames(OUT_STEREO.(current_subject).KIN.(current_task).(current_op));
            
            for cl = 1 : length(calibrations)
                current_cal = char(calibrations(cl));
                
                % display([current_subject, ' ', current_task, ' ', current_op, ' ', current_cal])
                
                D_STER = OUT_STEREO.(current_subject).KIN.(current_task).(current_op).(current_cal).angles;
                D_MIMU = OUT.(current_subject).KIN.(current_task).(current_op).(current_cal).angles;
            
            end
            
        end
        
    end
    
end