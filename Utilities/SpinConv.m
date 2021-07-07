function OUTPUT = SpinConv(TYPES, INPUT, tol, ichk)
%SpinConv   Conversion from a rotation representation type to another
%
%   OUT = SpinConv(TYPES, IN, TOL, ICHK) converts a rotation representation
%   type (IN) to another (OUT). Supported conversion input/output types are
%   as follows:
%      1) Q      Rotation quaternions
%      2) EV     Euler vector and rotation angle (degrees)
%      3) DCM    Direction cosine matrix (a.k.a. rotation matrix)
%      4) EA###  Euler angles (12 possible sets) (degrees)
%   All representation types accepted as input (IN) and returned as output
%   (OUT) by SpinConv are meant to represent the rotation of a 3D
%   coordinate system (CS) relative to a rigid body or vector space
%   ("alias" transformation), rather than vice-versa ("alibi"
%   transformation).
% 
%   OUT=SpinConv(TYPES,IN) is equivalent to OUT=SpinConv(TYPES,IN,10*eps,1) 
%   OUT=SpinConv(TYPES,IN,TOL) is equiv. to OUT=SpinConv(TYPES,IN,TOL,1) 
%
%   Input and output arguments:
%
%      TYPES - Single string value that specifies both the input type and
%            the desired output type. The allowed values are:
%
%               'DCMtoEA###'      'DCMtoEV'      'DCMtoQ'     
%               'EA###toDCM'      'EA###toEV'    'EA###toQ'     
%               'EVtoDCM'         'EVtoEA###'    'EVtoQ'         
%               'QtoDCM'          'QtoEA###'     'QtoEV'        
%               'EA###toEA###' 
%                  
%            For cases that involve Euler angles, ### should be
%            replaced with the proper order desired. E.g., EA321
%            would be Z(yaw)-Y(pitch)-X(roll).
%
%      IN  - Array of N matrices or N vectors (N>0) corresponding to the
%            first entry in the TYPES string, formatted as follows:
%
%            DCM - (3×3×N) Array of rotation matrices. Each matrix R 
%                  contains in its rows the versors of the rotated CS
%                  represented in the original CS, and in its columns the
%                  versors of the original CS represented in the rotated
%                  CS. This format is typically used when the column-vector
%                  convention is adopted: point coordinates are arranged in
%                  column vectors Vi, and the desired rotation is applied
%                  by pre-multiplying Vi by R (rotated Vi = R * Vi).
%            EA### - [psi,theta,phi] (N×3) row vector list containing, in 
%                  each row, three Euler angles or Tait-Bryan angles.
%                  (degrees).
%            EV  - [m1,m2,m3,MU] (N×4) Row vector list containing, in each 
%                  row, the components (m1, m2, m3) of an Euler rotation
%                  vector (represented in the original CS) and the Euler
%                  rotation angle about that vector (MU, in degrees).
%            Q   - [q1,q2,q3,q4] (N×4) Row vector list defining, in each
%                  row, a rotation quaternion. q4 = cos(MU/2), where MU is
%                  the Euler angle.
%
%      TOL - (Default value: TOL = 10 * eps) Tolerance value for deviations
%            from 1. Used to test determinant of rotation matrices or
%            length of unit vectors.
%      ICHK - (Default value: ICHK = 1) Flag controlling whether 
%            near-singularity warnings are issued or not. 
%            ICHK = 0 disables warnings.  
%            ICHK = 1 enables them.
%      OUT - Array of N matrices or N vectors (N > 0) corresponding to the
%            second entry in the TYPES string, formatted as shown
%            above.
%
%   See also SpinCalc, degtorad, rad2deg.

% Version 2.2
% 2013 April 3
%
% Based on:
%    SpinCalc, Version 1.3 (MATLAB Central file #20696)
%    2009 June 30 
% SpinCalc code by:
%    John Fuller
%    National Institute of Aerospace
%    Hampton, VA 23666
%    John.Fuller@nianet.org
% Debugged and optimized for speed by:
%    Paolo de Leva
%    University "Foro Italico" 
%    Rome, Italy
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Setting default values for missing input arguments
switch nargin
    case 2, tol = .001; ichk = true;
    case 3, ichk = true;
    case 4
        if isequal(ichk, 0), ichk = false; 
        else                 ichk = true; 
        end
    otherwise, error(nargchk(2, 4, nargin)); % Allow 2 to 4 input arguments
end

% No TYPES string can be shorter than 4 or longer than 12 chars
    len = length(TYPES);
    if len>12 || len<4, error('Invalid entry for TYPES input string'); end

% Determine type of conversion from TYPES string
    TYPES = upper(TYPES);
    index = strfind(TYPES, 'TO');
    TYPE.INPUT  = TYPES(1 : index-1);
    TYPE.OUTPUT = TYPES(index+2 : len);
    fields = {'INPUT', 'OUTPUT'}; % 1×2 cell
    % Check validity of TYPES string, both for input and output
    for f = 1:2
       IO = fields{f};
       type = TYPE.(IO);
       switch type
           case {'Q' 'EV' 'DCM'} % Valid TYPE
           otherwise
               % Check that TYPE is 'EA###'
               if length(type)~=5 || ~strcmp(type(1:2), 'EA')
                   error('Invalid entry for TYPES input string')
               end
               TYPE.(IO) = 'EA';
               EAorder.(IO) = type(3:5);
               % Check that all characters in '###' are numbers between 1
               % and 3, and that no 2 consecutive characters are equal
               order31 = str2num(EAorder.(IO)'); % 3×1 double
               if isempty(order31) || any ([order31<1; order31>3]) || ...
                                            order31(1)==order31(2) || ...
                                            order31(2)==order31(3)
                   error('Invalid Euler angle order in TYPES string.')
               end
               % Type of EA sequence:
               %    1) Rotations about three distinct axes
               %    2) 1st and 3rd rotation about same axis
               if order31(1)==order31(3), EAtype.(IO) = 2; 
               else                       EAtype.(IO) = 1;
               end
        end
    end
    
% Set N (number of rotations) and check INPUT size
    [size1, size2, size3] = size(INPUT);
    switch TYPE.INPUT
       case 'DCM' % (3×3×N) Direction cosine matrix
           N = size3;
           isnot_DCM = false;
           if ndims(INPUT)>3 || N==0 || size1~=3 || size2~=3
               error('Invalid INPUT size (INPUT must be 3×3×N for DCM type)')
           end
        case 'EA', v_length=3; Isize='N×3'; isnot_DCM=true;
        case 'Q',  v_length=4; Isize='N×4'; isnot_DCM=true;
        case 'EV', v_length=4; Isize='N×4'; isnot_DCM=true;
    end
    if isnot_DCM
        N = size1;
        if ndims(INPUT)~=2 || N==0 || size2~=v_length
            error(['Invalid INPUT size (INPUT must be ' ...
                    Isize ' for ' TYPE.INPUT ' type)'])
        end
    end

% Determine the quaternions that uniquely describe the rotation prescribed
% by INPUT. OUTPUT will be calculated in the second portion of the code
% from these quaternions.
switch TYPE.INPUT
    
    case 'DCM'
        % NOTE: Orthogonal matrixes may have determinant -1 or 1
        %       DCMs are special orthogonal matrices, with determinant 1
        improper  = false;
        DCM_not_1 = false;
        if N == 1
            % Computing deviation from orthogonality
            delta = INPUT * INPUT' - eye(3); % DCM*DCM' - I
            delta = delta(:); % 9×1 <-- 3×3
            % Checking determinant of DCM
            DET = det(INPUT);
            if DET<0, improper=true; end
            if ichk && abs(DET-1)>tol, DCM_not_1=true; end 
            % Permuting INPUT
            INPUT = reshape(INPUT, [1 3 3]); % 1×3×3
        else
            % Computing deviation from orthogonality
            delta = multiprod(INPUT, multitransp(INPUT), [1 2]); % DCM*DCM'
            delta = bsxfun(@minus, delta, eye(3)); % Subtracting I
            delta = delta(:); % 9N×1 <-- 3×3×N
            % Checking determinant of DCMs
            DET = INPUT(1,1,:).*INPUT(2,2,:).*INPUT(3,3,:) -INPUT(1,1,:).*INPUT(2,3,:).*INPUT(3,2,:)...
                 +INPUT(1,2,:).*INPUT(2,3,:).*INPUT(3,1,:) -INPUT(1,2,:).*INPUT(2,1,:).*INPUT(3,3,:)...
                 +INPUT(1,3,:).*INPUT(2,1,:).*INPUT(3,2,:) -INPUT(1,3,:).*INPUT(2,2,:).*INPUT(3,1,:); % 1×1×N
            if any(DET<0), improper=true; end
            if ichk && any(abs(DET-1)>tol), DCM_not_1=true; end 
            % Permuting INPUT
            INPUT = permute(INPUT, [3 1 2]); % N×3×3            
        end
        % Issuing error messages or warnings
        if ichk && any(abs(delta)>tol)
            errordlg('Warning: Input DCM is not orthogonal.')
        end
        if improper, error('Improper input DCM'); end
        if DCM_not_1
            errordlg('Warning: Input DCM determinant off from 1 by more than tolerance.');
        end
        % Denominators for 4 distinct types of equivalent Q equations
        denom = [1 + INPUT(:,1,1) - INPUT(:,2,2) - INPUT(:,3,3),...
                 1 - INPUT(:,1,1) + INPUT(:,2,2) - INPUT(:,3,3),...
                 1 - INPUT(:,1,1) - INPUT(:,2,2) + INPUT(:,3,3),...
                 1 + INPUT(:,1,1) + INPUT(:,2,2) + INPUT(:,3,3)];
        denom = 2 .* sqrt (denom); % N×4
        % Choosing for each DCM the equation which uses largest denominator
        [maxdenom, index] = max(denom, [], 2); % N×1
        clear delta DET denom
        Q = NaN(N,4); % N×4
        % EQUATION 1
        ii = (index==1); % (Logical vector) MAXDENOM==DENOM(:,1)
        if any(ii)
            Q(ii,:) = [                         0.25 .* maxdenom(ii,1),... 
                       (INPUT(ii,1,2)+INPUT(ii,2,1)) ./ maxdenom(ii,1),...
                       (INPUT(ii,1,3)+INPUT(ii,3,1)) ./ maxdenom(ii,1),...
                       (INPUT(ii,2,3)-INPUT(ii,3,2)) ./ maxdenom(ii,1)];
        end
        % EQUATION 2
        ii = (index==2); % (Logical vector) MAXDENOM==DENOM(:,2)
        if any(ii)
            Q(ii,:) = [(INPUT(ii,1,2)+INPUT(ii,2,1)) ./ maxdenom(ii,1),...
                                                0.25 .* maxdenom(ii,1),...
                       (INPUT(ii,2,3)+INPUT(ii,3,2)) ./ maxdenom(ii,1),...
                       (INPUT(ii,3,1)-INPUT(ii,1,3)) ./ maxdenom(ii,1)];
        end
        % EQUATION 3
        ii = (index==3); % (Logical vector) MAXDENOM==DENOM(:,3)
        if any(ii)
            Q(ii,:) = [(INPUT(ii,1,3)+INPUT(ii,3,1)) ./ maxdenom(ii,1),...
                       (INPUT(ii,2,3)+INPUT(ii,3,2)) ./ maxdenom(ii,1),...
                                                0.25 .* maxdenom(ii,1),...
                       (INPUT(ii,1,2)-INPUT(ii,2,1)) ./ maxdenom(ii,1)];
        end
        % EQUATION 4
        ii = (index==4); % (Logical vector) MAXDENOM==DENOM(:,4)
        if any(ii)
            Q(ii,:) = [(INPUT(ii,2,3)-INPUT(ii,3,2)) ./ maxdenom(ii,1),...
                       (INPUT(ii,3,1)-INPUT(ii,1,3)) ./ maxdenom(ii,1),...
                       (INPUT(ii,1,2)-INPUT(ii,2,1)) ./ maxdenom(ii,1),...
                                                0.25 .* maxdenom(ii)];
        end
        clear INPUT maxdenom index ii
        
    case 'EV'
        % Euler vector (EV) and angle MU in degrees
        EV = INPUT(:,1:3); % N×3
        halfMU = INPUT(:,4) * (pi/360); % (N×1) MU/2 in radians
        % Check that input m's constitute unit vector
        delta = sqrt(sum(EV.*EV, 2)) - 1; % N×1
        if any(abs(delta) > tol)
            error('(At least one of the) input Euler vector(s) is not a unit vector')            
        end
        % Quaternion
        SIN = sin(halfMU); % (N×1)
        Q = [EV(:,1).*SIN, EV(:,2).*SIN, EV(:,3).*SIN, cos(halfMU)];
        clear EV delta halfMU SIN
        
    case 'EA'
        % Identify singularities (2nd Euler angle out of range)
        theta = INPUT(:, 2); % N×1
        if EAtype.INPUT == 1
            % Type 1 rotation (rotations about three distinct axes)
            if any(abs(theta)>=90)
                error('Second input Euler angle(s) outside -90 to 90 degree range')
            elseif ichk && any(abs(theta)>88)
                errordlg(['Warning: Second input Euler angle(s) near a '...
                          'singularity (-90 or 90 degrees).'])
            end
        else 
            % Type 2 rotation (1st and 3rd rotation about same axis)
            if any(theta<=0 | theta>=180)
                error('Second input Euler angle(s) outside 0 to 180 degree range')
            elseif ichk && any(theta<2 | theta>178)
                errordlg(['Warning: Second input Euler angle(s) near a '...
                          'singularity (0 or 180 degrees).'])
            end
        end
        % Half angles in radians
        HALF = INPUT * (pi/360); % N×3
        Hpsi   = HALF(:,1); % N×1
        Htheta = HALF(:,2); % N×1
        Hphi   = HALF(:,3); % N×1
        % Pre-calculate cosines and sines of the half-angles for conversion.
        c1=cos(Hpsi); c2=cos(Htheta); c3=cos(Hphi);
        s1=sin(Hpsi); s2=sin(Htheta); s3=sin(Hphi);
        c13 =cos(Hpsi+Hphi);  s13 =sin(Hpsi+Hphi);
        c1_3=cos(Hpsi-Hphi);  s1_3=sin(Hpsi-Hphi);
        c3_1=cos(Hphi-Hpsi);  s3_1=sin(Hphi-Hpsi);
        clear HALF Hpsi Htheta Hphi
        switch EAorder.INPUT
            case '121', Q=[c2.*s13,  s2.*c1_3, s2.*s1_3, c2.*c13];
            case '232', Q=[s2.*s1_3, c2.*s13,  s2.*c1_3, c2.*c13];
            case '313', Q=[s2.*c1_3, s2.*s1_3, c2.*s13,  c2.*c13];
            case '131', Q=[c2.*s13,  s2.*s3_1, s2.*c3_1, c2.*c13];
            case '212', Q=[s2.*c3_1, c2.*s13,  s2.*s3_1, c2.*c13];
            case '323', Q=[s2.*s3_1, s2.*c3_1, c2.*s13,  c2.*c13];
            case '123', Q=[s1.*c2.*c3+c1.*s2.*s3, c1.*s2.*c3-s1.*c2.*s3, c1.*c2.*s3+s1.*s2.*c3, c1.*c2.*c3-s1.*s2.*s3];
            case '231', Q=[c1.*c2.*s3+s1.*s2.*c3, s1.*c2.*c3+c1.*s2.*s3, c1.*s2.*c3-s1.*c2.*s3, c1.*c2.*c3-s1.*s2.*s3];
            case '312', Q=[c1.*s2.*c3-s1.*c2.*s3, c1.*c2.*s3+s1.*s2.*c3, s1.*c2.*c3+c1.*s2.*s3, c1.*c2.*c3-s1.*s2.*s3];
            case '132', Q=[s1.*c2.*c3-c1.*s2.*s3, c1.*c2.*s3-s1.*s2.*c3, c1.*s2.*c3+s1.*c2.*s3, c1.*c2.*c3+s1.*s2.*s3];
            case '213', Q=[c1.*s2.*c3+s1.*c2.*s3, s1.*c2.*c3-c1.*s2.*s3, c1.*c2.*s3-s1.*s2.*c3, c1.*c2.*c3+s1.*s2.*s3];
            case '321', Q=[c1.*c2.*s3-s1.*s2.*c3, c1.*s2.*c3+s1.*c2.*s3, s1.*c2.*c3-c1.*s2.*s3, c1.*c2.*c3+s1.*s2.*s3];
        otherwise
            error('Invalid input Euler angle order (TYPES string)');            
        end
        clear c1 c2 c3 s1 s2 s3 c13 s13 c1_3 s1_3 c3_1 s3_1

    case 'Q'
        if ichk && any(abs(sqrt(sum(INPUT.*INPUT, 2)) - 1) > tol)
            errordlg('Warning: (At least one of the) Input quaternion(s) is not a unit vector')
        end
        Q = INPUT;
end
clear TYPE.INPUT EAorder.INPUT

% Normalize quaternion(s) in case of deviation from unity. 
% User has already been warned of deviation.
Qnorms = sqrt(sum(Q.*Q,2));
Q = [Q(:,1)./Qnorms, Q(:,2)./Qnorms, Q(:,3)./Qnorms, Q(:,4)./Qnorms]; % N×4

switch TYPE.OUTPUT
    
    case 'DCM'
        Q  = reshape(Q', [1 4 N]); % (1×4×N)
        SQ = Q.^2;
        OUTPUT = [   SQ(1,1,:)-SQ(1,2,:)-SQ(1,3,:)+SQ(1,4,:),  2.*(Q(1,1,:).*Q(1,2,:) +Q(1,3,:).*Q(1,4,:)), 2.*(Q(1,1,:).*Q(1,3,:) -Q(1,2,:).*Q(1,4,:));
                  2.*(Q(1,1,:).*Q(1,2,:) -Q(1,3,:).*Q(1,4,:)),   -SQ(1,1,:)+SQ(1,2,:)-SQ(1,3,:)+SQ(1,4,:),  2.*(Q(1,2,:).*Q(1,3,:) +Q(1,1,:).*Q(1,4,:));
                  2.*(Q(1,1,:).*Q(1,3,:) +Q(1,2,:).*Q(1,4,:)), 2.*(Q(1,2,:).*Q(1,3,:) -Q(1,1,:).*Q(1,4,:)),   -SQ(1,1,:)-SQ(1,2,:)+SQ(1,3,:)+SQ(1,4,:)];
    
    case 'EV'
        % Angle MU in radians and sine of MU/2
        halfMUrad = atan2( sqrt(sum(Q(:,1:3).*Q(:,1:3),2)), Q(:,4) ); % N×1
        SIN = sin(halfMUrad); % N×1
        index = (SIN==0); % (N×1) Logical index
        if any(index)
            % Initializing
            OUTPUT = zeros(N,4);
            % Singular cases (MU is zero degrees)
            OUTPUT(index, 1) = 1;
            % Non-singular cases
            SIN = SIN(~index, 1);
            OUTPUT(~index, :) = [Q(~index,1) ./ SIN, ...
                                 Q(~index,2) ./ SIN, ...
                                 Q(~index,3) ./ SIN, ...
                                 halfMUrad .* (360/pi)];
        else
            % Non-singular cases            
            OUTPUT = [Q(:,1)./SIN, Q(:,2)./SIN, Q(:,3)./SIN, halfMUrad.*(360/pi)];
        end
        % MU greater than 180 degrees
        index = (OUTPUT(:,4) > 180); % (N×1) Logical index
        OUTPUT(index, :) = [-OUTPUT(index,1:3), 360-OUTPUT(index,4)];

    case 'EA'
        SQ = Q.^2;
        switch EAorder.OUTPUT
        case '121'
            OUTPUT = [atan2(Q(:,1).*Q(:,2) +Q(:,3).*Q(:,4), Q(:,2).*Q(:,4)-Q(:,1).*Q(:,3)),...
                      acos(SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3)),...
                      atan2(Q(:,1).*Q(:,2) -Q(:,3).*Q(:,4), Q(:,1).*Q(:,3)+Q(:,2).*Q(:,4))];
        case '232'
            OUTPUT = [atan2(Q(:,1).*Q(:,4) +Q(:,2).*Q(:,3), Q(:,3).*Q(:,4)-Q(:,1).*Q(:,2)),...
                      acos(SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3)),...
                      atan2(Q(:,2).*Q(:,3) -Q(:,1).*Q(:,4), Q(:,1).*Q(:,2)+Q(:,3).*Q(:,4))];
        case '313'
            OUTPUT = [atan2(Q(:,1).*Q(:,3) +Q(:,2).*Q(:,4), Q(:,1).*Q(:,4)-Q(:,2).*Q(:,3)),...
                      acos(SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3)),...
                      atan2(Q(:,1).*Q(:,3) -Q(:,2).*Q(:,4), Q(:,1).*Q(:,4)+Q(:,2).*Q(:,3))];
        case '131'
            OUTPUT = [atan2(Q(:,1).*Q(:,3) -Q(:,2).*Q(:,4), Q(:,1).*Q(:,2)+Q(:,3).*Q(:,4)),...
                      acos(SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3)),...
                      atan2(Q(:,1).*Q(:,3) +Q(:,2).*Q(:,4), Q(:,3).*Q(:,4)-Q(:,1).*Q(:,2))];
        case '212'
            OUTPUT = [atan2(Q(:,1).*Q(:,2) -Q(:,3).*Q(:,4), Q(:,1).*Q(:,4)+Q(:,2).*Q(:,3)),...
                      acos(SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3)),...
                      atan2(Q(:,1).*Q(:,2) +Q(:,3).*Q(:,4), Q(:,1).*Q(:,4)-Q(:,2).*Q(:,3))];
        case '323'
            OUTPUT = [atan2(Q(:,2).*Q(:,3) -Q(:,1).*Q(:,4), Q(:,1).*Q(:,3)+Q(:,2).*Q(:,4)),...
                      acos(SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3)),...
                      atan2(Q(:,1).*Q(:,4) +Q(:,2).*Q(:,3), Q(:,2).*Q(:,4)-Q(:,1).*Q(:,3))];
        case '123'
            OUTPUT = [atan2(2.*(Q(:,1).*Q(:,4)-Q(:,2).*Q(:,3)), SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3)),...
                       asin(2.*(Q(:,1).*Q(:,3)+Q(:,2).*Q(:,4))),...
                      atan2(2.*(Q(:,3).*Q(:,4)-Q(:,1).*Q(:,2)), SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3))];
        case '231'
            OUTPUT = [atan2(2.*(Q(:,2).*Q(:,4)-Q(:,1).*Q(:,3)), SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3)),...
                       asin(2.*(Q(:,1).*Q(:,2)+Q(:,3).*Q(:,4))),...
                      atan2(2.*(Q(:,1).*Q(:,4)-Q(:,3).*Q(:,2)), SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3))];
        case '312'
            OUTPUT = [atan2(2.*(Q(:,3).*Q(:,4)-Q(:,1).*Q(:,2)), SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3)),...
                       asin(2.*(Q(:,1).*Q(:,4)+Q(:,2).*Q(:,3))),...
                      atan2(2.*(Q(:,2).*Q(:,4)-Q(:,3).*Q(:,1)), SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3))];
        case '132'
            OUTPUT = [atan2(2.*(Q(:,1).*Q(:,4)+Q(:,2).*Q(:,3)), SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3)),...
                       asin(2.*(Q(:,3).*Q(:,4)-Q(:,1).*Q(:,2))),...
                      atan2(2.*(Q(:,1).*Q(:,3)+Q(:,2).*Q(:,4)), SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3))];
        case '213'
            OUTPUT = [atan2(2.*(Q(:,1).*Q(:,3)+Q(:,2).*Q(:,4)), SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3)),...
                       asin(2.*(Q(:,1).*Q(:,4)-Q(:,2).*Q(:,3))),...
                      atan2(2.*(Q(:,1).*Q(:,2)+Q(:,3).*Q(:,4)), SQ(:,4)-SQ(:,1)+SQ(:,2)-SQ(:,3))];
        case '321'
            OUTPUT = [atan2(2.*(Q(:,1).*Q(:,2)+Q(:,3).*Q(:,4)), SQ(:,4)+SQ(:,1)-SQ(:,2)-SQ(:,3)),...
                       asin(2.*(Q(:,2).*Q(:,4)-Q(:,1).*Q(:,3))),...
                      atan2(2.*(Q(:,1).*Q(:,4)+Q(:,3).*Q(:,2)), SQ(:,4)-SQ(:,1)-SQ(:,2)+SQ(:,3))];
        otherwise
            error('Invalid output Euler angle order (TYPES string).');
        end
        OUTPUT = OUTPUT * (180/pi); % (N×3) Euler angles in degrees
        theta  = OUTPUT(:,2);       % (N×1) Angle THETA in degrees
        % Check OUTPUT
        if any(~isreal( OUTPUT(:) ))
	        error('SpinConv:Unreal', ...
                 ['Unreal Euler output. Input resides too close to singularity.\n' ...
                  'Please choose different output type.'])
        end
        % Type 1 rotation (rotations about three distinct axes)
        % THETA is computed using ASIN and ranges from -90 to 90 degrees
        if EAtype.OUTPUT == 1
	        singularities = abs(theta) > 89.9; % (N×1) Logical index
	        if any(singularities)
                firstsing = find(singularities, 1); % (1×1)
		        error(['Input rotation # %s resides too close to Type 1 Euler singularity.\n' ...
                       'Type 1 Euler singularity occurs when second angle is -90 or 90 degrees.\n' ...
                       'Please choose different output type.'], num2str(firstsing));
	        end
        % Type 2 rotation (1st and 3rd rotation about same axis)
        % THETA is computed using ACOS and ranges from 0 to 180 degrees
        else
	        singularities = theta<0.1 | theta>179.9; % (N×1) Logical index
	        if any(singularities)
                firstsing = find(singularities, 1); % (1×1)
		        error(['Input rotation # %s resides too close to Type 2 Euler singularity.\n' ...
                       'Type 2 Euler singularity occurs when second angle is 0 or 180 degrees.\n' ...
                       'Please choose different output type.'], num2str(firstsing));
	        end
        end

    case 'Q'
        OUTPUT = Q;
end