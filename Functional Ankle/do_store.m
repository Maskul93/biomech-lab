
subjects = get_filenames('./');

for sb = 8 %: length(subjects)
    
    current_subject = char(subjects(sb));
    
    % Load calibration parameters for current subject
    load(['../mat_files/' current_subject '_statics.mat']);
    
    sessions = get_filenames(['./' current_subject]);
    sessions = sessions([1,2,4]); % Remove 'Static' session
    
    for ss = 1 : length(sessions)
        
        current_session = char(sessions(ss));
        files = get_filenames(['./' current_subject '/' current_session]);
        
        for fl = 1 : length(files)
            
            current_file = char(files(fl));
            
            if strcmp(current_session, 'FAN') 
                
                op = current_file(8:10);    % extract operator fieldname from filename
                cl = current_file(12:15);   % extract calibration fieldname from filename
                
                DD = get_trident(current_file);
                D = do_calibrate(DD, statics);
                
%                 plot(DD.FOOT.gyr)

                
%                 FOOT = D.SHAN;
%                 SHANK = D.FOOT;
%                 D.FOOT = FOOT;
%                 D.SHAN = SHANK;
                
                DATA_RAW.(current_subject).(current_session).(op).(cl) = D;
            end
            
            if strcmp(current_session, 'POST')

                posnum = current_file(8:end-4);

                DD = get_trident(current_file);
                D = do_calibrate(DD, statics);
                
%                 FOOT = D.SHAN;
%                 SHANK = D.FOOT;
%                 D.FOOT = FOOT;
%                 D.SHAN = SHANK;

                DATA_RAW.(current_subject).(current_session).(posnum) = D;
            end
            
            if strcmp(current_session, 'TASK')
                
                taskname = current_file(4:end-4); % get taskname from filename
                DD = get_trident(current_file);
                D = do_calibrate(DD, statics);
                
%                 FOOT = D.SHAN;
%                 SHANK = D.FOOT;
%                 D.FOOT = FOOT;
%                 D.SHAN = SHANK;
                
                DATA_RAW.(current_subject).(current_session).(taskname) = D;
            end
        end
    end
end