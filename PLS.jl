mutable struct solucion
    C
    E
    f1
    f2
    obj
    visitado
end

function PLS(k_max,r_max,len_N,neighborhood_structure,e,NO_IMPROVE_LIMIT)
    r = 1;

    #Memoria vectores estaciones candidatas.
    mem_C = zeros(Int64,r_max*k_max*2,length(CANDIDATAS));
    #posible problema con la memoria
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
        println("SOLUCION INICIAL");
        C,E,f1,f2,obj = init_solution_mo(); #GENERAR SOLUCIÓN INICIAL
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

    #current_obj = zeros(Float64,r_max);
    #objs_iter = [];
    #cong_k = [];
    #obj_k = [];

    #HASTA QUE TODAS LAS SOLUCIONES DEL ARCHIVO SEAN VISITADAS
    while ~visitados(A)
        k = 1;

        #println("====== $r ====== $obj");
        #push!(objs_iter,obj);

        #current_obj[r] = Inf;



        #while k <= k_max
            #println("=== k =  $(neighborhood_structure[k]) ===")
            #Se generan vecinos
            println("[PLS] === Generación de vecinos ===");
            N = generar_vecindario(len_N,st.C,neighborhood_structure[k],mem_C,index_mem_C);
            indiceVisitado = findall(x -> x==st, A);
            A[indiceVisitado[1]].visitado = 1;
            println("[PLS] Índice marcado como visitado: ", indiceVisitado[1]);

            for i=1:len_N
                println("[PLS] Vecino # ",i," ===============");
                aux_obj, aux_f1, aux_f2, aux_E = Gurobi_optimalMO(N[i,:]);
                #=  revisar si es dominado por los que están en el archivo
                si no es dominado por ninguno, entra al archivo  =#

                if criterioAcceso(aux_f1,aux_f2,A) == true
                    #println("CUMPLE REQUISITOS");
                    solNueva = solucion(N[i,:],aux_E,aux_f1,aux_f2,aux_obj,0);
                    push!(A,solNueva);
                    #println("SE AGREGA a A: ", length(A));

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
                        println("[PLS] Indices a eliminar tras análisis dominancia: ", str_indicesEliminados);
                        #= se eliminan los elementos en el array con los indices
                        que se guardaron anteriormente. A se actualiza mediante
                        la función deleteat! =#
                        deleteat!(A,indicesAEliminar);
                        println("[PLS] # nuevo de soluciones en archivo:", length(A));
                    else
                        println("[PLS] No se encontraron soluciones dominadas");
                    end
                end
            end
        #end
        t+=1;

        #= Apenas se elige una solución del archivo, se marca como visitada,
        ya que se le generará un vecindario apenas comience la siguiente
        iteración, =#

        st = selArchivo(A);
        #println("NUEVO A: ", length(A));
        if(st == nothing)
            break;
        end
        r+=1;
    end
    println("====== Resultados ======");
    println("n° iter                 = $t");
    println("Estructura vecindario   = $neighborhood_structure");
    println("Vecinos por iteración   = $len_N");
    println("N° clusters             = $cl");
    println("N° estaciones           = $(length(ESTACIONES))");
    println("1° FO Weighted Sum  = $first_obj");
    println("1° FO1              = $first_obj_f1");
    println("1° FO2              = $first_obj_f2");

    name = "exp_$(t)_$(len_N)_$(obj)";
    filename = name*".txt"
    open(filename, "w") do file
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
    return C,E,obj;
end

function visitados(archivo)
    visited = true;
    for i in 1:length(archivo)
        #println("=============== ",i," ===============\n")
        if(archivo[i].visitado == 0)
            visited = false;
            break;
        end
    end
    return visited;
end

function generar_vecindario(len_N,C,k,mem_C,index_mem_C)
    N = zeros(Int64,len_N,length(CANDIDATAS));
    for i=1:len_N
        aux_C = zeros(Int64,length(CANDIDATAS));
        while true
            aux_C = swap_center_random_grid(C,k);

            if compare_N(N,aux_C,len_N) && validate_connection(aux_C) && compare_N(mem_C,aux_C,index_mem_C)
                index_mem_C += 1;
                mem_C[index_mem_C,:] = aux_C;
                N[i,:] = aux_C;
                break;
            end
        end
    end
    #aux_C = N[rand(1:len_N),:];
    #aux_obj,aux_E = Gurobi_optimal(aux_C);

    return N;
end

function revisarDominanciaEnArchivo(f1, f2, A)
    indicesDominados = [];

    for i in 1:length(A)
        if(f1 < A[i].f1 && f2 < A[i].f2)
            push!(indicesDominados, i);
        end
    end

    return indicesDominados;
end


function criterioAcceso(f1,f2, A)
    accede = true;
    for i in 1:length(A)
        if(f1 > A[i].f1 && f2 > A[i].f2)
            accede = false;
            return accede;
        end
    end
    return accede;
end

function selArchivo(A)
    auxA = solucion[];
    for i in 1:length(A)
        if(A[i].visitado == 0)
            push!(auxA,A[i]);
        end
    end
    if length(auxA) == 0
        return nothing;
    end
    idx = rand(1:length(auxA));
    return auxA[idx];
end
