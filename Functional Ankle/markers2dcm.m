function G_R_Tek = markers2dcm(markers, seg_name)



M1 = markers.([seg_name, num2str(1)]);
M2 = markers.([seg_name, num2str(2)]);
M3 = markers.([seg_name, num2str(3)]);
M4 = markers.([seg_name, num2str(4)]);


for t = 1:length(M1)
    m1 = M1(t,:)';  % Origin Marker
    m2 = M2(t,:)';
    m3 = M3(t,:)';
    
    %Definition of the new Reference Frame
    j = (m2-m1)/(norm(m2-m1));
    i = (cross(j,(m3-m1))/(norm(cross(j, (m3-m1)))));
    k = cross(j,i);
    
    R_temp = [i j k];
    G_R_Tek(:,:,t) = R_temp;
end

end