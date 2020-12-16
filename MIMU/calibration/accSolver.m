% ## ---- AccSolver ---- ## %
% To solve the optimization problem such that the optimal offset and
% sensitivity can be found from the static ad hoc acquisition.
function [modG,J] = accSolver(x,VX,VY,VZ,G)
    for nn = 1:length(VX)
        modG(nn) = x(1)^2*(-x(4)+VX(nn))^2 + x(2)^2*(-x(5)+VY(nn))^2 +  x(3)^2*(-x(6)+VZ(nn))^2  - G^2;
        J(nn,:) = [2*x(1)*(-x(4) + VX(nn))^2  2*x(2)*(-x(5) + VY(nn))^2  2*x(3)*(-x(6) + VZ(nn))^2   x(1)^2*(2*x(4) - 2*VX(nn))  x(2)^2*(2*x(5) - 2*VY(nn))   x(3)^2*(2*x(6) - 2*VZ(nn)); ];
    end
end