
function D = get_trident(filename)

warning off
T = readtable(filename);
mon_temp = T.Properties.VariableNames([3,21,33]);

for i = 1 : length(mon_temp)
    cm = char(mon_temp(i));
    mon_names(i) = {cm(1:4)};
end

m = 0;
for i = 3 : 15 : size(T,2)
   m = m + 1; 
   cm = char(mon_names(m));
   
   D.(cm).acc = T{:,i:i+2} / 1000;               % [m/s^2]
   D.(cm).gyr = deg2rad(T{:,i+3:i+5});           % [rad/s]
   D.(cm).mag = T{:,i+6:i+8} * 1000000;          % [μT]
end

end