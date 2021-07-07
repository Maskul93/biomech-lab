function [offs, sens] = get_acc_calib(acc)
%% GET ACCELEROMETER CALIBRATION PARAMETERS
% This function compute the accelerometer 'offset' and 'sensitivity' for a
% given calibration trial. Such trial consisted in ad hoc acquisitions in
% which the accelerometer is aligned with gravity in both positive and
% negative sense. Thus, it is assumed that different portions of the
% measure correspond to different alignments. 
% ------------------------------------------------------------------------
% INPUT:
%   · acc [N x 3] = acclerometer static acquisition [m/s²]
% ------------------------------------------------------------------------
% OUTPUT:
%   · offs [1 x 3] = accelerometer offset [m/s²]
%   · sens [1 x 3] = accelerometer sensitivity [m/s²]
% ------------------------------------------------------------------------
% AUTHOR: Andrea Mannini (2012)
% ADAPTED: Guido Mascia, PhD student at University of Rome "Foro Italico"
% CREATION DATE: 16/12/2020
% LAST MODIFIED: 16/12/2020
% ------------------------------------------------------------------------

    acc = acc/9.81; % The solver requires data expressed in [g]
    x = get_static_acc_windows(acc);
    Nr_statics = length(x);
    g = 1;
    
    for i = 1 : Nr_statics
       
        Vx(i) = mean(acc(x(1,i):x(2,i),1));
        Vy(i) = mean(acc(x(1,i):x(2,i),2));
        Vz(i) = mean(acc(x(1,i):x(2,i),3));

    end
    
    opts = optimoptions(@fsolve,'Algorithm', 'levenberg-marquardt');
    X = fsolve(@accSolver, [1 1 1 0 0 0], optimset('jacobian','on', 'Algorithm', 'levenberg-marquardt'), Vx, Vy, Vz, g);
    offs = X(4:6);
    sens = X(1:3);
 
end
