function angles = fan_protocol_STEREO(GAIT, CALIBRATION, POSTURE, STEP)

%% Functional Axis (for BOTH segments)
a_F = get_functional_axes_STEREO(CALIBRATION.G_R_FOOT);   

% Shank Vertical Axis
SHAN_POSTURE = mean_DCM(POSTURE.G_R_SHAN);
a_v = SHAN_POSTURE(:,2);

% Foot Long Axis
R_cali = mean_DCM(POSTURE.G_R_TABL);
R_foot = mean_DCM(POSTURE.G_R_FOOT);
a_l = -R_foot' * R_cali(:,3);

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
R0_sh = mean_DCM( STEP.G_R_SHAN ) * R_sh;
R0_ft = mean_DCM( STEP.G_R_FOOT ) * R_ft;

% Create proximal and distal segments 
PROX = permute( multiprod(GAIT.G_R_SHAN, repmat(R0_sh, 1, 1, size(GAIT.G_R_SHAN, 3) ) ), [3 1 2] );
DIST = permute( multiprod(GAIT.G_R_FOOT, repmat(R0_ft, 1, 1, size(GAIT.G_R_FOOT, 3) ) ), [3 1 2] );

angles = fanges_STEREO(PROX, DIST);
angles_rb = fanges_STEREO_rb(PROX, DIST);

end