%load ~/Desktop/data_fan_2021/mat_files/DATA_RAW_NEXUS_bad_names.mat

D = DATA_RAW_NEXUS;

subjects = fieldnames(D);

for sb = 4%1 : length(subjects)
    current_subject = char(subjects(sb));
    sessions = fieldnames(D.(current_subject));
    
    for ss = 1 : length(sessions)
        current_session = char(sessions(ss));
        
        if strcmp(current_session, 'TASK')
            
            trials = fieldnames(D.(current_subject).TASK);
            trials = trials(1:3);
            
            for tr = 1 : length(trials)
                current_trial = char(trials(tr));
                
                temp_trial = D.(current_subject).TASK.(current_trial);
                fields = fieldnames(temp_trial);
                
                
                for fl = 1 : length(fields)
                    
                    current_field = char(fields(fl));
                    
                    if strfind(current_field, ['S' num2str(sb) '_']);
                        new_field = erase(current_field, ['S' num2str(sb) '_']);
                        
                        tmp = D.(current_subject).TASK.(current_trial).(current_field);     % Store temporarily data from old field.
                        temp_trial = rmfield(temp_trial, current_field); % Remove old-named field
                        temp_trial.(new_field) = tmp;
                        
                    end
                end
                
                D.(current_subject).TASK.(current_trial) = temp_trial;
            end
            
        end
        
        %% POSTURE
        if strcmp(current_session, 'POST')
            trials = fieldnames(D.(current_subject).POST);
            
            for tr = 1 : length(trials)
                current_trial = char(trials(tr));
                
                temp_trial = D.(current_subject).POST.(current_trial);
                fields = fieldnames(temp_trial);
                
                
                for fl = 1 : length(fields)
                    
                    current_field = char(fields(fl));
                    
                    if strfind(current_field, 'Table_')
                        new_field = erase(current_field, 'Table_');
                        tmp = D.(current_subject).POST.(current_trial).(current_field);     % Store temporarily data from old field.
                        temp_trial = rmfield(temp_trial, current_field); % Remove old-named field
                        temp_trial.(new_field) = tmp;
                    end
                    
                    if strfind(current_field, ['S' num2str(sb) '_']);
                        new_field = erase(current_field, ['S' num2str(sb) '_']);
                        tmp = D.(current_subject).POST.(current_trial).(current_field);     % Store temporarily data from old field.
                        temp_trial = rmfield(temp_trial, current_field); % Remove old-named field
                        temp_trial.(new_field) = tmp;
                        
                    end
                end
                
                D.(current_subject).POST.(current_trial) = temp_trial;
            end
        end
        
        % CALIBRATIONS
        if strcmp(current_session, 'FAN')
            
            operators = fieldnames(D.(current_subject).FAN);
            for op = 1 : length(operators)
                current_operator = char(operators(op));
                calibrations = fieldnames(D.(current_subject).FAN.(current_operator));
                
                for cl = 1 : length(calibrations)
                    current_calibration = char(calibrations(cl));
                    
                    temp_trial = D.(current_subject).FAN.(current_operator).(current_calibration);
                    fields = fieldnames(temp_trial);
                    
                    for fl = 1 : length(fields)
                        
                        current_field = char(fields(fl));
                        
                        if strfind(current_field, ['S' num2str(sb) '_']);
                            new_field = erase(current_field, ['S' num2str(sb) '_']);
                            
                            tmp = D.(current_subject).TASK.(current_trial).(current_field);     % Store temporarily data from old field.
                            temp_trial = rmfield(temp_trial, current_field); % Remove old-named field
                            temp_trial.(new_field) = tmp;
                            
                        end
                    end
                    D.(current_subject).FAN.(current_operator).(current_calibration) = temp_trial;
                end
            end
            
            
        end
    end
    
end



