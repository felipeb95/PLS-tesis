function PLSAngel(len_N,neighborhood_structure,centro,numCentro,numExperimento)
    curveId = 1
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
        for i = 1:length(epsilonValues)
            println("USANDO EPSILON ", i);
            C,E,f1,f2,obj,dmax = init_solution_mo(centro,epsilonValues[i]); #GENERAR SOLUCIÓN INICIAL
            if obj != Inf
                st = solucion(C,E,f1,balance,obj,dmax,0,curveId);
                push!(A,st); #ACTUALIZAR ACHIVO
                println("A:", length(A));
            end
        end
        if length(A) > 0

            break;
        else
            centro = generarC();
            A = solucion[];
        end

    end
    curveId += 1

    #Se guarda primera solución.
    first_C = copy(C);
    first_E = copy(E);
    first_obj = copy(obj);
    first_obj_f1 = copy(f1);
    first_obj_f2 = copy(f2);

    name = "memArchivoPLSAngel_$(numCentro)_$(numExperimento)_$(len_N)_$(neighborhood_structure)_$(prioridad)_Epsilon ";
    name = strConcat(name,epsilonValues);

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

                #Aqui se deben marcar todos los del archivo con el mismo curveId
                indiceVisitado = findall(x -> x==st, A);
                curveIdBuscado = A[indiceVisitado[1]].curveId;
                for j=1:length(A)
                    if (A[j].curveId==curveIdBuscado)
                        A[j].visitado = 1
                    end
                end
                println("MARCANDO COMO VISITADO EN CURVEID ", curveIdBuscado);

                for j=1:len_N
                    println("RESOLVIENDO VECINO ", j);
                    for k = 1:length(epsilonValues)
                        println("USANDO EPSILON ", k);
                        aux_obj, aux_f1, aux_f2, aux_E, aux_dmax = SolverNL(N[j,:],epsilonValues[k]);
                        solNueva = solucion(N[j,:],aux_E,aux_f1,aux_f2,aux_obj,aux_dmax,0,curveId);
                        push!(A,solNueva);
                    end
                    curveId += 1
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
        
        allEpsilons = collect(0.2:0.1:1);
        uniqueCenterItems = unique(v->v.C,A); ## Soluciones con centro único
       # uniqueCenters = map(i -> uniqueCenterItems[i].C, 1:length(uniqueCenterItems)); ## Extracción del centro
        tempA = solucion[];
        ## AGREGAR FRENTES PARA CADA SOLUCIÓN CON EPSILONS RESTANTES Y CORRER ANÁLISIS DE DOMINANCIA DE NUEVO ##
        for i in 1:length(uniqueCenterItems)
            centerToUse = uniqueCenterItems[i].C; ## Centro actual de los centros únicos.
            sameCenterItems = filter(v->v.C==centerToUse,A); ## Filtro todos los items con ese centro
            epsilonsForCenter = unique(v->v.f2,sameCenterItems); ## Saco todos epsilons distintos para ese centro
            epsilonsForCenter = map( i -> epsilonsForCenter[i].f2,1:length(epsilonsForCenter)); ## Extraigo solo epsilon para descartarlos después.
            epsilonsLeft = filter(v->!(v in epsilonsForCenter),allEpsilons); ## Sólo me quedo con epsilons que no hayan sido usados para el centro actual.

            for j in 1:length(epsilonsLeft) ## Creación de soluciones para los epsilons restantes (no usados) del centro actual.
                _obj,_f1,_f2,_E,dmax = SolverNL(centerToUse,epsilonsLeft[i]);
                solNueva = solucion(centerToUse,_E,_f1,epsilonsLeft[i],_obj,dmax,1,-1);
                push!(tempA,solNueva);
            end
        end

        A = vcat(A,tempA);
        A = analisisDominancia(A);
    end

    hipervolumen = hyperVolume(A, puntoRefX,puntoRefY);

    println("[PLS] ====== Resultados ======");
    println("n° iter                 = $t");
    println("Estructura vecindario   = $neighborhood_structure");
    println("Vecinos por iteración   = $len_N");
    println("N° clusters             = $cl");
    println("N° estaciones           = $(length(ESTACIONES))");
    println("1° FO1              = $first_obj_f1");
    println("1° FO2              = $first_obj_f2");

    name = "expArchivoPLSAngel_$(numCentro)_$(numExperimento)_$(len_N)_$(neighborhood_structure)_$(prioridad)_Epsilon ";
    name = strConcat(name,epsilonValues);
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
        write(file, "Hipervolumen          = $hipervolumen\n")
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
