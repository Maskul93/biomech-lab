function D = do_calibrate(DD, statics)

g = 9.81;

monitors = fieldnames(DD);

for mn = 1 : length(monitors)
    current_mon = char(monitors(mn));
    
    % Remove Gyro Bias
    D.(current_mon).gyr = DD.(current_mon).gyr - statics.(current_mon).gyro_bias;
    
    % Remove Acc Bias
    % acc_calib = ((acc_data - offs) * sens) * 9.81;
    acc = DD.(current_mon).acc;
    offs = statics.(current_mon).offs;
    sens = statics.(current_mon).sens;
    
    for i = 1 : 3
        unbiased_acc(:,i) = ((acc(:,i)/g - offs(i)) * sens(i)) * g;
    end
    
    D.(current_mon).acc = unbiased_acc;
    
    % Remove Mag Bias
    % mag_calib = diag(kmest) \ (mag - repmat(bmest,1,N));
    scalef = statics.(current_mon).scalef;
    bias = statics.(current_mon).bias;
    mag = DD.(current_mon).mag;
    N = length(mag);
    
    kmest = diag(scalef); % scalef
    bmest = repmat(bias,N,1); % bias
            
    unbiased_mag = kmest \ (mag - bmest)';
    
    D.(current_mon).mag = unbiased_mag';
end
end