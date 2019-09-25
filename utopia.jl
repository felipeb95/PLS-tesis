include("load_data.jl");
include("helpers.jl");

using Statistics;
#Inicializar variables globales de balance y prioridad.
global balance          = 1;
global prioridad        = 2;
#Grilla
global M                = get_grid();
#Matriz de adyacencia de zonas.
global adjacency_matrix = get_adjacency_matrix();
#Matriz de conexiones.
global c                = connection_calculation();

using JuMP, AmplNLWriter, Gurobi

num_stations  = length(ESTACIONES);
num_candidatas  = length(CANDIDATAS);
E = zeros(Int64,num_stations);
m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro", ["mip_maxnodes=100 outlev=3"]))
#m = Model(with_optimizer(Gurobi.Optimizer))
@variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
@variable(m,C[i=1:num_candidatas],Bin)
@variable(m,beta, start = 0.0);
f1 = @expression(m,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));
f2 = @NLexpression(m,beta);
#@objective(m,Min,f1);
@NLobjective(m,Min,f2);

@constraint(m,sum(C[j] for j in CANDIDATAS) == 15)


for i in ESTACIONES
    @constraint(m,sum(x[i,j] for j in CANDIDATAS) == 1)
end

for i in ESTACIONES
    for j in CANDIDATAS

        if C[j] == 1
            @constraint(m,x[i,j] <= c[i,j]*C[j])
        end

        #if C[j] == 1
            @constraint(m,x[i,j] <= c[i,j]*C[j])
        #end
    end
end

for j in CANDIDATAS
    if C[j] == 1
        for l in PRIORIDADES
            pxsum = @expression(m, sum(prior[i,l]*x[i,j] for i in ESTACIONES))
            psum = @expression(m, sum(prior[i,l] for i in ESTACIONES))
            @constraint(m,(pxsum  - floor(psum/cl)*C[j]) <= prioridad)
            @constraint(m,(floor(psum/cl)*C[j] - pxsum) <= prioridad)
        end
    end
    #if C[j] == 1
        for l in PRIORIDADES
            if l == 1
                pxsum = @expression(m, sum(prior[i,l]*x[i,j] for i in ESTACIONES))
                psum = @expression(m, sum(prior[i,l] for i in ESTACIONES))
                @constraint(m,(pxsum  - floor(psum/cl)*C[j]) <= prioridad)
                @constraint(m,(floor(psum/cl)*C[j] - pxsum) <= prioridad)
            end
        end
    #end
end

f2Array = @NLexpression(m, [j = 1:num_candidatas], abs(sum(r_menos[i]*x[i,j] for i in ESTACIONES)-sum(r_mas[i]*x[i,j] for i in ESTACIONES)))
@NLconstraint(m, [j = 1:num_candidatas], beta*(sum(r_menos[i]*x[i,j] for i in ESTACIONES)+sum(r_mas[i]*x[i,j] for i in ESTACIONES)) >= f2Array[j])

optimize!(m)
status = termination_status(m);
Z_opt = objective_value(m);
x_opt = value.(x);
C_opt = value.(C);
println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
#println("FUNCION 1 POR RETORNAR: ", value(f1));
#println("FUNCION 2 POR RETORNAR: ", value(f2));
println("FUNCION 1 POR RETORNAR: ", value(f1));
println("FUNCION 2 POR RETORNAR: ", value(f2));

if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (length(x_opt) == 0)
    #inf
else
    for i in ESTACIONES
        E[i] = findall(x->x==1,x_opt[i,:])[1];
    end
    #no inf
end
