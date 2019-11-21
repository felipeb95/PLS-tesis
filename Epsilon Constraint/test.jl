include("load_data.jl");
include("gurobi.jl");
include("helpers.jl");
function connection_calculation2(dist_max)
    num_stations = length(ESTACIONES);
    num_centers = length(CANDIDATAS);
    c = zeros(Int,num_stations,num_centers)
    for i in ESTACIONES
        for j in CANDIDATAS
            if (dist[i,j] < dist_max)
                I_d = 1;
                c[i,j] = I_d * acc[i,j];
            else
                c[i,j] = 0;
            end
        end
    end
    return c;
end

global_distances = zeros(Int,101926);
iter = 1;
for i in ESTACIONES[1:end-1]
    for j in ESTACIONES[i+1:end]
        # push!(global_distances,dist[i,j])
        global_distances[iter] = dist[i,j];
        iter+=1;
    end
end

length(global_distances)
minimum(global_distances)
maximum(global_distances)
sum(global_distances)/length(global_distances)
std(global_distances)
dmax
# ================== #

C = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0]
E = [15, 15, 115, 15, 15, 115, 15, 115, 15, 450, 115, 115, 15, 15, 15, 15, 115, 115, 115, 115, 15, 15, 15, 15, 15, 450, 115, 15, 450, 450, 450, 15, 15, 15, 15, 15, 15, 15, 15, 134, 450, 15, 450, 15, 67, 67, 15, 450, 15, 67, 67, 88, 67, 67, 88, 153, 67, 67, 153, 67, 153, 67, 67, 153, 450, 67, 67, 67, 153, 153, 67, 67, 67, 67, 67, 153, 67, 67, 67, 67, 153, 450, 153, 153, 115, 115, 450, 88, 88, 88, 88, 88, 88, 88, 88, 88, 88, 450, 450, 88, 88, 88, 15, 88, 88, 88, 115, 88, 88, 88, 212, 450, 115, 115, 115, 115, 115, 115, 115, 115, 115, 88, 134, 134, 115, 134, 115, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 153, 134, 134, 134, 153, 134, 134, 134, 153, 153, 153, 153, 153, 153, 153, 153, 134, 153, 115, 153, 153, 153, 153, 153, 67, 67, 67, 305, 67, 67, 305, 305, 450, 305, 450, 67, 67, 153, 153, 67, 153, 115, 67, 67, 67, 67, 67, 67, 67, 67, 212, 221, 15, 212, 212, 221, 221, 212, 212, 212, 221, 221, 212, 212, 221, 212, 212, 221, 221, 212, 212, 221, 221, 221, 221, 212, 212, 221, 221, 221, 212, 212, 212, 212, 212, 221, 221, 221, 221, 212, 212, 221, 212, 221, 221, 221, 221, 212, 221, 221, 221, 221, 221, 212, 212, 15, 15, 15, 15, 15, 15, 15, 450, 115, 450, 115, 15, 450, 450, 15, 88, 115, 450, 450, 450, 450, 450, 450, 450, 450, 450, 450, 450, 450, 153, 153, 153, 153, 153, 318, 318, 318, 305, 305, 305, 305, 305, 305, 318, 305, 318, 318, 318, 318, 318, 318, 318, 318, 318, 318, 318, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 318, 305, 318, 318, 318, 318, 318, 318, 318, 318, 318, 360, 305, 305, 305, 353, 305, 353, 353, 353, 360, 318, 360, 360, 360, 318, 360, 360, 360, 360, 353, 353, 353, 353, 353, 353, 353, 353, 353, 353, 353, 360, 360, 360, 360, 360, 353, 353, 353, 353, 353, 353, 353, 353, 353, 353, 353, 353, 360, 360, 360, 360, 360, 360, 360, 353, 353, 416, 416, 353, 416, 416, 416, 416, 416, 416, 416, 416, 416, 416, 360, 416, 360, 416, 427, 360, 360, 360, 360, 360, 427, 427, 427, 427, 427, 427, 427, 427, 416, 416, 416, 416, 416, 416, 416, 416, 416, 416, 416, 427, 427, 427, 427, 427, 427, 427, 427, 427, 427, 427, 416, 416, 416, 416, 427, 427, 427, 427, 427, 427, 427, 427, 15, 88, 15, 450, 221, 212]


a = get_prior_system(C,E)
b = get_bal_system(C,E)
get_priorbal_system(C,E)

#.FO
sum(get_distances_cluster_system(C,E)[1:end,2])

distances = zeros(length(ESTACIONES) - cl);
iter = 1;
for i in find(x->x==1,C)
    stations = get_stations_center(i,E);
    for j in stations
        if i!=j
            distances[iter] = dist[i,j];
            iter+=1;
        end
    end
end

minimum(distances)
maximum(distances)
sum(distances)/length(distances)
sqrt(var(distances))

# ================== #
balance        = 0.35;
prioridad      = 8;

# ================== #
c = connection_calculation();
@time Gurobi_optimal(C)
# ================== #
dist_max = maximum(distances)*1700
c = connection_calculation2(dist_max)
@time Gurobi_optimal(C)