using JuMP, Gurobi, AmplNLWriter

function SolverNL(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    #m = Model(with_optimizer(AmplNLWriter.Optimizer, "gurobi",  ["OutputFlag=1"]))
    m = Model(with_optimizer(Gurobi.Optimizer, OutputFlag=0))
    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
    f1 = @expression(m,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));
    valuef2 = rand(minEpsilon:.01:maxEpsilon);
    @objective(m,Min,f1);

    for i in ESTACIONES
        @constraint(m,sum(x[i,j] for j in CANDIDATAS) == 1)
    end

    for i in ESTACIONES
        for j in CANDIDATAS
            @constraint(m,x[i,j] <= c[i,j]*C[j])
        end
    end

    for j in CANDIDATAS
        for l in PRIORIDADES
            if l == 1
                pxsum = @expression(m, sum(prior[i,l]*x[i,j] for i in ESTACIONES))
                psum = @expression(m, sum(prior[i,l] for i in ESTACIONES))
                @constraint(m,(pxsum  - floor(psum/cl)*C[j]) <= prioridad)
                @constraint(m,(floor(psum/cl)*C[j] - pxsum) <= prioridad)
            end
        end
    end

    for j in CANDIDATAS
        expr2 = @expression(m,sum(r_menos[i]*x[i,j] for i in ESTACIONES));
        expr3 = @expression(m,sum(r_mas[i]*x[i,j] for i in ESTACIONES));
        @constraint(m, (expr2 - expr3)  <= valuef2  *  (expr2 + expr3));
        @constraint(m,(-expr2 + expr3) <= valuef2  *  (expr2 + expr3));
    end
    optimize!(m)
    status = termination_status(m);
    Z_opt = objective_value(m);
    x_opt = value.(x);


    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    println("FUNCION 1 POR RETORNAR: ", value(f1));
    println("FUNCION 2 POR RETORNAR: ", valuef2);
    println("STATUS: ", status);

    ##CALCULO DE DMAX
    dmax = fitness_all(x_opt, C)

    if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || Z_opt - floor(Z_opt) != 0 || (length(x_opt) == 0)
        return Inf, Inf, Inf, E, dmax;
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, value(f1), valuef2, E, dmax
    end
end
