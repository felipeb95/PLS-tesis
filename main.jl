include("load_data.jl");
include("parametros.jl");
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
    for a = 1:length(array_a_ws)
        global a_ws = array_a_ws[a];
        println("Prueba con alfa (Weighted Sum) = ",a_ws);
        for l = 1:length(array_len_N)
            len_N = array_len_N[l];
            println("Prueba con largo vecindario = ",len_N);
            for n = 1:length(array_neighborhood_structure)
                neighborhood_structure = array_neighborhood_structure[n];
                println("Prueba con estructura vecinos = ",neighborhood_structure);
                for e = 1:expPaquete
                    println("Experimento Paquete nº ",e);
                    A_Paquete = solucion[]
                    A_Paquete = @time PLS(len_N,neighborhood_structure,e,setC[i],i);
                end
                println("Experimento Angel");
                #A_Angel = solucion[]
                #A_Angel = @time PLSAngel(len_N,neighborhood_structure,setC[i],i);
            end
        end
    end
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
=#
