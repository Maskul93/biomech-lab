subjects = fieldnames(OUT_STEREO);
subjects = subjects([1:9,11]);
gaits = {'GAIT1', 'GAIT2', 'GAIT3'};
operators = {'OP1', 'OP2', 'OP3'};
calibrations = {'CAL1', 'CAL2', 'CAL3'};
timings = readtable('~/Desktop/Functional Ankle/cut_timings.csv');
ti = timings.ti;
tf = timings.tf;
idx = 0;

intra_op = [ ];
inter_op = [ ];
intra_subj = [ ];
inter_subj = [ ];

arch_intra_op = [ ];
arch_inter_op = [ ];
arch_intra_subj = [ ];

y_sq = [ ];

for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    
    for gt = 1 : length(gaits)
        gait = char(gaits(gt));
        
        idx = idx + 1;
        
        % Intra operator
        for op = 1 : length(operators)
            oper = char(operators(op));
            
            intra_op = [intra_op; OUT_MIMU.(subj).KIN.(gait).(oper).CAL1.angles(ti(idx):tf(idx),1), ...
                OUT_MIMU.(subj).KIN.(gait).(oper).CAL2.angles(ti(idx):tf(idx),1), ...
                OUT_MIMU.(subj).KIN.(gait).(oper).CAL3.angles(ti(idx):tf(idx),1)];
            
            inter_op = [inter_op, intra_op];    % Append the 3 calibrations
            sigma_intra_op = get_sigma(intra_op);         % Compute sigma Intra-Operator
            arch_intra_op = [arch_intra_op; {subj}, {gait}, {oper}, {sigma_intra_op}]; % Store into archive
            intra_op = [ ];                     % Clear intra variables
            
        end
        
        % Inter operator
        sigma_inter_op = get_sigma(inter_op);             % Compute mean sigma Inter-Operator
        arch_inter_op = [arch_inter_op; {subj}, {gait}, {sigma_inter_op}]; % Store into archive
        
        % Append and Normalize the 9 gait cycles of the same subject
        intra_subj = [intra_subj, ScaleTime(inter_op, 1, size(inter_op, 1), 100)];
        inter_op = [ ];                         % Clear Inter-Operator variable
    end
    
    sigma_intra_subj = get_sigma(intra_subj);        % Compute sigma Intra-Subject
    arch_intra_subj = [arch_intra_subj; {subj}, {sigma_intra_subj}];
    
    inter_subj = [inter_subj, intra_subj];
    
    intra_subj = [ ];   % Clear Intra-Subject variable
end

sigma_inter_subj = get_sigma(inter_subj);    % Compute sigma Inter-Subject


% Private function to improve code readability
function [sigma_source, y, y_sq] = get_sigma(x)
    T = size(x, 1);
    p = size(x, 2);
    x_mean = mean(x,2);
        
    for j = 1 : p
        
        num = 0;
        
        for i = 1 : T
            num = num + (x_mean(i) - x(i,j))^2;
        end
        
        y_sq(j) = num / T;
        % y(j) = sqrt(num / T);
        
    end
    
    sigma_source = sqrt( sum(y_sq) / (p - 1) );     % Eq. 2.4
end