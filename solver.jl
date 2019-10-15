using JuMP, AmplNLWriter

function SolverNL(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro",  ["mip_maxnodes=10 outlev=3"]))
    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
    @variable(m,beta, start = 0.0);
    f1 = @NLexpression(m,(sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS)-idealf1)/(anti_idealf1-idealf1));
    f2 = @NLexpression(m,(beta-idealf2)/(anti_idealf2-idealf2));
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
            if l == 1
                pxsum = @expression(m, sum(prior[i,l]*x[i,j] for i in ESTACIONES))
                psum = @expression(m, sum(prior[i,l] for i in ESTACIONES))
                @constraint(m,(pxsum  - floor(psum/cl)*C[j]) <= prioridad)
                @constraint(m,(floor(psum/cl)*C[j] - pxsum) <= prioridad)
            end
        end
    end

    f2Array = @NLexpression(m, [j = 1:num_candidatas], abs(sum(r_menos[i]*x[i,j] for i in ESTACIONES)-sum(r_mas[i]*x[i,j] for i in ESTACIONES)))
    @NLconstraint(m, [j = 1:num_candidatas], beta*(sum(r_menos[i]*x[i,j] for i in ESTACIONES)+sum(r_mas[i]*x[i,j] for i in ESTACIONES)) >= f2Array[j])

    optimize!(m)
    status = termination_status(m);
    Z_opt = objective_value(m);
    x_opt = value.(x);
    valuef2 = value(f2);
    if valuef2 > 1
        valuef2 = 1;
    end
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    println("FUNCION 1 POR RETORNAR: ", value(f1));
    println("FUNCION 2 POR RETORNAR: ", valuef2);

    ##CALCULO DE DMAX
    dmax = fitness_all(x_opt, C)

    #if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (length(x_opt) == 0)
    #    return Inf, Inf, Inf, E, dmax;
    #else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, value(f1), valuef2, E, dmax
    #end
end
