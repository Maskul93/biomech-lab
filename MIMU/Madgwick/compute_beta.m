function beta = compute_beta(gyro)
%% COMPUTE-BETA
% This function computes the ß parameter for the Madgwick filter. ß is the
% gyroscope measurement error expressed as the magnitude of a quaternion
% derivative:
% ------------- ß = sqrt( 0.75 * w_max ) -------------
% 
% where w_max is the maximum gyroscope error. It is computed as the
% standard deviation of the angular velocity measured during a static phase
% -------------
% INPUT:    · gyro = gyroscope measurement during a static phase (N x 3);
% OUTPUT:   · beta = Madgwick parameter (1 x 1).
% -------------
% Creation date: 03/03/2020
% Author: Guido Mascia, PhD student at University of Rome "Foro Italico"
% (g.mascia@studenti.uniroma4.it)
% -------------

w_max = max(std(gyro));
beta = sqrt( 0.75 ) * w_max;
end 