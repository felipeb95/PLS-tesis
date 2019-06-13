using JuMP, AmplNLWriter, Gurobi, KNITRO

function Gurobi_optimal(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    m = Model(with_optimizer(Gurobi.Optimizer, OutputFlag=0)) #No muestra resultados por consola.
    #m = Model(with_optimizer(optimizer, params))
    #m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro")) #No muestra resultados por consola.
    #m = Model(with_optimizer(Gurobi.Optimizer)) #No muestra resultados por consola.

    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
    f1 = @expression(m,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));

    @objective(m,Min,f1);
    #@NLobjective(m,Min,0.5*sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS) + 0.5*ALGO);

    #for i in ESTACIONES
    #    for j in CANDIDATAS
    #        @constraint(m,x[i,j] >=0)
    #    end
    #end
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

    for j in CANDIDATAS
        expr2 = @expression(m,sum(r_menos[i]*x[i,j] for i in ESTACIONES));
        expr3 = @expression(m,sum(r_mas[i]*x[i,j] for i in ESTACIONES));
        @constraint(m, (expr2 - expr3)  <= balance  *  (expr2 + expr3));
        @constraint(m,(-expr2 + expr3) <= balance  *  (expr2 + expr3));
    end
    optimize!(m)
    status = termination_status(m);
    println("TERMINATION STATUS: ", status);
    Z_opt = objective_value(m);
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    println("FUNCION 1 POR RETORNAR: ", value(f1));
    x_opt = value.(x);
    println("X_OPT: ", length(x_opt));

    if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (Z_opt - floor(Z_opt) != 0 || length(x_opt) == 0)
        return Inf, zeros(num_stations,num_stations);
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, E
    end
end








function Gurobi_optimalMO(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    m = Model(with_optimizer(Gurobi.Optimizer, OutputFlag=0)) #No muestra resultados por consola.
    #m = Model(with_optimizer(optimizer, params))
    #m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro")) #No muestra resultados por consola.
    #m = Model(with_optimizer(KNITRO.Optimizer)) #No muestra resultados por consola.

    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)
    f1 = @expression(m,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));
    #@NLexpression(m,f2Array[j = 1:num_candidatas],abs(sum(r_menos[i]*x[i,j] for i in ESTACIONES)-sum(r_mas[i]*x[i,j] for i in ESTACIONES))/(sum(r_menos[i]*x[i,j] for i in ESTACIONES)+sum(r_mas[i]*x[i,j] for i in ESTACIONES)));
    #f2(x) = max(x);
    #JuMP.register(m, :f2, num_candidatas, f2, autodiff=true);

    @objective(m,Min,f1);
    #@NLobjective(m,Min,0.5*f1+0.5*f2(f2Array));

    #for i in ESTACIONES
    #    for j in CANDIDATAS
    #        @constraint(m,x[i,j] >=0)
    #    end
    #end
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

    for j in CANDIDATAS
        expr2 = @expression(m,sum(r_menos[i]*x[i,j] for i in ESTACIONES));
        expr3 = @expression(m,sum(r_mas[i]*x[i,j] for i in ESTACIONES));
        @constraint(m, (expr2 - expr3)  <= balance  *  (expr2 + expr3));
        @constraint(m,(-expr2 + expr3) <= balance  *  (expr2 + expr3));
    end
    optimize!(m)
    status = termination_status(m);
    println("TERMINATION STATUS: ", status);
    Z_opt = objective_value(m);
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    x_opt = value.(x);
    println("X_OPT: ", length(x_opt));
    println("FUNCION 1 POR RETORNAR: ", value(f1));
    f2 = rand()
    println("FUNCION 2 POR RETORNAR: ", f2);

    if #=(status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) ||=# (Z_opt - floor(Z_opt) != 0 || length(x_opt) == 0)
        return Inf, zeros(num_stations,num_stations);
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, value(f1), f2, E
    end
end






function Ampl_optimal(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    #m = Model(with_optimizer(Gurobi.Optimizer, OutputFlag=0)) #No muestra resultados por consola.
    #m = Model(with_optimizer(optimizer, params))
    m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro")) #No muestra resultados por consola.

    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)

    @objective(m,Min,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));

    #for i in ESTACIONES
    #    for j in CANDIDATAS
    #        @constraint(m,x[i,j] >=0)
    #    end
    #end
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

    for j in CANDIDATAS
        expr2 = @expression(m,sum(r_menos[i]*x[i,j] for i in ESTACIONES));
        expr3 = @expression(m,sum(r_mas[i]*x[i,j] for i in ESTACIONES));
        @constraint(m, (expr2 - expr3)  <= balance  *  (expr2 + expr3));
        @constraint(m,(-expr2 + expr3) <= balance  *  (expr2 + expr3));
    end

    optimize!(m)
    status = termination_status(m);
    println("TERMINATION STATUS: ", status);
    Z_opt = objective_value(m);
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    x_opt = value.(x);
    println("X_OPT: ", length(x_opt));

    if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (Z_opt - floor(Z_opt) != 0 || length(x_opt) == 0)
        return Inf, zeros(num_stations,num_stations);
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, E
    end
end

function Knitro_optimal(C)
    num_stations  = length(ESTACIONES);
    num_candidatas  = length(CANDIDATAS);
    E = zeros(Int64,num_stations);
    m = Model(with_optimizer(KNITRO.Optimizer)) #No muestra resultados por consola.
    #m = Model(with_optimizer(optimizer, params))
    #m = Model(with_optimizer(AmplNLWriter.Optimizer, "knitro")) #No muestra resultados por consola.

    @variable(m,x[i=1:num_stations,j=1:num_candidatas],Bin)

    @objective(m,Min,sum(dist[i, j] * x[i, j] for i in ESTACIONES, j in CANDIDATAS));

    #for i in ESTACIONES
    #    for j in CANDIDATAS
    #        @constraint(m,x[i,j] >=0)
    #    end
    #end
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

    for j in CANDIDATAS
        expr2 = @expression(m,sum(r_menos[i]*x[i,j] for i in ESTACIONES));
        expr3 = @expression(m,sum(r_mas[i]*x[i,j] for i in ESTACIONES));
        @constraint(m, (expr2 - expr3)  <= balance  *  (expr2 + expr3));
        @constraint(m,(-expr2 + expr3) <= balance  *  (expr2 + expr3));
    end

    optimize!(m)
    status = termination_status(m);
    println("TERMINATION STATUS: ", status);
    Z_opt = objective_value(m);
    println("FUNCION OBJETIVO POR RETORNAR: ", Z_opt);
    x_opt = value.(x);
    println("X_OPT: ", length(x_opt));

    if (status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED) || (Z_opt - floor(Z_opt) != 0 || length(x_opt) == 0)
        return Inf, zeros(num_stations,num_stations);
    else
        for i in ESTACIONES
            E[i] = findall(x->x==1,x_opt[i,:])[1];
        end
        return Z_opt, E
    end
end
