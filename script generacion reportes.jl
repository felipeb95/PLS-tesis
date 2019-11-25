using Plots
include("example2.jl");
function strConcat(str,epsilon)
          for x=1:length(epsilon)
                    str = string(str,"_$(epsilon[x])");  
          end
return str;
end


f1 = [[300, 330, 320, 305] [200, 302, 239, 259]]
f2 = [[0.1, 0.2, 0.5, 0.7] [0.3, 0.6, 0.1, 0.3]]
a = scatter(f1,f2,label=["Ite 1" "Ite 2"])
epsilonValues = [0.2,0.3,0.4,0.8];
numCentro = 1;
len_N = 3;
neighborhood_structure = 1;
prioridad = 5;
i = 1;
prioridad = 5;



## GUARDAR DIRECTORIO ROOT ( DONDE ESTÁ EL MAIN) ##
rootDirectory = pwd();
cd(rootDirectory);
filename = "Angel_Centro_$(i)_Prioridad_$(prioridad)_Epsilon";
filename = strConcat(filename,epsilonValues)
configDirectory = "experimentos serie E"; # DIRECTORIO PARA LA CONFIGURACION DEL EXPERIMENTO 
configDirectory = strConcat(configDirectory,epsilonValues)
currentExperiment = nothing;
totalRunsStr = []; # STR QUE GUARDARÁ LA CORRIDA PARA LA CONFIGURACIÓN DEL EXPERIMENTO

println("[FILENAME] ",filename);

# SE REVISA SI EXISTE EL DIRECTORIO PARA LA CONFIGURACIÓN ACTUAL
# SI NO ESTÁ, SE CREA Y SE ACCEDE, ADEMÁS DE CREAR UN ARCHIVO PARA CONTAR LAS CORRIDAS. SI ESTÁ, SÓLO SE ACCEDE.
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

# NO HACE FALTA PASAR EL DIRECTORIO A LA FUNCION 
PLSAngel(len_N,neighborhood_structure,numCentro,epsilonValues) 
println("PWD exMain: ",pwd())
savefig(filename)
savefig(a,filename);

# SE SOBREESCRIBE LA CANTIDAD DE CORRIDAS 
cd(string(rootDirectory,"/",configDirectory));
f = open("totalRuns.txt","w") do f 
          write(f,string("nextRun:",currentExperiment+1));
end

cd(rootDirectory); ## REDIRIGIR AL ROOT POR SI LLEGASE A SER PARTE DE UN PROGRAMA QUE ITERA SOBRE DISTINTOS PARAMS.





