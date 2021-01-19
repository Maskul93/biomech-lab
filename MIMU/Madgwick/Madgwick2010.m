function [qbn_mad] = Madgwick2010(opal, f, b , qo)

% Madgwick2010     Estimate the orientation of an MIMU given its signals
%                  measured in the MIMU local reference frame and using the
%                  algorithm porposed by Madgwick et al. (2011).
% 
% INPUT            opal: structure array with three fields: 
%                  gyro (3-by-N): angular velocity signal (rad/s)
%                  mag  (3-by-N): magnetometer signal (Gauss)
%                  acc  (3-by-N): linear acceleration signal (m/s^2)
%                  f (1-by-1): sampling frequency
%                  b (1-by-1): input parameter (see Madgwick et al. (2011)
%                              for details). For Opal units during walking,
%                              b = .1
%                  q0 (1-by-4): quaternion representing the initial
%                               conditions. The scalar part is in the first
%                               component. Use q0 = [1 0 0 0] if initial
%                               conditions are not available
% 
% OUTPUT           qbn_mad (4-by-N): quaternions representing the 3-D
%                  orientation of the Global reference frame with respect 
%                  to the MIMU local frame (L_q_G) 
% 
% 
% Authors: Gabriele Ligorio (Scuola Superiore Sant’Anna Pisa - Sept 2013)
%          Elena Bergamini (University of Rome "Foro Italico" - Sept 2013)


Gyroscope = opal.gyr;
Accelerometer = opal.acc;
Magnetometer = opal.mag;
len=length(Gyroscope);
% last=length(Gyroscope)/f;
% time=(linspace(0,last,length(Gyroscope)))';


%% run Madgwick and/or Mahony algorithms

AHRS = MadgwickAHRS('SamplePeriod', 1/f, 'Beta', b);
 
% AHRS = MahonyAHRS('SamplePeriod', 1/f, 'Kp', 0.5);

qbn_mad = zeros(len, 4);
for t = 1:len
    
    gyr_t = Gyroscope(t,:);
    mag_t = Magnetometer(t,:);
    acc_t = Accelerometer(t,:);
    

    AHRS.Update(gyr_t,acc_t,mag_t*100);

    
    qbn_mad(t, :) = AHRS.Quaternion;
    
end

