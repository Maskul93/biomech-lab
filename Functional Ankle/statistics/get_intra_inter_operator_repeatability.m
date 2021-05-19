subjects = fieldnames(OUT_STEREO);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};
operators = {'OP1', 'OP2', 'OP3'};
calibrations = {'CAL1', 'CAL2', 'CAL3'};
timings = readtable('./theory/cut_timings.csv');
ti = timings.ti;
tf = timings.tf;
idx = 0;

PD_intra = [ ];
PD_inter = [ ];
PD_intra_stereo = [ ];
PD_inter_stereo = [ ];
arch_intra = [ ];
arch_inter = [ ];
arch_lfm = [ ];
arch_acc = [ ];

for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    
    for gt = 1 : length(gaits)
        gait = char(gaits(gt));
        
        idx = idx + 1;
        
        % Intra operator
        for op = 1 : length(operators)
            oper = char(operators(op));
            
            PD_intra = [PD_intra; OUT_MIMU.(subj).KIN.(gait).(oper).CAL1.angles(ti(idx):tf(idx),1), ...
                OUT_MIMU.(subj).KIN.(gait).(oper).CAL2.angles(ti(idx):tf(idx),1), ...
                OUT_MIMU.(subj).KIN.(gait).(oper).CAL3.angles(ti(idx):tf(idx),1)];
            
            PD_inter = [PD_inter, PD_intra];    % Append the 3 calibrations
            intra = get_rmse(PD_intra);         % Compute mean RMSE "INTRA"
            arch_intra = [arch_intra; {subj}, {gait}, {oper}, {intra}]; % Store into archive
            PD_intra = [ ];                     % Clear intra variables
            
            % Stereo
            PD_inter_stereo = [PD_inter_stereo, OUT_STEREO.(subj).KIN.(gait).(oper).CAL1.angles(ti(idx):tf(idx),1), ...
                OUT_STEREO.(subj).KIN.(gait).(oper).CAL2.angles(ti(idx):tf(idx),1), ...
                OUT_STEREO.(subj).KIN.(gait).(oper).CAL3.angles(ti(idx):tf(idx),1)];
            
        end
        
        % Inter operator
        inter = get_rmse(PD_inter);             % Compute mean RMSE "INTER"
        arch_inter = [arch_inter; {subj}, {gait}, {inter}]; % Store into archive
        
        % Reference curve for LFM
        B_real = mean(PD_inter_stereo, 2)';
        B = ScaleTime(B_real, 1, length(B_real), 100);
        A = ScaleTime(PD_inter, 1, length(B_real), 100)';
        [r2, a1, a0] = linfit2ref(A, B);
        arch_lfm = [arch_lfm; {subj}, {gait}, {a1}, {a0}, {r2}, {sqrt(r2)}];
        
        PD_inter = [ ];                         % Clear inter variable
        PD_inter_stereo = [ ];
    end
end

writetable(cell2table(arch_intra, 'VariableNames', {'subj', 'gait', 'operator', 'rmse'}), './theory/rmse_intra.csv', 'WriteVariableNames', 1)
writetable(cell2table(arch_inter, 'VariableNames', {'subj', 'gait', 'rmse'}), './theory/rmse_inter.csv', 'WriteVariableNames', 1)
writetable(cell2table(arch_lfm, 'VariableNames', {'subj', 'gait', 'a1', 'a0', 'r2', 'r'}), './theory/lfm.csv', 'WriteVariableNames', 1)

% Private function to improve code readability
function y = get_rmse(x)
    y = mean(rms(x - mean(x,2)),2);
end