function [q_new] = reshape_quaternion(q, syn)
%% RESHAPE-QUATERNION
% Reshapes the input quaternion to be coherent with either the 'SpinConv'
% or the 'Madgwick2010' synthax changing the position of the scalar
% component of the input quaternion
% ------------
% INPUT:    · q = quaternion to be reshaped (N x M);
%           · syn = string containing the required output syntax
%               ## -- 'spin' = [q0 q1 q2 q3] --> [q1 q2 q3 q0];
%               ## -- 'mad' = [q1 q2 q3 q0] --> [q0 q1 q2 q3];
% OUTPUT:   · q_new = reshaped quaternion according to 'syn' (N x 4) 
% ------------
% Author: Guido Mascia - PhD student at Unverisity of Rome "Foro Italico"
% (g.mascia@studenti.uniroma4.it)
% Creation Date: 05/03/2020
% ------------

% Check whether the input is a square matrix
if size(q, 1) == size(q, 2)
    ms1 = 'The input is 4x4, hence it is impossible to know what the actual quaternion.';
    ms2 = ' The input cannot be a square matrix!';
    msg = [ms1 ms2];
    error(msg)
end

% Check dimensions and reshape if necessary (must be N x 4)
if size(q, 1) == 4
    q = q';
end

switch syn
    case 'spin'
        q_new = [q(:, 2:4), q(:, 1)];
    case 'mad'
        q_new = [q(:, 4), q(:, 1:3)];
end
end