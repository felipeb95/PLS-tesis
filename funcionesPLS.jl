mutable struct solucion
    C
    E
    f1
    f2
    obj
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

function generar_vecindario(len_N,C,k,mem_C,index_mem_C)
    N = zeros(Int64,len_N,length(CANDIDATAS));
    for i=1:len_N
        aux_C = zeros(Int64,length(CANDIDATAS));
        while true
            aux_C = swap_center_random_grid(C,k);

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
