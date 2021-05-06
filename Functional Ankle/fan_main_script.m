% 1. FunAXESstruct --> Estraggo functional axes
% 2. Yimu_sh --> Estraggo la verticale della shank
% 3. XimuPost --> Estraggo l'asse lungo del piede
% 4. Terne --> Creo le terne anatomiche per entrambi i segmenti
% 5. Kin_IMU --> Calcolo la cinematografò
% % clear all
% % close all
% % load './mat_files/DATA_RAW.mat';
% % load './mat_files/OUT_STEREO.mat';

Fs = 1200;
Fc = 12;
Wn = Fc /(Fs/2);
%Fs = 100;
[b, a] = butter(4, Wn, 'low');

subjects = fieldnames(DATA_RAW);
for sb = 1 : length(subjects)
    current_subject = char(subjects(sb));
    tasks = fieldnames(DATA_RAW.(current_subject).TASK);
    tasks = tasks(1:3); % Just Gaits
    
    for ts = 1 : length(tasks)
        current_task = char(tasks(ts));
        
        % 'Navigation-Global' (Complementary)
        CALI_NAV = DATA_RAW.(current_subject).TASK.(current_task).CALI;
        settings.init_q_nb = get_q0(CALI_NAV.acc(1,:), CALI_NAV.mag(1,:));
        n_q_b = AHRS_apply(CALI_NAV, 'MadgwickAHRS', Fs, 1);
        n_R_b = quat2rotm(mean(n_q_b));
        
        % 'Navigation-Global' (FROE) 
        agm_nav = [CALI_NAV.acc, CALI_NAV.gyr, CALI_NAV.mag];
        [~, n_R_b2] = FROE(agm_nav, get_FROE_settings);
                
        % Load gait data and convert it into DCM (tek relative to nav)
        FOOT_GAIT = DATA_RAW.(current_subject).TASK.(current_task).FOOT;
        SHAN_GAIT = DATA_RAW.(current_subject).TASK.(current_task).SHAN;
        agm_shan_gait = [SHAN_GAIT.acc, SHAN_GAIT.gyr, SHAN_GAIT.mag];
        agm_foot_gait = [FOOT_GAIT.acc, FOOT_GAIT.gyr, FOOT_GAIT.mag];
         
        % Fuse data and get quaternions (Complementary)
        ft_q_g = AHRS_apply(FOOT_GAIT, 'MadgwickAHRS', Fs, 1);
        sh_q_g = AHRS_apply(SHAN_GAIT, 'MadgwickAHRS', Fs, 1);
        
        % Fuse data and get DCM (FROE)
        [~, n_R_sh] = FROE(agm_shan_gait, get_FROE_settings);
        [~, n_R_ft] = FROE(agm_foot_gait, get_FROE_settings);
        
        ft_R_g = quat2rotm(ft_q_g);
        sh_R_g = quat2rotm(sh_q_g);
        g_R_ft = multitransp(ft_R_g);
        g_R_sh = multitransp(sh_R_g);
        N = size(g_R_sh, 3);
        N_task = length(OUT_STEREO.(current_subject).KIN.(current_task).OP1.CAL1.angles);   % #samples of the task. Used after for 'scaletime'
        
        % Begin calibration process
        operators = fieldnames(DATA_RAW.(current_subject).FAN);
        
        for op = 1 : length(operators)
            current_op = char(operators(op));
            calibrations = fieldnames(DATA_RAW.(current_subject).FAN.(current_op));
            
            for cl = 1 : length(calibrations)
                current_cal = char(calibrations(cl));
                
                %display([current_subject, ' ', current_op, ' ' current_cal])
                
                %% 1. FUNCTIONAL AXES --> Extract Functional Axes
                D.RF = DATA_RAW.(current_subject).FAN.(current_op).(current_cal).FOOT;
                D.RS = DATA_RAW.(current_subject).FAN.(current_op).(current_cal).SHAN;
                
                a_F = get_functional_axes(D,'R', Fs);
                OUT_MIMU.(current_subject).FAN.(current_op).(current_cal).a_sh_fun = a_F;
                OUT_MIMU.(current_subject).FAN.(current_op).(current_cal).a_ft_fun = a_F;
                
                %% 2. SHANK VERTICAL AXIS --> Extract vertical shank axes from accelerometer data
                acc_post = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).SHAN.acc;
                axis_sh_v = unit(mean(acc_post));
                OUT_MIMU.(current_subject).FAN.(current_op).(current_cal).axis_sh_v = axis_sh_v;
                
                %% 3. FOOT LONG AXIS --> Extract foot long axis from calibration MIMU on the wooden table
                cali = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).CALI;
                foot = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).FOOT;
                agm_cali = [cali.acc, cali.gyr, cali.mag];
                agm_foot = [foot.acc, foot.gyr, foot.mag];
                
                % Complementary
                q_cali = AHRS_apply(cali, 'MadgwickAHRS', Fs, 1);
                q_foot = AHRS_apply(foot, 'MadgwickAHRS', Fs, 1);
                
                q_cali = mean(q_cali);
                q_foot = mean(q_foot);
                R_cali = quat2rotm(q_cali);
                R_foot = quat2rotm(q_foot);
                axis_ft_l = R_foot' * R_cali(:,1);
                OUT_MIMU.(current_subject).FAN.(current_op).(current_cal).axis_ft_l = axis_ft_l;
                
                % FROE
                q_cali2 = FROE(agm_cali, get_FROE_settings);
                q_foot2 = FROE(agm_foot, get_FROE_settings);
                R_cali2 = quat2rotm(mean(q_cali2));
                R_foot2 = quat2rotm(mean(q_foot2));
                axis_ft_l2 = R_foot2' * R_cali2(:,1);
                
                %% 4. ANATOMICAL REFERENCE FRAME (ARF) --> Cross product of the obtained axes to get the ARF of both segments
                % ## ---- SHANK ---- ## %
                Z_sh = a_F;
                X_sh = unit(cross(Z_sh, axis_sh_v));
                Y_sh = unit(cross(Z_sh, X_sh));
                R_sh = [X_sh', Y_sh', Z_sh'];
                OUT_MIMU.(current_subject).ARF.(current_op).(current_cal).R_sh = R_sh;
                
                % FROE
                R_sh2 = R_sh;
                
                % ## ---- FOOT ---- ## %
                Z_ft = a_F;
                Y_ft = unit(cross(axis_ft_l, Z_ft));
                X_ft = unit(cross(Y_ft, Z_ft));
                R_ft = [X_ft', Y_ft', Z_ft'];
                OUT_MIMU.(current_subject).ARF.(current_op).(current_cal).R_ft = R_ft;
                
                % FROE
                Y_ft2 = unit(cross(axis_ft_l2, Z_ft));
                X_ft2 = unit(cross(Y_ft2, Z_ft));
                R_ft2 = [X_ft2', Y_ft2', Z_ft'];
                
                %% 5. KINEMATICS --> Apply what you've just computed and get angles (Complementary)
                R_shA = repmat(R_sh, 1, 1, N);
                R_ftA = repmat(R_ft, 1, 1, N);
                g_R_shA = multiprod(g_R_sh, R_shA);
                g_R_ftA = multiprod(g_R_ft, R_ftA);
                
                % FROE
                R_shA2 = repmat(R_sh2, 1, 1, N);
                R_ftA2 = repmat(R_ft2, 1, 1, N);
                g_R_shA2 = multiprod(n_R_sh, R_sh2);
                g_R_ftA2 = multiprod(n_R_ft, R_ft2);
                
                % Align to the 'Navigation-Global'
                if sb == 6  % Subject 6 has the calibration MIMU in the wrong way
                    y = -n_R_b(:,1);
                    x = n_R_b(:,2);
                    z = n_R_b(:,3);
                    
                    n_R_b = [x,y,z];
                end
                
                nb = repmat(n_R_b, 1, 1, N);    % Complementary
                nb2 = n_R_b2;                   % FROE
                
                % Complementary
                g_R_shA = multiprod(nb, g_R_shA);
                g_R_ftA = multiprod(nb, g_R_ftA);
                
                % FROE
                g_R_shA2 = multiprod(nb2, g_R_shA2);
                g_R_ftA2 = multiprod(nb2, g_R_ftA2);
                
                % Permute dimensions (Complementary)
                PROX = permute(g_R_shA, [3 1 2]);
                DIST = permute(g_R_ftA, [3 1 2]);
                
                % Permute dimensions (FROE)
                PROX2 = permute(g_R_shA2, [3 1 2]);
                DIST2 = permute(g_R_ftA2, [3 1 2]);
                
                % Get angles
                ang = fanges(PROX, DIST);
                ang2 = fanges(PROX2, DIST2);
                
                ang_filt = filtfilt(b,a, ang);
                ang2_filt = filtfilt(b,a,ang2);
                
                %ang_rs = resample(ang_filt, 1, 12);
                ang_rs = ScaleTime(ang_filt, 1, N, N_task);
                ang2_rs = ScaleTime(ang2_filt, 1, N, N_task);
                
                OUT_MIMU.(current_subject).KIN.(current_task).(current_op).(current_cal).angles = ang_rs;
                OUT_MIMU.(current_subject).KIN.(current_task).(current_op).(current_cal).angles2 = ang2_rs;

            end
        end
    end
end

%save('OUT_MIMU.mat', 'OUT_MIMU')

%                 % Posture correction
%                 r0_sh = g_R_shA(:,:,1)';
%                 r0_ft = g_R_ftA(:,:,1)';
%                 for tt = 1 : N
%                     g_R_shA(:,:,tt) = r0_sh * g_R_shA(:,:,tt);
%                     g_R_ftA(:,:,tt) = r0_ft * g_R_ftA(:,:,tt);
%                 end
                
