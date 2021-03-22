% 1. FunAXESstruct --> Estraggo functional axes
% 2. Yimu_sh --> Estraggo la verticale della shank
% 3. XimuPost --> Estraggo l'asse lungo del piede
% 4. Terne --> Creo le terne anatomiche per entrambi i segmenti
% 5. Kin_IMU --> Calcolo la cinematografò

close all
%load('C:\Users\masku\Google Drive\Multi_FAN\DATA_RAW.mat');
Fs = 1200;


subjects = fieldnames(DATA_RAW);
for sb = 4%1 : length(subjects)
    current_subject = char(subjects(sb));
    tasks = fieldnames(DATA_RAW.(current_subject).TASK);
    tasks = tasks(1:3); % Just Gaits
    
    for ts = 1 : length(tasks)
        current_task = char(tasks(ts));
        
        % Foot FROE settings
        settings = get_FROE_settings;
        settings.T = 1 / Fs;
        
        % 'Navigation-Global'
        CALI_NAV = DATA_RAW.(current_subject).TASK.(current_task).CALI;
        settings.init_q_nb = get_q0(CALI_NAV.acc(1,:), CALI_NAV.mag(1,:));
        settings.estGyrBias = 0; 
        settings.estimateMagneticField = 0;
        settings.g = [0 0 9.82];
        n_q_b = FROE([CALI_NAV.acc CALI_NAV.gyr CALI_NAV.mag], settings);
        %plot(n_q_b,'DisplayName','n_q_b')
        n_R_b = quat2rotm(mean(n_q_b));
        
        n_q_b = AHRS_apply(CALI_NAV, 'MadgwickAHRS', Fs, 1);
        n_R_b = quat2rotm(mean(n_q_b));
        
        settings.g = [0 0 9.82];
        settings.estGyrBias = 0; 
        settings.estimateMagneticField = 0;
        % Load gait data and convert it into DCM (tek relative to nav)
        FOOT_GAIT = DATA_RAW.(current_subject).TASK.(current_task).FOOT;
        SHAN_GAIT = DATA_RAW.(current_subject).TASK.(current_task).SHAN;
              
        settings.init_q_nb = get_q0(FOOT_GAIT.acc(1,:), FOOT_GAIT.mag(1,:));
        ft_q_g = FROE([FOOT_GAIT.acc FOOT_GAIT.gyr FOOT_GAIT.mag], settings);
        
        % Update initial condition for the Shank
        settings.init_q_nb = get_q0(SHAN_GAIT.acc(1,:), SHAN_GAIT.mag(1,:));
        sh_q_g = FROE([SHAN_GAIT.acc SHAN_GAIT.gyr SHAN_GAIT.mag], settings);
        
        ft_q_g = AHRS_apply(FOOT_GAIT, 'MadgwickAHRS', Fs, 1);
        sh_q_g = AHRS_apply(SHAN_GAIT, 'MadgwickAHRS', Fs, 1);
        
        ft_R_g = quat2rotm(ft_q_g);
        sh_R_g = quat2rotm(sh_q_g);
        g_R_ft = multitransp(ft_R_g);
        g_R_sh = multitransp(sh_R_g);
        N = size(g_R_sh, 3);
        
        % Begin calibration process
        operators = fieldnames(DATA_RAW.(current_subject).FAN);
        
        for op = 1 : length(operators)
            current_op = char(operators(op));
            calibrations = fieldnames(DATA_RAW.(current_subject).FAN.(current_op));
            
            for cl = 1 : length(calibrations)
                current_cal = char(calibrations(cl));
                
                display([current_subject, ' ', current_op, ' ' current_cal])
                
                %% 1. FUNCTIONAL AXES --> Extract Functional Axes
                D.RF = DATA_RAW.(current_subject).FAN.(current_op).(current_cal).FOOT;
                D.RS = DATA_RAW.(current_subject).FAN.(current_op).(current_cal).SHAN;
                
                a_F = get_functional_axes(D,'R', Fs);
                OUT.(current_subject).FAN.(current_op).(current_cal).a_sh_fun = a_F;
                OUT.(current_subject).FAN.(current_op).(current_cal).a_ft_fun = a_F;
                
                %% 2. SHANK VERTICAL AXIS --> Extract vertical shank axes from accelerometer data
                acc_post = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).FOOT.acc;
                axis_sh_v = unit(mean(acc_post));
                OUT.(current_subject).FAN.(current_op).(current_cal).axis_sh_v = axis_sh_v;
                
                %% 3. FOOT LONG AXIS --> Extract foot long axis from calibration MIMU on the wooden table
                cali = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).CALI;
                foot = DATA_RAW.(current_subject).POST.(['POST', num2str(cl)]).FOOT;
                
                settings.init_q_nb = get_q0(cali.acc(1,:), cali.mag(1,:));
                q_cali = FROE([cali.acc, cali.gyr, cali.mag], settings);
                
                settings.init_q_nb = get_q0(foot.acc(1,:), foot.mag(1,:));
                q_foot = FROE([foot.acc, foot.gyr, foot.mag], settings);
                
                q_cali = mean(q_cali);
                q_foot = mean(q_foot);
                R_cali = quat2rotm(q_cali);
                R_foot = quat2rotm(q_foot);
                axis_ft_l = R_foot' * R_cali(:,1);       
                OUT.(current_subject).FAN.(current_op).(current_cal).axis_ft_l = axis_ft_l;
                
                %% 4. ANATOMICAL REFERENCE FRAME (ARF) --> Cross product of the obtained axes to get the ARF of both segments
                % ## ---- SHANK ---- ## %
                Z_sh = a_F;
                X_sh = unit(cross(Z_sh, axis_sh_v));
                Y_sh = unit(cross(Z_sh, X_sh));
                R_sh = [X_sh', Y_sh', Z_sh'];
                OUT.(current_subject).ARF.(current_op).(current_cal).R_sh = R_sh;
                
                % ## ---- FOOT ---- ## %
                Z_ft = a_F;
                Y_ft = unit(cross(axis_ft_l, Z_ft));
                X_ft = unit(cross(Y_ft, Z_ft));
                R_ft = [X_ft', Y_ft', Z_ft'];
                OUT.(current_subject).ARF.(current_op).(current_cal).R_ft = R_ft;
                
                %% 5. KINEMATICS --> Apply what you've just computed and get angles (maybe)
                R_shA = repmat(R_sh, 1, 1, N);
                R_ftA = repmat(R_ft, 1, 1, N);
                g_R_shA = multiprod(g_R_sh, R_shA);
                g_R_ftA = multiprod(g_R_ft, R_ftA);
                
                % Align to the 'Navigation-Global'
                
                if sb == 6
                    y = -n_R_b(:,1);
                    x = n_R_b(:,2);
                    z = n_R_b(:,3);
                    
                    n_R_b = [x,y,z];
                end
                
                nb = repmat(n_R_b, 1, 1, N);
                
                g_R_shA = multiprod(nb, g_R_shA);
                g_R_ftA = multiprod(nb, g_R_ftA);
                
                PROX = permute(g_R_shA, [3 1 2]);
                DIST = permute(g_R_ftA, [3 1 2]);

                ang = fanges(PROX, DIST);
                OUT.(current_subject).KIN.(current_task).(current_op).(current_cal).angles = ang;
            end
        end
            figure
            plot(ang);
            title(['Subject ' current_subject ' - ' current_task])
    end
end

%save('OUT', 'OUT.mat')