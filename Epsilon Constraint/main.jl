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
println("EpsilonValues: ",epsilonValues);

totalExperimentos = 5;
global puntoRefX = 450000;
global puntoRefY = 1.2;
allEpsilons = collect(0.2:0.01:0.3);
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
    sheet = xf[1];
    XLSX.rename!(sheet, "Resultados Angel ED")
    row = 3;
    header = 2;

	sheet["A1"] = string("Prioridad ",prioridad);
    sheet["B1"] = string("Serie Eps: ",epsilonValues);
    
    for e in 1:length(allEpsilons)
		# ROW WITH EPSILON HEADERS
		epsCell = string(abc[e+1],header);
		sheet[epsCell] = allEpsilons[e];
    end
    
    # ROW/COL HEADER
	sheet["A2"] = "Experimento/Epsilon";
	# CELL WITH TIME HEADER
	time = string(abc[length(allEpsilons)+2],header);
	sheet[time] = "Segundos";
	# CELL WITH TIME HEADER
	iterations = string(abc[length(allEpsilons)+3],header);
	sheet[iterations] = "Iteraciones";
	# CELL WITH HYPERVOLUME HEADER
	hvRow = string(abc[length(allEpsilons)+4],header);
	sheet[hvRow] = "Hipervolumen";

    for i=1:nCentros

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
                    sheet[expCell] = string("AngelED_Centro$(i)_Exp$(j)");

                    # CELL WITH TIME VALUE
                    time = string(abc[length(allEpsilons)+2],row);
                    sheet[time] = segundos;
                    
                    # CELL WITH ITERATIONS VALUE
                    iterations = string(abc[length(allEpsilons)+3],row);
                    sheet[iterations] = ite;

                    # CELL WITH HYPERVOLUME VALUE
                    hvRow = string(abc[length(allEpsilons)+4],row);
                    sheet[hvRow] = hiperVolumen;
    

                    epsInA = unique(v->v.f2,A_Angel);
                    epsInA = map( k -> epsInA[k].f2, 1:length(epsInA));
                    epsInA = sort(epsInA);

                    for k in 1:length(allEpsilons)
                        # ROW WITH OBJECTIVE VALUES
                        valueCell = string(abc[k+1],row);
                        objToEpsIndex = findfirst(x->x.f2 == allEpsilons[k],A_Angel); ## Busco el índice del único item asociado que podría existir con epsilon para ese valor sub k.
                        objToEps = objToEpsIndex != nothing ? A_Angel[objToEpsIndex].f1 : "dominado"; ## Si retorno 'nothing' entonces no está ese epsilon, fue dominado.
                        sheet[valueCell] = objToEps;
        
                    end

                end
            end
            row += 1;
        end
        
    end

end
