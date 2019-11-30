include("load_data.jl");
include("parametros.jl");
include("helpers.jl");
include("funcionesPLS.jl");
include("solver.jl");
include("PLSAngel.jl");
include("fileSavingHelpers.jl")

using Statistics, TickTock, Plots, XLSX;

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
println("Experimento con ", nCentros," centros");

totalExperimentos = 5;
global puntoRefX = 450000;
global puntoRefY = 1.2;
allEpsilons = collect(0.2:0.1:1);
abc = collect('A':'Z');

cd(string(pwd(),"/resultados"));
byConfigDirectory = "resultados P $(prioridad) E "; # DIRECTORIO PARA LA CONFIGURACION DEL EXPERIMENTO 
byConfigDirectory = strConcat(byConfigDirectory,epsilonValues)

if !isdir(byConfigDirectory)
    mkdir(byConfigDirectory)
    println("directorio creado por configuración nueva");
    cd(byConfigDirectory);
else 
    println("directorio con la configuración del experimento actual ya existe");
    cd(byConfigDirectory)
end


expName = string("resultados P ",prioridad," E ");
expName = strConcat(expName,epsilonValues);
expName = string(expName,".xlsx");
println("[EXCEL FILE] ",expName);

#PLS
XLSX.openxlsx(expName, mode="w") do xf

    for i=1:nCentros
        sheet = xf[1];
        if i == 1
            XLSX.rename!(sheet, "centro 1")
        else
            XLSX.addsheet!(xf, "centro $(i)")
            sheet = xf[i];
        end
        row = 1;

        centroActual = centrosString[i];
        centroActual = replace(centroActual,"["=>"");
        centroActual = replace(centroActual,"]"=>"");
        centroActual = replace(centroActual,","=>"");

        numbers = split(centroActual);
        setC = parse.(Int64,numbers);

        for j=1:totalExperimentos
            println("Prueba con centro nº ",i);
            for l = 1:length(array_len_N)
                len_N = array_len_N[l];
                println("Prueba con largo vecindario = ",len_N);
                for n = 1:length(array_neighborhood_structure)
                    neighborhood_structure = array_neighborhood_structure[n];
                    println("Prueba con estructura vecinos = ",neighborhood_structure);
                    println("Experimento Angel");

                    A_Angel = solucion[];
                    A_Angel,segundos,ite,hiperVolumen = PLSAngel(len_N,neighborhood_structure,setC,i,j);
                    
                    f1A = map( k -> A_Angel[k].f1, 1:length(A_Angel));
                    f2A = map( k -> A_Angel[k].f2, 1:length(A_Angel));

                    # CELL WITH EXPERIMENT COUNT
                    expCell = string("A",row);
                    sheet[expCell] = string("Exp $(j)");
                                    
                    # CELL WITH EPSILON HEADER
                    epsHCell = string("A",row+1);
                    sheet[epsHCell] = "Epsilon";

                    # CELL WITH FO HEADER
                    foCell = string("A",row+2);
                    sheet[foCell] = "FO1";

                    # CELL WITH HYPERVOLUME HEADER
                    hvRow = string("A",row+3);
                    sheet[hvRow] = "hyperVolume";
                    # CELL WITH HYPERVOLUME VALUE
                    hvRow = string("B",row+3);
                    sheet[hvRow] = hiperVolumen;

                    # CELL WITH TIME HEADER
                    time = string("A",row+4);
                    sheet[time] = "segundos";
                    # CELL WITH TIME VALUE
                    time = string("B",row+4);
			        sheet[time] = segundos;

                    epsInA = unique(v->v.f2,A_Angel);
                    epsInA = map( k -> epsInA[k].f2, 1:length(epsInA));
                    epsInA = sort(epsInA);

                    for k in 1:length(allEpsilons)
                        # ROW WITH EPSILON HEADERS
                        epsCell = string(abc[k+1],row+1);
                        sheet[epsCell] = allEpsilons[k];
        
                        # ROW WITH OBJECTIVE VALUES
                        valueCell = string(abc[k+1],row+2);
                        objToEpsIndex = findfirst(x->x.f2 == allEpsilons[k],A_Angel); ## Busco el índice del único item asociado que podría existir con epsilon para ese valor sub k.
                        objToEps = objToEpsIndex != nothing ? A_Angel[objToEpsIndex].f1 : "dominado"; ## Si retorno 'nothing' entonces no está ese epsilon, fue dominado.
                        sheet[valueCell] = objToEps;
        
                    end

                end
            end
            row += 6;
        end
        
    end

end
