warning off
% subjects
for i = 1 : 11
    subjects{i} = ['S' num2str(i)];
end

for sb = 1 : length(subjects)
    subj = char(subjects(sb));
    sessions = get_filenames(['./nexus_csv/', subj, '/']);
    
    for ss = 1 : length(sessions)
        sess = char(sessions(ss));
        session_files = get_filenames(['./nexus_csv/', subj, '/', sess]);
                
        for fl = 1 : length(session_files)
            filename = char(session_files(fl));
            
            if ss == 1  % FAN
                
                if sb <= 4
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    [G_R_FOOT, G_R_SHAN] = markers2dcmFAN(fn);
                else
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    [G_R_FOOT, G_R_SHAN] = markers2dcmFAN_ww(fn);
                end
                
                op = filename(end-11:end-9); % current operator
                cl = filename(end-7:end-4);  % current calibration
                
                DATA_NEXUS.(subj).(sess).(op).(cl).G_R_FOOT = G_R_FOOT;
                DATA_NEXUS.(subj).(sess).(op).(cl).G_R_SHAN = G_R_SHAN;
                
            end
            
            if ss == 2  % POST
                
                if sb <= 4
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    [G_R_FOOT, G_R_SHAN, G_R_TABL] = markers2dcmPOST(fn);
                else
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    [G_R_FOOT, G_R_SHAN, G_R_TABL] = markers2dcmPOST_ww(fn);
                end
                cl = filename(end-8:end-4);
                
                DATA_NEXUS.(subj).(sess).(cl).G_R_FOOT = G_R_FOOT;
                DATA_NEXUS.(subj).(sess).(cl).G_R_SHAN = G_R_SHAN;
                DATA_NEXUS.(subj).(sess).(cl).G_R_TABL = G_R_TABL;
                
            end
            
            if ss == 3  % TASK
                if sb <= 4
                    
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    if fl < 4
                        [G_R_FOOT, G_R_SHAN] = markers2dcmTASK(fn);
                    end
                    
                    if fl >= 4
                        [G_R_FOOT, G_R_SHAN, G_R_STEP] = markers2dcmSTEP(fn);
                        DATA_NEXUS.(subj).(sess).(cl).G_R_STEP = G_R_STEP;
                    end
                        
                else
                    fn = ['./nexus_csv/', subj, '/', sess '/' filename];
                    if fl < 4
                        [G_R_FOOT, G_R_SHAN] = markers2dcmTASK_ww(fn);
                    end
                    
                    if fl >= 4
                        [G_R_FOOT, G_R_SHAN, G_R_STEP] = markers2dcmSTEP_ww(fn);    
                        DATA_NEXUS.(subj).(sess).(cl).G_R_STEP = G_R_STEP;
                    end
                end
                cl = filename(end-8:end-4);
                
                DATA_NEXUS.(subj).(sess).(cl).G_R_FOOT = G_R_FOOT;
                DATA_NEXUS.(subj).(sess).(cl).G_R_SHAN = G_R_SHAN;
                
            end 
        end
    end
end
