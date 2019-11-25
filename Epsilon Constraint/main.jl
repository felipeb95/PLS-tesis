include("load_data.jl");
include("parametros.jl");
include("helpers.jl");
include("funcionesPLS.jl");
include("solver.jl");
include("PLSAngel.jl");

using Statistics, TickTock, Plots;

#Inicializar variables globales de balance y prioridad.
global balance          = 1;
##global prioridad        = 2;

#Grilla
global M                = get_grid();
#Matriz de adyacencia de zonas.
global adjacency_matrix = get_adjacency_matrix();
#Matriz de conexiones.
global c                = connection_calculation();


#CREACION DE CENTROS#
setC = [];
centro = zeros(Int64,length(CANDIDATAS));
for i = 1:nCentros
    centro = generarC();
    push!(setC,centro);
end

name = "centros";
filename = name*".txt"
open(filename, "w") do file
    for i in 1:nCentros
        aC       = copy(setC[i]);
        if i!=nCentros
            write(file, "$aC\n");
        else
            write(file, "$aC");
        end
    end
end


#PLS
for i=1:nCentros
    println("Prueba con centro nº ",i);
    for l = 1:length(array_len_N)
        len_N = array_len_N[l];
        println("Prueba con largo vecindario = ",len_N);
        for n = 1:length(array_neighborhood_structure)
            neighborhood_structure = array_neighborhood_structure[n];
            println("Prueba con estructura vecinos = ",neighborhood_structure);
            println("Experimento Angel");
            A_Angel = solucion[];
            A_Angel =PLSAngel(len_N,neighborhood_structure,setC[i],i);
            f1A = []
            f2A = []
            for f = 1:length(A_Angel)
                push!(f1A,A_Angel[f].f1)
                push!(f2A,A_Angel[f].f2)
            end
            fig = scatter(f1A,f2A,label="Archivo Angel")
            fn = "Angel_Centro_$(i)_Prioridad_$(prioridad)_Epsilon_$(epsilonValues[1])-$(epsilonValues[2])-$(epsilonValues[3])"
            savefig(fn)
            savefig(fig, fn)
        end
    end
end
