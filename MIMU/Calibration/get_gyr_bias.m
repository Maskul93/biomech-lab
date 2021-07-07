function bias = compute_gyr_bias(gyr)
%% GET GYROSCOPE BIAS
% This function compute the gyroscope bias from a static recording of N samples
% It is suggested to acquire at least a couple of minutes of data to get a
% consistent estimate of the gyroscope bias.
% ------------------------------------------------------------------------
% INPUT:
%   · gyr [N x 3] = gyroscope static acquisition [rad/s]
% ------------------------------------------------------------------------
% OUTPUT:
%   · bias [1 x 3] = gyroscope bias for each axis [rad/s]
% ------------------------------------------------------------------------
% AUTHOR: Guido Mascia, PhD student at University of Rome "Foro Italico"
% CREATION DATE: 16/12/2020
% LAST MODIFIED: 16/12/2020
% ------------------------------------------------------------------------

    bias = mean(gyr);

end