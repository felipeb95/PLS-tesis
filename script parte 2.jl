function PLSAngel(len_N,neighborhood_structure,numCentro,epsilonValues)

##directory = "experimentos serie E";
##directory = strConcat(directory,epsilonValues);
name = "memArchivoPLSAngel_$(numCentro)_$(len_N)_$(neighborhood_structure)_$(prioridad)_Epsilon";
name = strConcat(name,epsilonValues);

println("PWD ex2: ",pwd())

##cd(directory)
f = name*".txt"
open(f, "w") do file
          write(file, "juliaexp2");
end

end