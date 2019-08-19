function PLS(len_N,neighborhood_structure,e,centro,numCentro)

    #Memoria vectores estaciones candidatas.
    mem_C = [];
    index_mem_C = 0;

    #Solución inicial x.
    C = zeros(Int64,length(CANDIDATAS));
    E = zeros(Int64,length(ESTACIONES));
    obj_f1 = Inf;
    obj_f2 = Inf;
    obj = Inf;
    f1 = Inf;
    f2 = Inf;

    #SE INICIALIZAN VARIABLES Y ESTRUCTURA
    t = 0;

    A = solucion[]; #CREAR A
    st = solucion;
    #SOLUCION INICIAL
    while true
        println("[PLS Paquete] Solución inicial");
        C,E,f1,f2,obj = init_solution_mo(centro); #GENERAR SOLUCIÓN INICIAL
        if obj != Inf
            st = solucion(C,E,f1,f2,obj,0);
            push!(A,st); #ACTUALIZAR ACHIVO
            println("A:", length(A));
            break;
        end
    end


    #Se guarda primera solución.
    first_C = copy(C);
    first_E = copy(E);
    first_obj = copy(obj);
    first_obj_f1 = copy(f1);
    first_obj_f2 = copy(f2);

    #HASTA QUE TODAS LAS SOLUCIONES DEL ARCHIVO SEAN VISITADAS
    while ~visitados(A)
        #Se generan vecinos
        println("[PLS Paquete] === Generación de vecinos ===");
        N = generar_vecindario(len_N,st.C,neighborhood_structure,mem_C,index_mem_C);
        indiceVisitado = findall(x -> x==st, A);
        A[indiceVisitado[1]].visitado = 1;
        println("[PLS Paquete] Índice marcado como visitado: ", indiceVisitado[1]);

        for i=1:len_N
            println("[PLS Paquete] Vecino # ",i," ===============");
            aux_obj, aux_f1, aux_f2, aux_E = SolverNL(N[i,:]);
            #=  revisar si es dominado por los que están en el archivo
            si no es dominado por ninguno, entra al archivo  =#

            if criterioAcceso(aux_f1,aux_f2,A) == true
                solNueva = solucion(N[i,:],aux_E,aux_f1,aux_f2,aux_obj,0);
                push!(A,solNueva);

                #=  se buscan los índices de las soluciones que están dentro
                del archivo y que están siendo dominadas por la última
                solución agregada al archivo =#

                indicesAEliminar = revisarDominanciaEnArchivo(aux_f1,aux_f2,A);
                str_indicesEliminados = "";
                if length(indicesAEliminar) != 0
                    for dominatedIndex = 1 : length(indicesAEliminar)
                        str_indicesEliminados *= string(indicesAEliminar[dominatedIndex]);
                        if dominatedIndex != length(indicesAEliminar)
                            str_indicesEliminados *= ", ";
                        else
                            str_indicesEliminados *= ".";
                        end
                    end
                    println("[PLS Paquete] Indices a eliminar tras análisis dominancia: ", str_indicesEliminados);
                    #= se eliminan los elementos en el array con los indices
                    que se guardaron anteriormente. A se actualiza mediante
                    la función deleteat! =#
                    deleteat!(A,indicesAEliminar);
                    println("[PLS Paquete] # nuevo de soluciones en archivo:", length(A));
                else
                    println("[PLS Paquete] No se encontraron soluciones dominadas");
                end
            end
        end
        #= Apenas se elige una solución del archivo, se marca como visitada,
        ya que se le generará un vecindario apenas comience la siguiente
        iteración, =#
        st = selArchivo(A);
        if(st == nothing)
            break;
        end
        t+=1;
    end
    println("[PLS] ====== Resultados ======");
    println("n° iter                 = $t");
    println("Estructura vecindario   = $neighborhood_structure");
    println("Vecinos por iteración   = $len_N");
    println("N° clusters             = $cl");
    println("N° estaciones           = $(length(ESTACIONES))");
    println("1° FO Weighted Sum  = $first_obj");
    println("1° FO1              = $first_obj_f1");
    println("1° FO2              = $first_obj_f2");

    name = "expPLSPaquete_$(numCentro)_$(e)_$(a_ws)_$(len_n)_$(neighborhood_structure)";
    filename = name*".txt"
    open(filename, "w") do file
        write(file, "alfa Weighted Sum     = $a_ws \n")
        write(file, "n° iter               = $t \n")
        write(file, "Estructura vecindario = $neighborhood_structure \n")
        write(file, "Vecinos por iteración = $len_N \n")
        write(file, "N° clusters           = $cl \n")
        write(file, "N° estaciones         = $(length(ESTACIONES)) \n")
        write(file, "1° FO Weighted Sum    = $first_obj\n")
        write(file, "1° FO1                = $first_obj_f1\n")
        write(file, "1° FO2                = $first_obj_f2\n")
        #sacar de archivo
        for i in 1:length(A)
            aC       = copy(A[i].C);
            aE       = copy(A[i].E);
            a_obj    = copy(A[i].obj);
            a_obj_f1 = copy(A[i].f1);
            a_obj_f2 = copy(A[i].f2);
            write(file, "Archivo [$i] \n")

            write(file, "C               = $aC \n");
            write(file, "E               = $aE \n");
            write(file, "FO Weighted Sum = $a_obj \n");
            write(file, "FO1             = $a_obj_f1 \n");
            write(file, "FO2             = $a_obj_f2 \n");
        end
    end
    return A;
end
