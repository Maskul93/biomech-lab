subjects = fieldnames(DATA_NEXUS);
Fs = 100;

for sb = 2 : length(subjects)
    current_subject = char(subjects(sb));
    
    tasks = fieldnames(DATA_NEXUS.(current_subject).TASK);
    tasks = tasks(1:3); % Gait only
    
    for ts = 1 : length(tasks)
        current_task = char(tasks(ts));
        
        % Shank and Foot DCM from markers
        G_R_SH = DATA_NEXUS.(current_subject).TASK.(current_task).G_R_SHAN;
        G_R_FT = DATA_NEXUS.(current_subject).TASK.(current_task).G_R_FOOT;
        N = size(G_R_SH, 3);
        
        operators = fieldnames(DATA_NEXUS.(current_subject).FAN);
        
        for op = 1 : length(operators)
            current_op = char(operators(op));
            calibrations = fieldnames(DATA_NEXUS.(current_subject).FAN.(current_op));
            
            for cl = 1 : length(calibrations)
                current_cal = char(calibrations(cl));
                
                %% 1. FUNCTIONAL AXES --> Extract Functional Axes
                a_F = get_functional_axes_STEREO(DATA_NEXUS.(current_subject).FAN.(current_op).(current_cal).G_R_FOOT);
                OUT_STEREO.(current_subject).FAN.(current_op).(current_cal).a_sh_fun = a_F;
                OUT_STEREO.(current_subject).FAN.(current_op).(current_cal).a_ft_fun = a_F;
                
                % 2. SHANK Vertical AUX axis from posture
                current_posture = ['POST' num2str(cl)];
                POSTURE = DATA_NEXUS.(current_subject).POST.(current_posture).G_R_SHAN;
                axis_sh_v = mean(POSTURE(:,2,:),3);
                OUT_STEREO.(current_subject).ARF.(current_op).(current_cal).axis_sh_v = axis_sh_v;
                
                %% 3. FOOT LONG AXIS
                R_cali = DATA_NEXUS.(current_subject).POST.(current_posture).G_R_TABL;
                R_foot = DATA_NEXUS.(current_subject).POST.(current_posture).G_R_FOOT;
                
                R_cali_mean = mean_DCM(R_cali);
                R_foot_mean = mean_DCM(R_foot);
                axis_ft_l = R_foot_mean' * R_cali_mean(:,1);
                OUT_STEREO.(current_subject).ARF.(current_op).(current_cal).axis_ft_l = axis_ft_l;
                                
                %% 4. ANATOMICAL REFERENCE FRAME (ARF) --> Cross product of the obtained axes to get the ARF of both segments
                % ## ---- SHANK ---- ## %
                Z_sh = a_F;
                X_sh = unit(cross(Z_sh, axis_sh_v));
                Y_sh = unit(cross(Z_sh, X_sh));
                R_sh = [X_sh', Y_sh', Z_sh'];
                OUT_STEREO.(current_subject).ARF.(current_op).(current_cal).R_sh = R_sh;
                
                % ## ---- FOOT ---- ## %
                Z_ft = a_F;
                Y_ft = unit(cross(axis_ft_l, Z_ft));
                X_ft = unit(cross(Y_ft, Z_ft));
                R_ft = [X_ft', Y_ft', Z_ft'];
                OUT_STEREO.(current_subject).ARF.(current_op).(current_cal).R_ft = R_ft;
                
                %% 5. KINEMATICS
                R_shA = repmat(R_sh, 1, 1, N);
                R_ftA = repmat(R_ft, 1, 1, N);
                g_R_shA = multiprod(G_R_SH, R_shA);
                g_R_ftA = multiprod(G_R_FT, R_ftA);
                
                % Permute dimensions
                PROX = permute(g_R_shA, [3 1 2]);
                DIST = permute(g_R_ftA, [3 1 2]);
                
                % Get angles
                ang = fanges_STEREO(PROX, DIST);
                OUT_STEREO.(current_subject).KIN.(current_task).(current_op).(current_cal).angles = ang;
            end
        end
        
    end
end

    
    