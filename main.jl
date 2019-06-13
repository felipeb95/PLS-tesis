include("load_data.jl");
#include("cargardatos.jl");
include("gurobi.jl");
include("helpers.jl");
include("RVNS.jl");
include("PLS.jl");
include("PLSAngel.jl");

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

#= MAIN =#
# Variables metaheurística
r_max =2; #Número iteraciones.
len_N =3;  #Tamaño de los vecindarios.
neighborhood_structure = [1]; #Tamaños estructuras de entorno.
k_max = length(neighborhood_structure); #k máximo.

#Numero de experimentos a realizar.
experimentos = 1;

#Limite de no mejoras.
const NO_IMPROVE_LIMIT = r_max;

objs_iter = 0;
objs_array = [];
for e = 1:experimentos
    C_test = zeros(Int64,length(CANDIDATAS));
    E_test = zeros(Int64,length(ESTACIONES));
    C_test,E_test,objs_iter = @time PLSAngel(k_max,r_max,len_N,neighborhood_structure,e,NO_IMPROVE_LIMIT);
    append!(objs_array,objs_iter);
end
let suma = 0.0;
    for i=1:length(objs_array)
        suma = suma + objs_array[i];
    end


    promedio  = suma/length(objs_array);
    de    = std(floor.(objs_array));
    best  = minimum(objs_array);
    worst = maximum(objs_array);

    #Resumen resultados
    name = "result_exp_$(balance)_$(prioridad)_$(experimentos)_$(best)";
    filename = name*".txt"
    open(filename, "w") do file
        write(file, "promedio       = $promedio \n");
        write(file, "d.e            = $de   \n");
        write(file, "best           = $best \n");
        write(file, "worst          = $worst \n");
    end
end
