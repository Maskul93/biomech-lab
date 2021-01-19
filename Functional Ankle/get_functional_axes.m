function [axis_sh_fun, axis_ft_fun] = get_functional_axes(D, side)
%% GET-FUNCTIONAL AXES
% Compute the main Ankle functional axis starting from functional
% calibration gyroscope measurements. Shank main functional axis
% computed exploiting the procedure proposed in [1] for the elbow joint
% -----------------------
% Created by Guido Mascia - PhD student at Univeristy of Rome "Foro
% Italico" (g.mascia@studenti.uniroma4.it)
% Creation date: 26/02/2020
% -----------------------
% INPUT:    · D = structure containing Accelerometer, Magnetometer, and
%             Gyroscope measurements during the functional calibration procedure
%             Each of the signals is a (N x 3) matrix, where N is the
%             number of samples;
%           · side = either 'L' or 'R'. Required to distinguish the
%             direction of the angular velocity vector which is opposite in
%             the two sides;
% OUTPUT:   · axis_ft_fun = Ankle main plantar-dorsiflexion functional axis
%             computed as the unitary mean angular velocity vector;
%           · axis_sh_fun = Shank main plantar-dorsiflexion functional axis
%             computed exploiting the procedure proposed in [1].
% -----------------------
% [1] Muller et al. - Alignment-Free, Self-Calibrating Elbow Angles Measurement using
% Inertial Sensors (2016)
% -----------------------

% Load Foot and Shank recordings
Foot = D.([side, 'F']);
Shank = D.([side, 'S']);

% Filtering Parameters
fs = 128;
[b,a] = butter(4,2/(fs/2), 'low');
beta = 0.001;
ts = [1 2];

% Filtered Foot Signal
FootGyroFilt = filtfilt(b,a,Foot.gyr);

% Threshold computation as the maximum of maxima
GyroSel_ft = FootGyroFilt;
threshold = max(max(GyroSel_ft));
threshold = threshold/2.5;  

% Check which is the main functional axis
maximum = max(GyroSel_ft);
[maximum2, column] = max(maximum);

% Select the the angular velocity frames above the threshold only
selected = GyroSel_ft(:,column) > threshold;
GyroSel2_ft = GyroSel_ft(selected,:);

GyroSel2_norm_ft = zeros(size(GyroSel2_ft));

for i = 1 : 3
    GyroSel2_norm_ft(:,i) = GyroSel2_ft(:,i)./magna(GyroSel2_ft);
end

% FOOT main functional axis expressed in the 
% MIMU technical reference frame -- g_a_ft
if side == 'R'
axis_ft_fun = unit(mean(GyroSel2_norm_ft)); 
end
if side == 'L'
    axis_ft_fun = -unit(mean(GyroSel2_norm_ft)); 
end

% Shank functional axis computation
ShankGyroFilt = filtfilt(b,a,Shank.gyr);
GyroSel_sh = ShankGyroFilt;

GyroSel2_sh = GyroSel_sh(selected,:);
GyroSel2_norm_sh = zeros(size(GyroSel2_sh));

% Compute relative orientation between the two frames -- ft_R_sh
[q0_sh] = get_q0(Shank.acc, Shank.mag);
[q0_ft] = get_q0(Foot.acc, Foot.mag);

sh_q_g = Madgwick2010(Shank, fs, beta, q0_sh');
ft_q_g = Madgwick2010(Foot, fs, beta, q0_ft');

sh_q_g = reshape_quaternion(sh_q_g, 'spin');
ft_q_g = reshape_quaternion(ft_q_g, 'spin');
sh_R_g = SpinConv('QtoDCM', sh_q_g);
ft_R_g = SpinConv('QtoDCM', ft_q_g);

g_R_sh = multitransp(sh_R_g, 1);
ft_R_sh = multiprod(ft_R_g, g_R_sh, [1 2]);
ft_R_sh = ft_R_sh(:,:,selected);

ft_w_sh = zeros(size(GyroSel2_norm_sh));

for i = 1 : length(GyroSel2_norm_sh)
   ft_w_sh(i,:) = - GyroSel2_ft(i,:) + ( ft_R_sh(:,:,i) * GyroSel2_sh(i,:)')'; 
end

for i = 1 : 3
    GyroSel2_norm_sh(:,i) = ft_w_sh(:,i)./magna(ft_w_sh);
end

% NaN control
for i = 1 : 3
    temp = GyroSel2_norm_sh(:,i);
    trues = temp(~isnan(temp));
    gg(:,i) = trues;
end

GyroSel2_norm_sh = gg;

if side == 'R'
axis_sh_fun = -unit(mean(GyroSel2_norm_sh));
end

if side == 'L'
    axis_sh_fun = unit(mean(GyroSel2_norm_sh));
end
end