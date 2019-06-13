function RVNS(k_max,r_max,len_N,neighborhood_structure,e,NO_IMPROVE_LIMIT)
    r = 1;

    #Memoria vectores estaciones candidatas.
    mem_C = zeros(Int64,r_max*k_max*2,length(CANDIDATAS));
    index_mem_C = 0;

    #Solución inicial x.
    C = zeros(Int64,length(CANDIDATAS));
    E = zeros(Int64,length(ESTACIONES));
    obj = Inf;

    while true
        println("SE INICIALIZA SOLUCION");
        C,E,obj = init_solution();
        println("RETORNA ",obj)
        if obj != Inf
            break;
        end
    end
    println("SOLUCION INICIALIZADA");

    #Se guarda primera solución.
    first_C = copy(C);
    first_E = copy(E);
    first_obj = copy(obj);

    #Contador Mejoras.
    improve = 0;
    no_improve = 0;

    current_obj = zeros(Float64,r_max);
    objs_iter = [];
    cong_k = [];
    obj_k = [];

    #Comienzo iteraciones.
    while r <= r_max
        k = 1;

        println("====== $r ====== $obj");
        push!(objs_iter,obj);

        current_obj[r] = Inf;

        while k <= k_max
            println("=== k =  $(neighborhood_structure[k]) ===")

            #Agitacion
            _C,_E,_obj = shaking(len_N,C,E,obj,neighborhood_structure[k],mem_C,index_mem_C);

            if sum(_E) != 0 && _obj <= current_obj[r]
                current_obj[r] = _obj;
            end

            #Sí x' mejor que x, x = x' (Cambio de vecindario)
            if _obj < obj
                C = copy(_C);
                E = copy(_E);
                obj = copy(_obj);
                append!(obj_k,obj);
                push!(cong_k,neighborhood_structure[k]);
                #println("=MEJORA= $obj");
                improve += 1;
                no_improve = 0;
                break;
            else
                k+=1;
                no_improve+=1;
            end
        end

        if no_improve >= NO_IMPROVE_LIMIT
            break;
        end

        r+=1;
    end
    println("====== Resultados ======");
    println("n° iter       = $r_max");
    println("Prioridad      = $prioridad");
    println("Balance        = $balance");
    println("neighborhood_structure = $neighborhood_structure");
    println("Len_N         = $len_N");
    println("N° clusters   = $cl");
    println("N° estaciones = $(length(ESTACIONES))");
    println("N° mejoras    = $(improve)");
    println("N° iter       = $(r_max)");
    println("1° FO         = $first_obj");
    println("FO            = $obj");
    println("Centros       = $(findall(x->x==1,C))");
    println("C = $C");
    println("E = $E");

    name = "$(balance)_$(prioridad)_exp_$(e)_$(r_max)_$(len_N)_$(improve)_$(obj)";
    filename = name*".txt"
    open(filename, "w") do file
        write(file, "n° iter       = $r_max \n")
        write(file, "neighborhood_structure = $neighborhood_structure \n")
        write(file, "Prioridad     = $prioridad \n")
        write(file, "balance       = $balance \n")
        write(file, "Len_N         = $len_N \n")
        write(file, "N° clusters   = $cl \n")
        write(file, "N° estaciones = $(length(ESTACIONES)) \n")
        write(file, "N° mejoras    = $(improve)\n")
        write(file, "N° iter       = $(r_max)\n")
        write(file, "1° FO         = $first_obj\n")
        write(file, "FO            = $obj\n")
        write(file, "Centros       = $(findall(x->x==1,C))\n")
        write(file, "C = $C\n")
        write(file, "E = $E\n")
        write(file, "Objs= $objs_iter\n")
        write(file, "current_obj = $current_obj\n")
        write(file, "cong_K= $cong_k \n");
        write(file, "obj_k= $obj_k \n");
    end
    return C,E,obj;
end

function shaking(len_N,C,E,obj,k,mem_C,index_mem_C)
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
    aux_C = N[rand(1:len_N),:];
    aux_obj,aux_E = Gurobi_optimal(aux_C);

    return aux_C,aux_E,aux_obj;
end
