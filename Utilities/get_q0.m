function [t_q0_g] = get_q0(a, h)
%% GET-Q0
% This method estimates the 3D MIMU orientation with respect to a 
% Gravity-Magnetic North global reference frame of the North-East-Down
% (NED) type. The required measurements are the ones coming from the 
% accelerometer and the magnetometer. Notice that the pose estimate does
% not depend on the measurement unit. Since this method should be used to 
% estimate the initial orientation of the MIMU, is recommended to use as 
% input signals the first recorded sample.
% ---------------
% Created by: Guido Mascia - PhD student at University of Rome "Foro
% Italico" (g.mascia@studenti.uniroma4.it)
% Creation date: 02/03/2020
% Modified: 22/12/2020
% ---------------
% INPUT:    · a = accelerometer measurement (3 x N);
%           · h = magnetometer measurement (3 x N);
% OUTPUT:   · t_q0_g = initial orientation (4 x 1). The scalar component
%             is chosen to be at the 1st column. Hence, if this orientation 
%             is required as initial condition for Madgwick, is good as it is!
% ---------------
% REFERENCES
% [1] I. Bar-Itzhack and Y. Oshman, “Attitude determination from vector 
% observations: Quaternion estimation” (1981)
% ---------------

a = a(1,:)';
h = h(1,:)';
    
a_t = a/norm(a); % technical acceleration
h_t = h/norm(h); % technical magnetic field

a_n = [0 0 1]'; % navigation acceleration

h_n_tmp = [ norm( [ h_t(1); - h_t(2)] ); ...
            0; ...
            - h_t(3)];
        
h_n = h_n_tmp/norm(h_n_tmp); % navigation magnetic field

% -- Triad generations [1]
r1 = a_n;
r2 = cross(r1, h_n)/norm(cross(r1, h_n));
r3 = cross(r1, r2);
N_R_g = [r1 r2 r3]; 

s1 = a_t;
s2 = cross(s1, h_t)/norm(cross(s1, h_t));
s3 = cross(s1, s2);
T_R_g = [s1 s2 s3];

T_R_N = T_R_g * N_R_g';
t_q0_g = rotm2quat(T_R_N'); % q0 = [W x y z] -- W = scalar component
end