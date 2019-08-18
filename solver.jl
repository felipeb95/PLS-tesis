using JuMP, AmplNLWriter

function SolverNL(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro",  ["outlev=0"]))
    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
    @variable(m,beta, start = 0.0);
    f1 = @NLexpression(m,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));
    f2 = @NLexpression(m,beta);
    @NLobjective(m,Min,a_ws*f1+(1-a_ws)*f2);

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
            pxsum = @expression(m, sum(prior[i,l]*x[i,j] for i in ESTACIONES))
            psum = @expression(m, sum(prior[i,l] for i in ESTACIONES))
            @constraint(m,(pxsum  - floor(psum/cl)*C[j]) <= prioridad)
            @constraint(m,(floor(psum/cl)*C[j] - pxsum) <= prioridad)
        end
    end

    f2Array = @NLexpression(m, [j = 1:num_candidatas], abs(sum(r_menos[i]*x[i,j] for i in ESTACIONES)-sum(r_mas[i]*x[i,j] for i in ESTACIONES)))
    @NLconstraint(m, [j = 1:num_candidatas], beta*(sum(r_menos[i]*x[i,j] for i in ESTACIONES)+sum(r_mas[i]*x[i,j] for i in ESTACIONES)) >= f2Array[j])

    optimize!(m)
    status = termination_status(m);
    Z_opt = objective_value(m);
    x_opt = value.(x);
    println("TERMINATION STATUS: ", status);
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    println("FUNCION 1 POR RETORNAR: ", value(f1));
    println("FUNCION 2 POR RETORNAR: ", value(f2));

    if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (length(x_opt) == 0)
        return Inf, zeros(num_stations,num_stations);
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, value(f1), value(f2), E
    end
end
