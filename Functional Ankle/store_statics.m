
subj = 'S6';

Dacc = get_trident(['./' subj '/Static/StaticACC.csv']);
Dgyr = get_trident(['./' subj '/Static/StaticGYR.csv']);
Dmag = get_trident(['./' subj '/Static/StaticMAG.csv']);

monitors = fieldnames(Dacc);

for mn = 1 : length(monitors)
    
    current_monitor = char(monitors(mn));
    
    [offs, sens] = get_acc_calib(Dacc.(current_monitor).acc);
    [bias, scalef] = get_mag_calib(Dmag.(current_monitor).mag);
    [gyro_bias] = get_gyr_bias(Dgyr.(current_monitor).gyr);
    
    statics.(current_monitor).offs = offs;
    statics.(current_monitor).sens = sens;
    statics.(current_monitor).bias = bias;
    statics.(current_monitor).scalef = scalef;
    statics.(current_monitor).gyro_bias = gyro_bias;
    
end

save([subj '_statics.mat'], 'statics')
