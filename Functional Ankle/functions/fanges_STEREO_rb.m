function PDIEAA = fanges(TPROX,TDIST)
%% FAN-GES
% DESCRIPTION: this function computes the kinematic angles of the ankle 
% joint as it was defined in the 'FAN project'. The convention here used 
% is the one proposed by Grood and Suntay (1983). 
% 
% Notice that the rotations have different names, since the joint involved
% is not the knee as in (Grood and Suntay, 1983). It was decided to use 
% the nomenclature proposed in the ISB recommendations (Wu et al., 2002).
% Hence, the calcaneous vertical axis is chosen to be 'e3', whereas the
% tibia-fibula medial-lateral axis is chosen to be 'e1'. In turn, 'e2',
% i.e. the floating axis, is chosen to be perpendicular to both of them.
%
% Furthermore, because of the convention used as well as the experimental
% setup through which the MIMU where placed and oriented, the following
% convention must be taken into account:
%
%   · Tx = T(:,2,:); -- The x is the 2nd column of the input DCM
%   · Ty = T(:,3,:); -- The y is the 3rd column of the input DCM
%   · Tz = T(:,1,:); -- The z is the 1st column of the input DCM 
% 
% This convention holds for both proximal and distal segment. 
% ------------------------------------------------------------------------
% INPUT:
%   · TPROX (3 x 3 x N): proximal segment DCM expressed in the anatomical
%   reference frame. N is the samples number.
%   · TDIST (3 x 3 x N): distal segment DCM expressed in the anatomical
%   reference frame. N is the samples number.
% OUTPUT:
%   · PDIEAA (N x 3) [degrees]: kinematics angles. Notice that:
%       - 1st column = Plantarflexion-Dorsiflexion (-/+)
%       - 2nd column = Inversion-Eversion (+/-)
%       - 3rd column = Abduction-Adduction (+/-)
% ------------------------------------------------------------------------
% AUTHOR: Guido Mascia, MSc, PhD student at University of Rome "Foro
% Italico", g.mascia@studenti.uniroma4.it
% CREATION DATE: 19/03/2021
% LAST MODIFIED: 19/03/2021
% ------------------------------------------------------------------------

% % Build versors
e1 = multitransp(TPROX(:,:,1),2);   % Tibia-Fibula Medial-lateral Axis == Z
e3 = multitransp(TDIST(:,:,3),2);   % Calcaneous Vertical Axis == y
e2 = unit(cross(e3,e1,3),3);        % Floating Axis

% Plantar-Dorsiflexion (to be checked)
% sin (a) = -e2 · sh_v = -e2 · TPROX(:,:,2);
PD = rad2deg( asin(dot(-e3, multitransp(TPROX(:,:,2),2),3)) );

% Abduction-Adduction
AA = rad2deg( pi / 2 - acos(dot(e1,e3,3)) );

% Abduction-Adduction
% sin (gamma) = -e2 · i == -e2 · TDIST(:,:,1)
IE = rad2deg( asin( dot(e2, multitransp(TDIST(:,:,1), 2), 3)) ); 

% Store angles
PDIEAA = [PD IE AA];
end
