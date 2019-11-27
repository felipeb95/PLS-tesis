include("load_data.jl");
include("parametros.jl");
include("helpers.jl");
include("funcionesPLS.jl");
include("solver.jl");
include("PLSAngel.jl");
include("fileSavingHelpers.jl")

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
#=
for i = 1:nCentros
    centro = generarC();
    push!(setC,centro);
end
=#

centrosString = [];
f = open("centros.txt") do f
        while !eof(f)
        line = readline(f)
        push!(centrosString,line);
    end
end

nCentros = length(centrosString);
totalExperimentos = 5;
global puntoRefX = 450000;
global puntoRefY = 1.2;

#PLS
for i=1:nCentros
    centroActual = centrosString[i];
    centroActual = replace(centroActual,"["=>"");
    centroActual = replace(centroActual,"]"=>"");
    centroActual = replace(centroActual,","=>"");

    numbers = split(centroActual);
    setC = parse.(Int64,numbers);

    for j=1:totalExperimentos;
        println("Prueba con centro nº ",i);
        for l = 1:length(array_len_N)
            len_N = array_len_N[l];
            println("Prueba con largo vecindario = ",len_N);
            for n = 1:length(array_neighborhood_structure)
                neighborhood_structure = array_neighborhood_structure[n];
                println("Prueba con estructura vecinos = ",neighborhood_structure);
                println("Experimento Angel");

                filename = "Angel_Centro_$(i)_$(j)_Prioridad_$(prioridad)_Epsilon ";
                filename = strConcat(filename,epsilonValues)

                A_Angel = solucion[];
                A_Angel,segundos,ite =PLSAngel(len_N,neighborhood_structure,setC,i,j);
                f1A = []
                f2A = []
                for f = 1:length(A_Angel)
                    push!(f1A,A_Angel[f].f1)
                    push!(f2A,A_Angel[f].f2)
                end

                fig = scatter(f1A,f2A,label="Archivo Angel")
                savefig(filename)
                savefig(fig, filename)


            end
        end
    end
end
