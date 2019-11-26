include("load_data.jl");
include("parametros.jl");
include("helpers.jl");
include("funcionesPLS.jl");
include("solver.jl");
include("PLS.jl");
include("PLSAngel.jl");

using Statistics, TickTock, Plots,XLSX;

#Inicializar variables globales de balance y prioridad.
global balance          = 1;
global prioridad        = 5;

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



XLSX.openxlsx("Resultados.xlsx", mode="w") do xf
    sheet = xf[1]
    XLSX.rename!(sheet, "Resultados")
    sheet["A1"] = "Prioridad $(prioridad)"
    sheet["B1"] = "Min Epsilon $(minEpsilon)"
    sheet["C1"] = "Max Epsilon $(maxEpsilon)"
    sheet["A2"] = "Experimento/Epsilon"
    sheet["B2"] = 0.2
    sheet["C2"] = 0.3
    sheet["D2"] = 0.4
    sheet["E2"] = 0.5
    sheet["F2"] = 0.6
    sheet["G2"] = 0.7
    sheet["H2"] = 0.8
    sheet["I2"] = 0.9
    sheet["J2"] = 1.0
    sheet["K2"] = "Segundos"
    sheet["L2"] = "Iteraciones"
    sheet["M2"] = "Hipervolumen"
    numero = 3
    for i=1:nCentros
        println("Prueba con centro nº ",i);
        for l = 1:length(array_len_N)
            len_N = array_len_N[l];
            println("Prueba con largo vecindario = ",len_N);
            for n = 1:length(array_neighborhood_structure)
                neighborhood_structure = array_neighborhood_structure[n];
                println("Prueba con estructura vecinos = ",neighborhood_structure);
                for e = 1:expPaquete
                    println("Experimento nº ",e);
                    println("Experimento Paquete");
                    A = solucion[]
                    A,segundos,ite = PLS(len_N,neighborhood_structure,e,setC[i],i);
                    f1P = []
                    f2P = []
                    for f = 1:length(A)
                        push!(f1P,A[f].f1)
                        push!(f2P,A[f].f2)
                    end
                    push!(f1P,450000)
                    push!(f2P,1.2)
                    hipervol = hipervolumen(f1P,f2P)
                    #fig = scatter(f1P,f2P,label="Archivo Paquete")
                    #fn = "Paquete_$(e)_Centro_$(i)_Prioridad_$(prioridad)_Epsilon_$(minEpsilon)-$(maxEpsilon)"
                    #savefig(fn)
                    #savefig(fig, fn)

                    for f = 1:length(A)
                        if(A[f].f2 == 0.2)
                            activa = "B$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.3)
                            activa = "C$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.4)
                            activa = "D$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.5)
                            activa = "E$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.6)
                            activa = "F$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.7)
                            activa = "G$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.8)
                            activa = "H$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.9)
                            activa = "I$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 1.0)
                            activa = "J$(numero)"
                            sheet[activa] = A[f].f1
                        end
                    end
                    activa = "A$(numero)"
                    sheet[activa] = "Paquete_Centro_$(i)_Exp_$(e)"
                    activa = "K$(numero)"
                    sheet[activa] = segundos
                    activa = "L$(numero)"
                    sheet[activa] = ite
                    activa = "M$(numero)"
                    sheet[activa] = hipervol
                    numero += 1


                    println("Experimento Angel");
                    A = solucion[]
                    A,segundos,ite = PLSAngel(len_N,neighborhood_structure,setC[i],i,e);
                    f1A = []
                    f2A = []
                    for f = 1:length(A)
                        push!(f1A,A[f].f1)
                        push!(f2A,A[f].f2)
                    end
                    push!(f1A,450000)
                    push!(f2A,1.2)
                    hipervol = hipervolumen(f1A,f2A)
                    #fig = scatter(f1A,f2A,label="Archivo Angel")
                    #fn = "Angel_$(e)_Centro_$(i)_Prioridad_$(prioridad)_Epsilon_$(minEpsilon)-$(maxEpsilon)"
                    #savefig(fn)
                    #savefig(fig, fn)


                    for f = 1:length(A)
                        if(A[f].f2 == 0.2)
                            activa = "B$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.3)
                            activa = "C$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.4)
                            activa = "D$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.5)
                            activa = "E$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.6)
                            activa = "F$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.7)
                            activa = "G$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.8)
                            activa = "H$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 0.9)
                            activa = "I$(numero)"
                            sheet[activa] = A[f].f1
                        end
                        if(A[f].f2 == 1.0)
                            activa = "J$(numero)"
                            sheet[activa] = A[f].f1
                        end
                    end
                    activa = "A$(numero)"
                    sheet[activa] = "Angel_Centro_$(i)_Exp_$(e)"
                    activa = "K$(numero)"
                    sheet[activa] = segundos
                    activa = "L$(numero)"
                    sheet[activa] = ite
                    activa = "M$(numero)"
                    sheet[activa] = hipervol
                    numero += 1
                end
            end
        end
    end
end
