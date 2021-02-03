function FEAAIE = multiges(TPROX,TDIST,side,joi);
%FEAAIE = multiges(TPROX,TDIST,side,joi);
%----------------------------------------------------------------------
% INPUT:
% TPROX (NFx3x3) &
% TDIST (NFx3x3)= rotation matrixes of the rotation from the Local to the Global CS
%               
% side        = body side     : 0=right;   1=left => 1 changes the sign of AA and IE
% joi         = type of joint : 0=hip ankle => 0 -- like 1=knee changes the sign of FE
%               (0,0 means right hip!)
%---------------------------------------------------------------------
% OUTPUT:
% FEAAIE(NFx3)= matrix of the 3 angles (FE IE AA) in all the NF frames [deg]
%               They mean Fl/Ex Ab/Ad In/Ex if the input matrix are oriented with
%               y longitudinal (DIST pointing the PROX; x antero-post; z lat-med)
%----------------------------------------------------------------------
% VARIABLES:
% NF  (1x1)   =number of columns of TPROX
% e1  (NFx3)  =Z axis in the proximal segment
% e3  (NFx3)  =Y axis in the distal   segment
% e2  (NFx3)  =  floating axis
% FE  (NFx1)  =angle of flex-extension (rotation about e1)
% AA  (NFx1)  =angle of abd-adduction  (rotation about e2)
% IE  (NFx1)  =angle of inter-exter rot(rotation about e3)
%----------------------------------------------------------------------
% NOTES:
% It uses function atan2 to well calculate the angles not in (-pi/2,pi/2)
% The angular convention is chosen according to Grood et Suntay:
% Flexion(+),Extension(-); Abduction(+),Adduction(-); External(+),Internal(-)
%----------------------------------------------------------------------
% Ref.: Grood et Suntay A joint coordinate system for the clinical description of three- -JCS
%                         dimensional motion: application to the knee
%                         J Biomech. Engng 1983 105: 136-144

% Auth: A Leardini 31/1/92, modified Donati,modified Cereatti

e2a = multitransp(TDIST(:,:,2),2);  % prendo la y di foot
e2b = multitransp(TPROX(:,:,3),2);  % prendo la z di shank
e2 = unit(cross(e2a,e2b,3),3);      % crosso ed esce la x 
e2zd = dot(e2,-multitransp(TDIST(:,:,3),2),3);   %% dot(e2,-multitransp(TDIST(:,:,3),2),3);
e2xd = dot(e2,multitransp(TDIST(:,:,1),2),3);  %% dot(e2,multitransp(TDIST(:,:,1),2),3);

% Internal-External Rotation
IE(:,1) = -atan2(e2zd,e2xd); % Di quanto ha ruotato intorno all'asse y (slide 45) -- flottante xd2 

e2yp = dot(e2,multitransp(TPROX(:,:,2),2),3);   %% dot(e2,multitransp(TPROX(:,:,2),2),3); 
e2xp = dot(e2,multitransp(TPROX(:,:,1),2),3);  %% dot(e2,multitransp(TPROX(:,:,1),2),3);

% Flexion-Extension
FE(:,1) = atan2(e2yp,e2xp);
bet = dot(e2a,e2b,3);
% Ab-Adduction
AA(:,1) = acos(bet)-pi/2;

if side==1,IE=-IE;AA=-AA;end;
if joi ==1,FE=-FE;end;
% results in degrees
FEAAIE=[FE,AA,IE]*180/pi;
%FEAAIE = [rad2deg(e2yp), rad2deg(bet), rad2deg(e2zd)];

% function FEAAIE = multiges(TPROX,TDIST,side,joi);
%FEAAIE = multiges(TPROX,TDIST,side,joi);
% %----------------------------------------------------------------------
% % INPUT:
% % TPROX (NFx3x3) &
% % TDIST (NFx3x3)= rotation matrixes of the rotation from the Local to the Global CS
% %               
% % side        = body side     : 0=right;   1=left => 1 changes the sign of AA and IE
% % joi         = type of joint : 0=hip ankle => 0 -- like 1=knee changes the sign of FE
% %               (0,0 means right hip!)
% %---------------------------------------------------------------------
% % OUTPUT:
% % FEAAIE(NFx3)= matrix of the 3 angles (FE IE AA) in all the NF frames [deg]
% %               They mean Fl/Ex Ab/Ad In/Ex if the input matrix are oriented with
% %               y longitudinal (DIST pointing the PROX; x antero-post; z lat-med)
% %----------------------------------------------------------------------
% % VARIABLES:
% % NF  (1x1)   =number of columns of TPROX
% % e1  (NFx3)  =Z axis in the proximal segment
% % e3  (NFx3)  =Y axis in the distal   segment
% % e2  (NFx3)  =  floating axis
% % FE  (NFx1)  =angle of flex-extension (rotation about e1)
% % AA  (NFx1)  =angle of abd-adduction  (rotation about e2)
% % IE  (NFx1)  =angle of inter-exter rot(rotation about e3)
% %----------------------------------------------------------------------
% % NOTES:
% % It uses function atan2 to well calculate the angles not in (-pi/2,pi/2)
% % The angular convention is chosen according to Grood et Suntay:
% % Flexion(+),Extension(-); Abduction(+),Adduction(-); External(+),Internal(-)
% %----------------------------------------------------------------------
% % Ref.: Grood et Suntay A joint coordinate system for the clinical description of three- -JCS
% %                         dimensional motion: application to the knee
% %                         J Biomech. Engng 1983 105: 136-144
% 
% % Auth: A Leardini 31/1/92, modified Donati,modified Cereatti
% 
% e2a = multitransp(TDIST(:,:,2),2);  % prendo la y di foot
% e2b = multitransp(TPROX(:,:,3),2);  % prendo la z di shank
% e2 = unit(cross(e2a,e2b,3),3);      % crosso ed esce la x 
% e2zd = dot(e2,-multitransp(TDIST(:,:,3),2),3);
% e2xd = dot(e2,multitransp(TDIST(:,:,1),2),3);
% % Internal-External Rotation
% IE(:,1) = -atan2(e2zd,e2xd); % Di quanto ha ruotato intorno all'asse y (slide 45) -- flottante xd2 
% e2yp = dot(e2,multitransp(TPROX(:,:,2),2),3);  % QUESTO ERA COL +!
% e2xp = dot(e2,multitransp(TPROX(:,:,1),2),3);
% % Flexion-Extension
% FE(:,1) = atan2(e2yp,e2xp);
% bet = dot(e2a,e2b,3);
% % Ab-Adduction
% AA(:,1) = acos(bet)-pi/2;
% 
% if side==1,IE=-IE;AA=-AA;end;
% if joi ==1,FE=-FE;end;
% % results in degrees
% FEAAIE=[FE,AA,IE]*180/pi;