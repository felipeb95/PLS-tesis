#PARAMETROS
lineas = []
array_len_N = []
array_neighborhood_structure = []
array_a_ws = []
f = open("parametros.txt") do f
   line = 1
   while !eof(f)
     x = readline(f)
     xx = split(x, ":")
     push!(lineas,xx[2])

     line += 1
   end
 end
xxx = split(lineas[1], ",");
for i in 1:length(xxx)
  push!(array_len_N,parse(Int,xxx[i]));
end
xxx = split(lineas[2], ",");
for i in 1:length(xxx)
  push!(array_neighborhood_structure,parse(Int,xxx[i]));
end
xxx = split(lineas[3], ",");
for i in 1:length(xxx)
  push!(array_a_ws,parse(Float64,xxx[i]));
end
expPaquete = parse(Int,lineas[4]) #Numero de experimentos a realizar en PLS de Paquete
nCentros = parse(Int,lineas[5]) #Numero de centros a probar
global minEpsilon = parse(Float64,lineas[6])
global maxEpsilon = parse(Float64,lineas[7])
