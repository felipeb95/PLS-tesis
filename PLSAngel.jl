mutable struct solucion
    C
    E
    f1
    f2
    obj
    visitado
end

function PLSAngel(k_max,r_max,len_N,neighborhood_structure,e,NO_IMPROVE_LIMIT)
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

    #HASTA QUE TODAS LAS SOLUCIONES DEL ARCHIVO SEAN VISITADAS
    while ~visitados(A)
        k = 1;
        println("ITERACION ",k);

        #OBTENER NO VISITADAS DEL ARCHIVO (TODAS)
        println("GENERANDO NO VISITADAS");
        NV = getNoVisitadas(A);
        for i=1:length(NV)
            st = NV[i];
            println("RECORRRIENDO NO VISITADA nº ",i)

            #Se generan vecinos
            println("GENERANDO VECINOS");
            N = generar_vecindario(len_N,st.C,neighborhood_structure[k],mem_C,index_mem_C);
            indiceVisitado = findall(x -> x==st, A);
            A[indiceVisitado[1]].visitado = 1;
            println("MARCANDO COMO VISITADO EN ESPACIO", indiceVisitado[1]);

            for j=1:len_N
                aux_obj, aux_f1, aux_f2, aux_E = Gurobi_optimalMO(N[j,:]);
                solNueva = solucion(N[j,:],aux_E,aux_f1,aux_f2,aux_obj,0);
                push!(A,solNueva);
            end

        end
        println("LARGO A ANTES DEL ANALISIS ",length(A))
        A = analisisDominancia(A);
        println("LARGO A DESPUES DEL ANALISIS ",length(A))
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

    name = "expPLSAngel_$(t)_$(len_N)_$(obj)";
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

function visitados(A)
    visited = true;
    for i in 1:length(A)
        println("=============== ",i," ===============\n")
        if(A[i].visitado == 0)
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

function analisisDominancia(A)
    indicesDominados = Int[];
    for i in 1:length(A)
        for j in 1:length(A)
            if(A[i].f1 < A[j].f1 && A[i].f2 < A[j].f2)
                if(findfirst(isequal(j),indicesDominados)==nothing)
                    push!(indicesDominados, j);
                end
            else
                if(A[i].f1 > A[j].f1 && A[i].f2 > A[j].f2)
                    if(findfirst(isequal(i),indicesDominados)==nothing)
                        push!(indicesDominados, i);
                    end
                end
            end
        end
    end

    sort!(indicesDominados);
    deleteat!(A,indicesDominados);

    return A;
end

function getNoVisitadas(A)
    NV = solucion[];
    for i in 1:length(A)
        if(A[i].visitado == 0)
            push!(NV,A[i]);
        end
    end
    return NV;
end
