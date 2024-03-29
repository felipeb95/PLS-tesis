using TickTock
mutable struct solucion
    C
    E
    f1
    f2
    obj
    dmax
    visitado
end

function visitados(A)
    visited = true;
    for i in 1:length(A)
        if(A[i].visitado == 0)
            visited = false;
            break;
        end
    end
    return visited;
end

function generar_vecindario(len_N,C,E,k,mem_C,index_mem_C)
    N = zeros(Int64,len_N,length(CANDIDATAS));
    for i=1:len_N
        aux_C = zeros(Int64,length(CANDIDATAS));
        while true
            aux_C = swap_center_random_grid(C,k);
            #aux_C = swap_center_max_distance_grid(C,E,k)

            if compare_N(N,aux_C,len_N) && validate_connection(aux_C) && compare_N(mem_C,aux_C,index_mem_C)
                index_mem_C += 1;
                push!(mem_C, aux_C);
                N[i,:] = aux_C;
                break;
            end
        end
    end
    return N;
end

function revisarDominanciaEnArchivo(f1, f2, A)
    indicesDominados = [];

    for i in 1:length(A)
        if(f1 <= A[i].f1 && f2 <= A[i].f2)
            push!(indicesDominados, i);
        end
    end

    return indicesDominados;
end


function criterioAcceso(f1,f2, A)
    accede = true;
    for i in 1:length(A)
        if(f1 >= A[i].f1 && f2 >= A[i].f2)
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

function analisisDominancia(A)
    indicesDominados = Int[];
    for i in 1:length(A)
        for j in 1:length(A)
            if(A[i].f1 < A[j].f1 && A[i].f2 <= A[j].f2)
                if(findfirst(isequal(j),indicesDominados)==nothing)
                    push!(indicesDominados, j);
                end
            else
                if(A[i].f1 > A[j].f1 && A[i].f2 >= A[j].f2)
                    if(findfirst(isequal(i),indicesDominados)==nothing)
                        push!(indicesDominados, i);
                    end
                    break;
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

function crowdingDistance(A)
    T =  length(A); # Este es el tamaño del Archivo
    M =  2; # la cantidad de objetivos
    cdScores =  zeros(Int64,T); # Inicialización de CD scores

    for m in m:M
        A = ascendingBubbleSort(A,m); # Sort mediante el m-iésimo objetivo
        cdScores[1] = cdScores[T] = Inf; # Límite superior e inferior son infinito
        for i in 2:T-1
            if(m==1)
                maxObjValue = maximum(x->x.f1, A);
                minObjValue = minimum(x->x.f1, A);
                cdScores[i] = cdScores[i] + ((A[i+1].f1 - A[i-1].f1) / (maxObjValue - minObjValue));
            end
            if(m==2)
                maxObjValue = maximum(x->x.f2, A);
                minObjValue = minimum(x->x.f2, A);
                cdScores[i] = cdScores[i] + ((A[i+1].f2 - A[i-1].f2) / (maxObjValue - minObjValue));
            end
        end
    end
return cdScores;
end

function crowdingDistanceForSingleObjective(A,m)
    T =  length(A); # Este es el tamaño del Archivo
    cdScores =  zeros(Float64,T); # Inicialización de CD scores

        A = ascendingBubbleSort(A,m); # Sort mediante el m-iésimo objetivo (1 ó 2)
        cdScores[1] = cdScores[T] = Inf64; # Límite superior e inferior son infinito
        for i in 2:T-1
            if(m==1)
                maxObjValue = maximum(x->x.f1, A);
                minObjValue = minimum(x->x.f1, A);
                cdScores[i] = cdScores[i] + ((A[i+1].f1 - A[i-1].f1) / (maxObjValue - minObjValue));
            end
            if(m==2)
                maxObjValue = maximum(x->x.f2, A);
                minObjValue = minimum(x->x.f2, A);
                cdScores[i] = cdScores[i] + ((A[i+1].f2 - A[i-1].f2) / (maxObjValue - minObjValue));
            end
        end
return cdScores;
end

function ascendingBubbleSort(A,m)
    # m es el m-iésimo objetivo
    # Si m = 1, objtivo es f1
    # Si m = 2, objetivo es f2
    temp = nothing;

    for i in 1:length(A)-1
        for j in 2:length(A)
            if m == 1
                if(A[j-1].f1 > A[j].f1)
                    temp = A[j-1];
                    A[j-1] = A[j];
                    A[j] = temp;
                end
            else
            if m == 2
                if(A[j-1].f2 > A[j].f2)
                    temp = A[j-1];
                    A[j-1] = A[j];
                    A[j] = temp;
                end
            end
            end
        end
    end
    return A;
end


function hyperVolume(archivo,refPointX,refPointY)
    ascendingBubbleSort(archivo,1);
    complement = solucion[];
    epsilonsFound = unique(v->v.f2,archivo);
    epsilons = map( i -> epsilonsFound[i].f2, 1:length(epsilonsFound));
    revEpsilons = sort(epsilons,rev=true);
    for i in 1:length(archivo)
        if i == 1 ## Primera solución archivo
            compPoint = solucion(nothing,nothing,archivo[i].f1, refPointY,Inf,1,nothing); ## Item solución con solo valores signficativos para f1 y f2.
            push!(complement, compPoint);
        else ## Cualquier otra solución archivo
            compPoint = solucion(nothing,nothing,archivo[i].f1, revEpsilons[i-1],Inf,1,nothing); ## Item solución con solo valores signficativos para f1 y f2.
            push!(complement, compPoint);
        end

        if i == length(archivo) ## Última solución archivo
            compPoint = solucion(nothing,nothing,refPointX, archivo[i].f2,Inf,1,nothing); ## Item solución con solo valores signficativos para f1 y f2.
            push!(complement, compPoint);
        end
    end

    _archivo = vcat(archivo,complement);
    _referenceArea = refPointX * refPointY;
    _area = 0;
    _epsilons = epsilons;
    push!(_epsilons,refPointY); ## Agrego a epsilons la coordenada Y del punto de referencia para poder cerrar el polígono.
    _epsilons = sort(_epsilons);

    for i in 1:length(epsilons)-1
        yLarge = _epsilons[i+1] - _epsilons[i];
        pointsFoundForEps = filter(x->x.f2 == _epsilons[i],_archivo); ## Todos los puntos cuyo epsilon es igual a epsilon[i].
        onlyXList= map( i -> pointsFoundForEps[i].f1, 1:length(pointsFoundForEps)); ## Guardo solo la coordenada x de los puntos encontados para ese epsilon[i].
        xLowest = minimum(onlyXList); ## Busco el minimo valor X que me retornó la función para aquel epsilon[i].
        xLarge = refPointX - xLowest;
        _area = _area + yLarge * xLarge;                
    end
    hyperVol = _area / _referenceArea;
return hyperVol;
end
