include("funciones.jl");
mutable struct solucion
    C::String
    E::String
    f1::Float64
    f2::Float64
    visitado::Int64
end

cdScores = nothing;

sol1 = solucion("C1","E1",10.5,34.3,1);
sol2 = solucion("C2","E2",16.2,28.5,1);
sol3 = solucion("C3","E3",18.33,17.16,0);
sol4 = solucion("C4","E4",19.8,28.91,0);
sol5 = solucion("C5","E5",14.24,19.6,1);


A = solucion[];
push!(A,sol1);
push!(A,sol2);
push!(A,sol3);
push!(A,sol4);
push!(A,sol5);
biggest = maximum(x->x.f2, A);

A = ascendingBubbleSort(A,1);
print("\n - - - - - - Archivo sorteado - - - - - - \n");
for i in 1:length(A)
    print(A[i],"\n");
end

print("\n - - - - - - Scores de CD - - - - - -\n");
cdScores = crowdingDistanceForSingleObjective(A,1)
for i in 1:length(A)
    print(cdScores[i],"\n");
end

NV, NVIndexes = getNoVisitadas(A);
print("\n - - - - - - Soluciones no visitadas en el Archivo sorteado - - - - - -\n");
for i in 1:length(NV)
    print(NV[i]," | Index: ",NVIndexes[i]," | CD-Score: ",cdScores[NVIndexes[i]]);
    if(cdScores[NVIndexes[i]] > 0.5)
          print(" (Muy denso) \n")
    else
          print(" (Poco denso) \n");
          
    end
end





