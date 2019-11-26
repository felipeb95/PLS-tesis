function PLSAngel(len_N,neighborhood_structure,centro,numCentro,e)
    tick()
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
        println("[PLS Angel] Solución inicial");
        C,E,f1,f2,obj,dmax = init_solution_mo(centro); #GENERAR SOLUCIÓN INICIAL
        if obj != Inf
            st = solucion(C,E,f1,f2,obj,dmax,0);
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

    name = "memArchivoPLSAngel_$(numCentro)_exp_$(e)_$(len_N)_$(neighborhood_structure)_$(prioridad)_Epsilon_$(minEpsilon)-$(maxEpsilon)"
    filename = name*".txt"
    open(filename, "w") do file
        #HASTA QUE TODAS LAS SOLUCIONES DEL ARCHIVO SEAN VISITADAS
        while ~visitados(A)
            #OBTENER NO VISITADAS DEL ARCHIVO (TODAS)
            println("GENERANDO NO VISITADAS");
            NV = getNoVisitadas(A);
            for i=1:length(NV)
                st = NV[i];
                println("RECORRRIENDO NO VISITADA nº $i de ", length(NV))

                #Se generan vecinos
                println("GENERANDO VECINOS");
                N = generar_vecindario(len_N,st.C,st.E,neighborhood_structure,mem_C,index_mem_C);
                indiceVisitado = findall(x -> x==st, A);
                A[indiceVisitado[1]].visitado = 1;
                println("MARCANDO COMO VISITADO EN ESPACIO ", indiceVisitado[1]);

                for j=1:len_N
                    aux_obj, aux_f1, aux_f2, aux_E, aux_dmax = SolverNL(N[j,:]);
                    solNueva = solucion(N[j,:],aux_E,aux_f1,aux_f2,aux_obj,aux_dmax,0);
                    push!(A,solNueva);
                end

            end
            println("LARGO A ANTES DEL ANALISIS ",length(A))
            A = analisisDominancia(A);
            println("LARGO A DESPUES DEL ANALISIS ",length(A))
            t+=1;
            write(file, "ITERACION $t \n");
            for i in 1:length(A)
                aC       = copy(A[i].C);
                aE       = copy(A[i].E);
                a_obj    = copy(A[i].obj);
                a_obj_f1 = copy(A[i].f1);
                a_obj_f2 = copy(A[i].f2);
                a_dmax   = copy(A[i].dmax);
                write(file, "Archivo [$i] \n")

                write(file, "C                  = $aC \n");
                write(file, "E                  = $aE \n");
                write(file, "FO1                = $a_obj_f1 \n");
                write(file, "FO2                = $a_obj_f2 \n");
                write(file, "DMAX               = $a_dmax \n");
            end
        end
    end

    println("[PLS] ====== Resultados ======");
    println("n° iter                 = $t");
    println("Estructura vecindario   = $neighborhood_structure");
    println("Vecinos por iteración   = $len_N");
    println("N° clusters             = $cl");
    println("N° estaciones           = $(length(ESTACIONES))");
    println("1° FO1              = $first_obj_f1");
    println("1° FO2              = $first_obj_f2");

    name = "expPLSAngel_$(numCentro)_exp_$(e)_$(len_N)_$(neighborhood_structure)_$(prioridad)_Epsilon_$(minEpsilon)-$(maxEpsilon)"
    filename = name*".txt"
    segundos = tok()
    open(filename, "w") do file
        write(file, "Segundos              = $(segundos) \n")
        write(file, "n° iter               = $t \n")
        write(file, "Estructura vecindario = $neighborhood_structure \n")
        write(file, "Vecinos por iteración = $len_N \n")
        write(file, "N° clusters           = $cl \n")
        write(file, "N° estaciones         = $(length(ESTACIONES)) \n")
        write(file, "1° FO1                = $first_obj_f1\n")
        write(file, "1° FO2                = $first_obj_f2\n")
        #sacar de archivo
        for i in 1:length(A)
            aC         = copy(A[i].C);
            aE         = copy(A[i].E);
            a_obj      = copy(A[i].obj);
            a_obj_f1 = copy(A[i].f1);
            a_obj_f2 = copy(A[i].f2);
            a_dmax     = copy(A[i].dmax);
            write(file, "Archivo [$i] \n")

            write(file, "C               = $aC \n");
            write(file, "E               = $aE \n");
            write(file, "FO1             = $a_obj_f1 \n");
            write(file, "FO2             = $a_obj_f2 \n");
            write(file, "DMAX            = $a_dmax \n");
        end
    end
    return A,segundos,t;
end
