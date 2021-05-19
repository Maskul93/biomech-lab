subjects = fieldnames(OUT_STEREO);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};
timings = readtable('./theory/cut_timings.csv');
ti = timings.ti;
tf = timings.tf;
idx = 0;
vars = {'subject', 'R2', 'SD a1', 'SD a0', 'a1', 'a0'};



A1 = [ ]; % IMU
A2 = [ ]; % STEREO

arch_imu = [ ];
arch_ste = [ ];

for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    
    for gt = 1 : length(gaits)
        gait = char(gaits(gt));
        
        idx = idx + 1;
        
        x_imu = OUT_MIMU.(subj).KIN.(gait).OP1.CAL1.angles(ti(idx):tf(idx),1)';
        x_ste = OUT_STEREO.(subj).KIN.(gait).OP1.CAL1.angles(ti(idx):tf(idx),1)';
        
        x1 = ScaleTime(x_imu, 1, length(x_imu), 100);
        x2 = ScaleTime(x_ste, 1, length(x_ste), 100);
        
        A1 = [A1; x1];
        A2 = [A2; x2];
    end
    
        
    [R2,SD_a1,SD_a0,m_a1,m_a0] = linfit2mean(A1);
    arch_imu = [arch_imu; {subj}, {R2}, {SD_a1}, {SD_a0}, {m_a1}, {m_a0}];
    
    [R2,SD_a1,SD_a0,m_a1,m_a0] = linfit2mean(A2);
    arch_ste = [arch_ste; {subj}, {R2}, {SD_a1}, {SD_a0}, {m_a1}, {m_a0}];
    
    A1 = [ ]; A2 = [ ];
end

% T1 = cell2table(arch_imu, 'VariableNames', vars);
% T2 = cell2table(arch_ste, 'VariableNames', vars);
% 
% writetable(T1, './theory/intra_subject_imu.csv');
% writetable(T2, './theory/intra_subject_ste.csv');