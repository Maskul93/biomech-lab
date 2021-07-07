function [Ds, Nf, Nf2] = delete_zeros(D)

x = D.CALI.acc(:,1);
substructs = fieldnames(D);

N = length(x);
xf = x(end);

for i = N : -1 : 1
    
    if x(i) ~= xf
        Nf = i;
        break
    end
    
end

Nf2 = round(Nf/12);
Ni = N - Nf;

for sb = 1 : length(substructs)
    s = char(substructs(sb));
    
    Ds.(s).acc = [D.(s).acc(1:Ni,:); D.(s).acc(1:Nf,:)];
    Ds.(s).gyr = [D.(s).gyr(1:Ni,:); D.(s).gyr(1:Nf,:)];
    Ds.(s).mag = [D.(s).mag(1:Ni,:); D.(s).mag(1:Nf,:)];

end