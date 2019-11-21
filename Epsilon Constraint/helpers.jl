function fitness_all(X, Y)
    fit = [];
    centers = findall(x->x == 1, Y);
    for i in centers
        max_dist = -Inf;
        stations = findall(x->x == 1, X[:,i]);
        for j in stations
            for k in stations
                max_dist = max(max_dist, dist[j,k] * X[j,i] * X[k,i]);
            end
        end
        push!(fit, max_dist);
    end
    return fit;
end

function order_zones(fit)
    aux = deepcopy(fit);
    sorted_zones = [];
    for i = 1:cl
        max_pos = findmax(aux)[2];
        push!(sorted_zones, max_pos);
        aux[max_pos] = -Inf;
    end
    return sorted_zones;
end


function generarC()
    _C = zeros(Int64,length(CANDIDATAS));
    while true
        _C = init_solution_C_grid();
        if validate_connection(_C)
            break;
        end
    end
    return _C
end

function init_solution_mo()
    _C = zeros(Int64,length(CANDIDATAS));
    _E = zeros(Int64,length(ESTACIONES));
    _obj = Inf;

    while true
        _C = init_solution_C_grid();
        if validate_connection(_C)
            break;
        end
    end
    _obj,_f1,_f2,_E,dmax = SolverNL(_C);
    return _C,_E,_f1,_f2,_obj,dmax;
end

function init_solution_mo(_C)
    _E = zeros(Int64,length(ESTACIONES));
    _obj = Inf;
    _obj,_f1,_f2,_E,dmax = SolverNL(_C);
    return _C,_E,_f1,_f2,_obj,dmax;
end

function init_solution_C()
    _C = zeros(Int64,length(CANDIDATAS));
    for i=1:cl
        while true
            x = rand(CANDIDATAS);
            if (~(_C[x] == 1) && ~(length(findall(x->x==1,_C)) > cl))
                _C[x] = 1;
                break;
            end
        end
    end
    return _C;
end

function init_solution_C_grid()
    _C = zeros(Int64,length(CANDIDATAS));
    for i=1:cl
        zone = findall(x->trunc(x)==1,vec(M[i,:]));
        while true
            x = rand(zone);
            if (~(_C[x] == 1) && ~(length(findall(x->x==1,_C)) > cl))
                _C[x] = 1;
                break;
            end
        end
    end
    return _C;
end

function compare_N(N,C,len_N)
    cond = 0;
    for i=1:len_N
        if N[i,:] == C[:]
            cond = 1;
        end
    end
    if (cond == 0)
        return true;
    else
        return false;
    end
end

function init_prior()
    _P = zeros(Int64,length(ESTACIONES));
    for i in ESTACIONES
        prior_aux = PRIORIDADES[findall(x->x==1,vec(prior[i,:]'))];
        _P[i] = prior_aux;
    end
    return _P;
end

function swap_center_random(C,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];
    for i=1:k
        centers = (x->x==1,_C);
        e = 0;
        while true
            e = rand(centers_old);
            if (~(e in a))
                append!(a,e);
                break;
            end
        end
        x=0;
        while true
            x = rand(CANDIDATAS);
            if (~(x in centers) && ~(x in b) && ~(x in centers_old))
                append!(b,x);
                break;
            end
        end
        _C[a[i]] = 0;
        _C[x] = 1;
    end
    return _C;
end

function swap_center_random_grid(C,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];

    for i=1:k
        zone = 0;
        centers = (x->x==1,_C);
        e = 0;
        while true
            e = rand(centers_old);
            if (~(e in a))
                append!(a,e);
                zone =get_zone(e);
                break;
            end
        end
        x=0;
        while true
            x = rand(findall(x->trunc(x)==1,vec(M[zone,:])));
            if (~(x in centers) && ~(x in b) && ~(x in centers_old))
                append!(b,x);
                break;
            end
        end
        _C[a[i]] = 0;
        _C[x] = 1;
    end
    return _C;
end


function swap_center_max_distance(C,E,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];
    for i=1:k
        centers = (x->x==1,_C);
        e = 0;
        matrix_distances = get_distances_cluster_system(C,E)
        e = trunc(Int,matrix_distances[i,1]);
        append!(a,e);

        x=0;
        x = rand(findall(x-> ~(x in b) && ~(x in centers_old) && ~(x in centers),CANDIDATAS))
        append!(b,x);

        _C[e] = 0;
        _C[x] = 1;
    end
    return _C;
end

function swap_center_max_distance_grid(C,E,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];
    for i=1:k
        centers = (x->x==1,_C);
        e = 0;
        matrix_distances = get_distances_cluster_system(C,E)
        e = trunc(Int,matrix_distances[i,1]);
        append!(a,e);
        zone =get_zone(e);

        x=0;
        while true
            x = rand(findall(x->trunc(x)==1,vec(M[zone,:])));
            if (~(x in centers) && ~(x in b) && ~(x in centers_old))
                append!(b,x);
                break;
            end
        end

        _C[e] = 0;
        _C[x] = 1;
    end
    return _C;
end


function swap_center_priorbal(C,E,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];
    for i=1:k
        centers = (x->x==1,_C);
        e = 0;
        matrix_prior_bal = get_priorbal_system(C,E)
        e = trunc(Int,matrix_prior_bal[i,1]);
        append!(a,e);

        x=0;
        x = rand(findall(x-> ~(x in b) && ~(x in centers_old) && ~(x in centers),CANDIDATAS))
        append!(b,x);

        _C[e] = 0;
        _C[x] = 1;
    end
    return _C;
end

function swap_center_priorbal_grid(C,E,k)
    _C = zeros(Int64,length(CANDIDATAS));
    _C = copy(C);
    centers_old = findall(x->x==1,C)
    a = [];
    b = [];
    for i=1:k
        centers = (x->x==1,_C);
        e = 0;
        matrix_prior_bal = get_priorbal_system(C,E)
        e = trunc(Int,matrix_prior_bal[i,1]);
        append!(a,e);
        zone =get_zone(e);
        x=0
        while true
            x = rand(findall(x->trunc(x)==1,vec(M[zone,:])));
            if (~(x in centers) && ~(x in b) && ~(x in centers_old))
                append!(b,x);
                break;
            end
        end

        _C[e] = 0;
        _C[x] = 1;
    end
    return _C;
end

function connection_calculation()
    num_stations = length(ESTACIONES);
    num_centers = length(CANDIDATAS);
    c = zeros(Int,num_stations,num_centers)
    for i in ESTACIONES
        for j in CANDIDATAS
            z1 = get_zone(i);
            z2 = get_zone(j);
            if (dist[i,j] < dmax) && (same_zone(i,j) || adjacency_matrix[z1,z2] == 1);
                I_d = 1;
                c[i,j] = I_d * acc[i,j];
            else
                c[i,j] = 0;
            end
        end
    end
    return c;
end

function validate_connection(_C)
    stations = findall(x->x==0,_C)
    centers  = findall(x->x==1,_C)
    for i=1:length(centers)
        zone = get_zone(centers[i]);
        stations = findall(x->x==1,vec(M[zone,:]));
        sum_aux = 0;
        for j=1:length(stations)
            sum_aux += c[centers[i],stations[j]];
        end
        if sum_aux == 0
            return false;
        end
    end
    return true;
end

function get_prior_system(C,E)
    centers = findall(x->x==1,C)
    pri = [];
    # pri = zeros(cl,3);
    for i=1:length(centers)
        pri = vcat(pri,[centers[i] get_prior_center(centers[i],E)]);
    end
    return pri;
end

function get_prior_center(center,E)
    stations_center = get_stations_center(center,E);
    sums_prior = zeros(length(PRIORIDADES));
    prior_array = zeros(length(PRIORIDADES),1)
    for l in PRIORIDADES
        for i in stations_center
            if l == findall(x->x==1,vec(prior[i,:]))[1]
                sums_prior[l] += prior[i,l];
            end
        end
    end

    for i=1:length(sums_prior)
        prior_array[i,1] = abs(floor(length(findall(x->x==1,vec(prior[:,i])))[1]/cl) - sums_prior[i]);
        # prior_array[i,2] = sums_prior[i] - floor(length(findall(x->x==1,prior[:,i]))[1]/cl);
    end
    # result1 = floor(sum(P)/cl) - sum_prior;
    # result2 = sum_prior - floor(sum(P)/cl);
    return prior_array';
end

function get_bal_system(C,E)
    centers = findall(x->x==1,C);
    bal = zeros(cl,2);
    for i=1:length(centers)
        bal[i,1] = centers[i];
        bal[i,2] = abs(get_balance_center(centers[i],E));
    end
    return bal;
end

function get_balance_center(center,E)
    suma_rmas = 0;
    suma_rmenos = 0;
    result = 0;
    stations_center = get_stations_center(center,E)
    for i=1:length(stations_center)
        suma_rmas+=r_mas[stations_center[i]];
        suma_rmenos+=r_menos[stations_center[i]];
    end
    result1 = suma_rmas + suma_rmenos == 0 ? 0 : ((-suma_rmas + suma_rmenos)/(suma_rmas + suma_rmenos));
    result2 = suma_rmas + suma_rmenos == 0 ? 0 : ((suma_rmas - suma_rmenos)/(suma_rmas + suma_rmenos));
    return result1;
    #return result1 <= balance && result2 <= balance;
end

function get_stations_center(center,E)
    x = [];
    for i in ESTACIONES
        if (E[i] == center)
            append!(x,i)
        end
    end
    return x;
end

function get_distances_cluster_system(C,E)
    distances = zeros(cl,2);
    iter = 1;
    for i in findall(x->x==1,C)
        stations = [];
        sum = 0;
        stations = get_stations_center(i,E);
        for j in stations
            sum += dist[i,j];
        end
        distances[iter,2] = sum;
        distances[iter,1] = i;
        iter+=1;
    end
    return sortrows(distances, by=x->(x[2]), rev=true);
end

function get_priorbal_system(C,E)
    a = get_prior_system(C,E);
    r,c = size(a);
    b = get_bal_system(C,E);
    prior_bal_system = zeros(cl,2)
    for i=1:r
        prior_bal_system[i,1] = a[i,1];
        prior_bal_system[i,2] = sum(a[i,2:end]) + b[i,2]*100;
    end
    return prior_bal_system = sortrows(prior_bal_system, by=x->(x[2]), rev=true)
end

function get_points(a,b,c,d,M)
    N = size(M)[1]
    points = zeros(length(ESTACIONES)); #452
    index = 1;
    for i=1:N
        if (M[i,3]>a && M[i,3]<=b && M[i,2]<c && M[i,2]>=d)
            # push!(points,trunc(Int64,M[i,1]));
            points[i] = 1;
        end
    end
    return points
end

function get_grid()
    f = open("geodata.txt");
    lines = readlines(f);

    geo_data = zeros(Float64,length(ESTACIONES),3)
    let
        i = 1;
        for line in lines
            data = split(line)
            station = parse(Int64,data[1]);
            latitude = parse(Float64,data[2]);
            longitude = parse(Float64,data[3]);

            geo_data[i,1] = station;
            geo_data[i,2] = latitude;
            geo_data[i,3] = longitude;
            i+=1;
        end
    end
    #lat
    lat_arr = geo_data[:,2];

    #long
    long_arr = geo_data[:,3];


    #min_lat   = minimum(lat_arr);
    min_lat   = 19.3582;
    #max_lat   = maximum(lat_arr);
    max_lat   = 19.444033;

    med_lat  = (max_lat + min_lat) / 2;
    #quarter_lat = (max_lat + med_lat) / 2;
    quarter_lat = 19.42;
    a = min_lat + (med_lat - min_lat)/3;
    b = a + (med_lat - min_lat)/3;

    #min_long  = minimum(long_arr);
    min_long  = -99.20781;
    #max_long  = maximum(long_arr);
    max_long  = -99.13;

    amp1 = (max_long-min_long)/6;
    _1_long = min_long + amp1;
    _2_long = _1_long + amp1;
    _3_long = _2_long + amp1;
    _4_long = _3_long + amp1;
    _5_long = _4_long + amp1;

    c = -99.1910;
    d = -99.15;

    amp2 = (d-c)/3;

    _6_long = c+amp2;
    _7_long = _6_long + amp2;
    amp3 = (d-c)/2;
    _8_long = c + amp3;

    z1 = get_points(min_long,_1_long,max_lat,quarter_lat,geo_data)';
    z3 = get_points(_2_long,_3_long,max_lat,quarter_lat,geo_data)';
    z2 = get_points(_1_long,_2_long,max_lat,quarter_lat,geo_data)';
    z4 = get_points(_3_long,_4_long,max_lat,quarter_lat,geo_data)';
    z5 = get_points(_4_long,_5_long,max_lat,quarter_lat,geo_data)';
    z6 = get_points(_5_long,max_long,max_lat,quarter_lat,geo_data)';
    z7 = get_points(c,_6_long,quarter_lat,med_lat,geo_data)';
    z8 = get_points(_6_long,_7_long,quarter_lat,med_lat,geo_data)';
    z9 = get_points(_7_long,d,quarter_lat,med_lat,geo_data)';
    z10 = get_points(c,_8_long,med_lat,b,geo_data)';
    z11 = get_points(_8_long,d,med_lat,b,geo_data)';
    z12 = get_points(c,_8_long,b,a,geo_data)';
    z13 = get_points(_8_long,d,b,a,geo_data)';
    z14 = get_points(c,_8_long,a,min_lat,geo_data)';
    z15 = get_points(_8_long,d,a,min_lat,geo_data)';

    M = vcat(z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15);
    return M;
end

function same_zone(x,y)
    flag =false;
    zone1 = get_zone(x);
    zone2 = get_zone(y);
    if zone1 == zone2
        flag = true;
    end

    return flag;
end

function get_zone(x)
    return findall(x->trunc(x)==1,M[:,x])[1];
end

function get_adjacency_matrix()
    adjacency_matrix = zeros(Int,15,15)
    adjacency_matrix[1,1] = 1;
    adjacency_matrix[1,2] = 1;
    adjacency_matrix[2,1] = 1;
    adjacency_matrix[2,2] = 1;
    adjacency_matrix[2,3] = 1;
    adjacency_matrix[2,7] = 1;
    adjacency_matrix[3,2] = 1;
    adjacency_matrix[3,3] = 1;
    adjacency_matrix[3,4] = 1;
    adjacency_matrix[3,7] = 1;
    adjacency_matrix[3,8] = 1;
    adjacency_matrix[4,3] = 1;
    adjacency_matrix[4,4] = 1;
    adjacency_matrix[4,5] = 1;
    adjacency_matrix[4,7] = 1;
    adjacency_matrix[4,8] = 1;
    adjacency_matrix[4,9] = 1;
    adjacency_matrix[5,4] = 1;
    adjacency_matrix[5,5] = 1;
    adjacency_matrix[5,6] = 1;
    adjacency_matrix[5,9] = 1;
    adjacency_matrix[6,5] = 1;
    adjacency_matrix[6,6] = 1;
    adjacency_matrix[6,9] = 1;
    adjacency_matrix[7,2] = 1;
    adjacency_matrix[7,3] = 1;
    adjacency_matrix[7,4] = 1;
    adjacency_matrix[7,7] = 1;
    adjacency_matrix[7,8] = 1;
    adjacency_matrix[7,10] = 1;
    adjacency_matrix[8,3] = 1;
    adjacency_matrix[8,4] = 1;
    adjacency_matrix[8,7] = 1;
    adjacency_matrix[8,8] = 1;
    adjacency_matrix[8,9] = 1;
    adjacency_matrix[8,10] = 1;
    adjacency_matrix[8,11] = 1;
    adjacency_matrix[9,4] = 1;
    adjacency_matrix[9,5] = 1;
    adjacency_matrix[9,6] = 1;
    adjacency_matrix[9,8] = 1;
    adjacency_matrix[9,9] = 1;
    adjacency_matrix[9,11] = 1;
    adjacency_matrix[10,7] = 1;
    adjacency_matrix[10,8] = 1;
    adjacency_matrix[10,10] = 1;
    adjacency_matrix[10,11] = 1;
    adjacency_matrix[10,12] = 1;
    adjacency_matrix[10,13] = 1;
    adjacency_matrix[11,8] = 1;
    adjacency_matrix[11,9] = 1;
    adjacency_matrix[11,10] = 1;
    adjacency_matrix[11,11] = 1;
    adjacency_matrix[11,12] = 1;
    adjacency_matrix[11,13] = 1;
    adjacency_matrix[12,10] = 1;
    adjacency_matrix[12,11] = 1;
    adjacency_matrix[12,12] = 1;
    adjacency_matrix[12,13] = 1;
    adjacency_matrix[12,14] = 1;
    adjacency_matrix[12,15] = 1;
    adjacency_matrix[13,10] = 1;
    adjacency_matrix[13,11] = 1;
    adjacency_matrix[13,12] = 1;
    adjacency_matrix[13,13] = 1;
    adjacency_matrix[13,14] = 1;
    adjacency_matrix[13,15] = 1;
    adjacency_matrix[14,12] = 1;
    adjacency_matrix[14,13] = 1;
    adjacency_matrix[14,14] = 1;
    adjacency_matrix[14,15] = 1;
    adjacency_matrix[15,12] = 1;
    adjacency_matrix[15,13] = 1;
    adjacency_matrix[15,14] = 1;
    adjacency_matrix[15,15] = 1;
    return adjacency_matrix;
end
