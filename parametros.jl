#PARAMETROS
lineas = []
f = open("parametros.txt") do f
   line = 1
   while !eof(f)
     x = readline(f)
     xx = split(x, ":")
     push!(lineas,parse(Float64,xx[2]))

     line += 1
   end
 end
len_N = trunc(Int,lineas[1]) #Tamaño del vecindario
neighborhood_structure = trunc(Int,lineas[2]) #Cuantos centros se abriran y cerraran por vecino
global a_ws = lineas[3] #Alfa weighted sum
expPaquete = trunc(Int,lineas[4]) #Numero de experimentos a realizar en PLS de Paquete
nCentros = trunc(Int,lineas[5]) #Numero de centros a probar
