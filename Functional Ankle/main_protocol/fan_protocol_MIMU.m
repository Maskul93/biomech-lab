function angles = fan_protocol_MIMU(GAIT, CALIBRATION, POSTURE, STEP, fs)

% Tuning Parameters for KF
acc_noise = (6.78 * 10^(-7))^.5;
gyr_noise = (5.23 * 10^(-5))^.5;

% Build FUSE KF
FUSE = ahrsfilter('SampleRate', fs, 'AccelerometerNoise', acc_noise, ...
    'GyroscopeNoise', gyr_noise, 'OrientationFormat', 'Rotation matrix', ...
    'LinearAccelerationDecayFactor', .9,...
    'DecimationFactor', 12, 'GyroscopeDriftNoise', .0000001, ...
    'MagnetometerNoise', 1, 'LinearAccelerationNoise', .1, ...
    'MagneticDisturbanceNoise', 1, 'MagneticDisturbanceDecayFactor', .9,...
    'ExpectedMagneticFieldStrength', 10);

% Synchronize signals
GAIT = delete_zeros(GAIT); 

% Global RF
g_R_b = quat2rotm( get_q0( GAIT.CALI.acc, GAIT.CALI.mag) );

%% Functional Axis (for BOTH segments)
a_F = get_functional_axes(CALIBRATION, fs);   

% Shank Vertical Axis
a_v = unit( mean( POSTURE.SHAN.acc ) );

% Foot Long Axis
R_cali = quat2rotm( get_q0(POSTURE.CALI.acc, POSTURE.CALI.mag) );
R_foot = quat2rotm( get_q0(POSTURE.FOOT.acc, POSTURE.FOOT.mag) );
a_l = R_foot' * R_cali(:,1);

% Shank ACS
Z_sh = a_F;
X_sh = unit( cross( Z_sh, a_v ) );
Y_sh = unit( cross( Z_sh, X_sh ) );
R_sh = [X_sh', Y_sh', Z_sh'];

% Foot ACS
Z_ft = a_F;
Y_ft = unit( cross( a_l, Z_ft ) );
X_ft = unit( cross( Y_ft, Z_ft ) );
R_ft = [X_ft', Y_ft', Z_ft'];

%% Posture angles from STEP first sample
R0_sh = quat2rotm( get_q0( STEP.SHAN.acc, STEP.SHAN.mag ) ) * R_sh;
R0_ft = quat2rotm( get_q0( STEP.FOOT.acc, STEP.FOOT.mag ) ) * R_ft;

%% Fuse gait sensor data and orient them in the global
g_R_sh = multiprod( repmat(g_R_b, 1, 1, length(GAIT.SHAN.acc)/12 ), FUSE(GAIT.SHAN.acc, GAIT.SHAN.gyr, GAIT.SHAN.mag) );
g_R_ft = multiprod( repmat(g_R_b, 1, 1, length(GAIT.FOOT.acc)/12 ), FUSE(GAIT.FOOT.acc, GAIT.FOOT.gyr, GAIT.FOOT.mag) );

% Multiply for the corrected (ACS) posture matrices
PROX = permute( multiprod(g_R_sh, repmat( squeeze(R0_sh), 1, 1, size(g_R_sh, 3) ) ), [3 1 2] );
DIST = permute( multiprod(g_R_ft, repmat( squeeze(R0_ft), 1, 1, size(g_R_ft, 3) ) ), [3 1 2] );

%% Get Angles
angles = fanges(PROX, DIST);
angles_rb = fanges_rb(PROX, DIST);

angles(:,1) = detrend(angles(:,1));
angles(:,2) = detrend(angles(:,2));
angles(:,3) = detrend(angles(:,3));

end