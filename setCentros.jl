include("load_data.jl");
include("helpers.jl");

using Statistics;

#Inicializar variables globales de balance y prioridad.
global balance          = 1;
global prioridad        = 15;

#Grilla
global M                = get_grid();
#Matriz de adyacencia de zonas.
global adjacency_matrix = get_adjacency_matrix();

#Matriz de conexiones.
global c                = connection_calculation();
nCentros = 20;
setC = [];
centro = zeros(Int64,length(CANDIDATAS));
for i = 1:nCentros
    centro = generarC();
    push!(setC,centro);
end

name = "centros";
filename = name*".txt"
open(filename, "w") do file
    for i in 1:n
        aC       = copy(setC[i]);
        write(file, "Centro [$i] \n")

        write(file, "$aC\n");
    end
end
