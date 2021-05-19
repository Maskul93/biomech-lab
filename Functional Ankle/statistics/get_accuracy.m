subjects = fieldnames(OUT_STEREO);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};
operators = {'OP1', 'OP2', 'OP3'};
calibrations = {'CAL1', 'CAL2', 'CAL3'};
timings = readtable('./theory/cut_timings.csv');
ti = timings.ti;
tf = timings.tf;
idx = 0;

arch_acc = [ ];


for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    
    for gt = 1 : length(gaits)
        gait = char(gaits(gt));
        
        idx = idx + 1;
        
        for op = 1 : length(operators)
            oper = char(operators(op));
            
            for cl = 1 : length(calibrations)
                cal = char(calibrations(cl));
                
                x = [OUT_STEREO.(subj).KIN.(gait).(oper).(cal).angles(ti(idx):tf(idx),1), ...
                    OUT_MIMU.(subj).KIN.(gait).(oper).(cal).angles(ti(idx):tf(idx),1)];
                
                y = get_rmse(x);
                R = corrcoef(x);
                r = R(1,2);
                
                B = ScaleTime(x(:,1), 1, length(x), 100)';
                A = ScaleTime(x(:,2), 1, length(x), 100)';
                
                [r2, a1, a0] = linfit2ref(A , B);
                
                
                arch_acc = [arch_acc; {subj}, {gait}, {oper}, {cal}, {y}, {r}, {r2}, {a1}, {a0}];
                
               
            end
        end
    end
end


writetable(cell2table(arch_acc, 'VariableNames', {'subj', 'gait', 'operator', 'calibration', 'RMSE', 'r', 'r2', 'a1', 'a0'}), './theory/accuracy.csv', 'WriteVariableNames', 1)

% Private function to improve code readability
function y = get_rmse(x)

    for i = 1 : length(x)
        root_err_sq(i) = sqrt( (x(i,1) - x(i,2))^2 );
    end
      
    y = mean(root_err_sq);
end