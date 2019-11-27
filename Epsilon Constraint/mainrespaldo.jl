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
for i = 1:nCentros
    centro = generarC();
    push!(setC,centro);
end

name = "centrosGenerados";
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

centersString = [];
f = open("centros.txt") do f
        while !eof(f)
        line = readline(f)
        push!(centersString,line);
    end
end

nCentros = length(centersString);
println("centersString");
totalExperimentos = 50;

#PLS
for i=1:nCentros
    for i=1:totalExperimentos;
        println("Prueba con centro nº ",i);
        for l = 1:length(array_len_N)
            len_N = array_len_N[l];
            println("Prueba con largo vecindario = ",len_N);
            for n = 1:length(array_neighborhood_structure)
                neighborhood_structure = array_neighborhood_structure[n];
                println("Prueba con estructura vecinos = ",neighborhood_structure);
                println("Experimento Angel");

                rootDirectory = pwd();
                cd(rootDirectory);
                filename = "Angel_Centro_$(i)_Prioridad_$(prioridad)_Epsilon ";
                filename = strConcat(filename,epsilonValues)
                configDirectory = "experimentos serie E "; # DIRECTORIO PARA LA CONFIGURACION DEL EXPERIMENTO
                configDirectory = strConcat(configDirectory,epsilonValues)
                currentExperiment = nothing;
                totalRunsStr = []; # STR QUE GUARDARÁ LA CORRIDA PARA LA CONFIGURACIÓN DEL EXPERIMENTO

                if !isdir(configDirectory)
                    mkdir(configDirectory)
                    println("baseDir created");
                    cd(configDirectory);
                    tr = "totalRuns.txt";
                    open(tr, "w") do file
                            write(file, "nextRun:1");
                    end
                    currentExperiment = 1; ## EL EXPERIMENTO ACTUAL QUE DEBE SER GUARDADO
                else
                    println("already exists");
                    cd(configDirectory)
                    f = open("totalRuns.txt") do f
                            while !eof(f)
                                        trLine = readline(f)
                                        trValue = split(trLine,":")
                                        push!(totalRunsStr,trValue[2]);
                            end
                    end
                    currentExperiment = parse(Int,totalRunsStr[1]); ## EL EXPERIMENTO ACTUAL QUE DEBE SER GUARDADO
                end

                runDirectory = string("run","$(currentExperiment)");

                if(!isdir(string(configDirectory,"/",runDirectory)))
                        mkdir(runDirectory)
                        println("runDir created")
                        cd(runDirectory)
                else
                        println("already exists");
                        cd(runDirectory)
                end


                A_Angel = solucion[];
                A_Angel,segundos,ite =PLSAngel(len_N,neighborhood_structure,setC[i],i);
                f1A = []
                f2A = []
                for f = 1:length(A_Angel)
                    push!(f1A,A_Angel[f].f1)
                    push!(f2A,A_Angel[f].f2)
                end

                fig = scatter(f1A,f2A,label="Archivo Angel")
                savefig(filename)
                savefig(fig, filename)

                cd(string(rootDirectory,"/",configDirectory));
                f = open("totalRuns.txt","w") do f
                        write(f,string("nextRun:",currentExperiment+1));
                end

                cd(rootDirectory); ## REDIRIGIR AL ROOT POR SI LLEGASE A SER PARTE DE UN PROGRAMA QUE ITERA SOBRE DISTINTOS PARAMS.

            end
        end
end
