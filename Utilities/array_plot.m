%% Array Plot 
%% Created by Guido Mascia (Università degli Studi di Roma "Foro Italico")

function array_plot(V,color,linewidth)
quiver3(0, 0, 0, V(1), V(2), V(3),color,'linewidth',linewidth);
axis equal
end