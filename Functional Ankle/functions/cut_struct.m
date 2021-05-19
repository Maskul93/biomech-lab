function Ds = cut_struct(D, ti, tf)


substructs = fieldnames(D);

for sb = 1 : length(substructs)
    s = char(substructs(sb));
    
    Ds.(s).acc = D.(s).acc(ti:tf,:);
    Ds.(s).gyr = D.(s).gyr(ti:tf,:);
    Ds.(s).mag = D.(s).mag(ti:tf,:);
    

end

end