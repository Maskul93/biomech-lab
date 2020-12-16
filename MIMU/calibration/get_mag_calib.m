function [bias, scale_factor] = get_mag_calib(mag)
%% GET MAGNETOMETER CALIBRATION PARAMETERS
% This function compute the magnetometer 'bias' and 'scale_factor' for a
% given calibration trial. Such trial consisted in moving the MIMU such 
% that a sphere was drawn in the space. As a rule of thumb, a couple of
% minutes of "sphere drawing" would give a good estimate of the two
% calibration parameters.
% ------------------------------------------------------------------------
% INPUT:
%   · mag [N x 3] = magnetometer sphere acquisition [µT]
% ------------------------------------------------------------------------
% OUTPUT:
%   · bias [1 x 3] = magnetometer bias for each axis [µT]
%   · scale_factor [1 x 3] = magnetometer scale factor for each axis [µT]
% ------------------------------------------------------------------------
% AUTHOR: Angelo Maria Sabatini and Gabriele Ligorio (2014)
% ADAPTED: Guido Mascia, PhD student at University of Rome "Foro Italico"
% CREATION DATE: 16/12/2020
% LAST MODIFIED: 16/12/2020
% ------------------------------------------------------------------------
    
    % Delete first and last 100 samples
    mag = mag(101:end-99, :)';   
    h = mean(mag(:, 1:5), 2);
    hnorm = norm(h);

    % Two-step non-linear estimation technique applied to normalized data
    mn    = mag./hnorm;
    N     = size(mn, 2);
    Am    = zeros(N, 6);
    bm    = zeros(N, 1);

    for i = 1:N
        Am(i, :) = [-2*mn(1, i) mn(2, i)^2 -2*mn(2, i) mn(3, i)^2 -2*mn(3, i) 1];
        bm(i)    = -mn(1, i)^2;
    end

    z  = pinv(Am)*bm;

    bmest(1) = z(1);
    k2       = z(2);
    bmest(2) = z(3)/k2;
    k3       = z(4);
    bmest(3) = z(5)/k3;
    k4       = z(6);
    k1       = z(1)^2 + z(2)*bmest(2)^2 + z(4)*bmest(3)^2 - k4;
    kmest(1) = sqrt(k1);
    kmest(2) = sqrt(k1/k2);
    kmest(3) = sqrt(k1/k3);
    
    % Get 'bias' and 'scale_factor'
    bmest    = bmest(:).*hnorm;
    kmest    = kmest(:)./kmest(1);

    bias = bmest'; scale_factor = kmest';

end