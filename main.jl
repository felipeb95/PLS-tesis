include("load_data.jl");
include("solver.jl");
include("helpers.jl");
include("funcionesPLS.jl")
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

#PARAMETROS MODIFICABLES
len_N =3;  #Tamaño del vecindario
neighborhood_structure = 1; #Cuantos centros se abriran y cerraran por vecion
global a_ws = 0.5; #Alfa weighted sum
expPaquete = 20; #Numero de experimentos a realizar en PLS de Paquete


#CREACION DE CENTROS#
nCentros = 1;
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
    #=
    for e = 1:expPaquete
        A_Paquete = solucion[]
        A_Paquete = @time PLS(len_N,neighborhood_structure,e,setC[i],i);
    end
    =#
    A_Angel = solucion[]
    A_Angel = @time PLSAngel(len_N,neighborhood_structure,setC[i],i);
end

#=let suma = 0.0;
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
