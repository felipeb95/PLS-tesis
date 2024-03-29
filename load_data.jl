open("Ins_PT_452_15.dat") do data
    st = read(data,String);
    splitst = split(st, r":|\[|\]|\n");
    filter!(e->!all(isspace, e)&&e!="",splitst);
    i = 1;
    while i <= length(splitst)
        line = splitst[i];
        i = i + 1;
        if line == "ESTACIONES"
            global ESTACIONES = [parse(Int, s) for s in split(splitst[i],r"\t")];
        elseif line == "CANDIDATAS"
            global CANDIDATAS = [parse(Int, s) for s in split(splitst[i],r"\t")];
        elseif line == "PRIORIDADES"
            global PRIORIDADES = [parse(Int, s) for s in split(splitst[i],r"\t")];
        elseif line == "r_mas"
            global r_mas = [parse(Int, s) for s in split(splitst[i],r"\t")];
        elseif line == "r_menos"
            global r_menos = [parse(Int, s) for s in split(splitst[i],r"\t")];
        elseif line == "cl"
            global cl = parse(Int, splitst[i]);
        elseif line == "balance"
            global balance = parse(Float64, splitst[i]);
        elseif line == "prioridad"
            global prioridad = parse(Int, splitst[i]);
        elseif line == "dmax"
            global dmax = parse(Int, splitst[i]);
        elseif line == "dist"
            terminalnum = length(ESTACIONES);
            distances = zeros(terminalnum,terminalnum);
            for j in 1:terminalnum
                distances[j,:] = [parse(Int, s) for s in split(splitst[i+j-1],r"\t")];
            end
            i = i + terminalnum - 1;
            global dist = distances;
        elseif line == "acc"
            terminalnum = length(ESTACIONES);
            access = zeros(terminalnum,terminalnum);
            for j in 1:terminalnum
                access[j,:] = [parse(Int, s) for s in split(splitst[i+j-1],r"\t")];
            end
            i = i + terminalnum - 1;
            global acc = access;
        elseif line == "prior"
            terminalnum = length(ESTACIONES);
            priorities = zeros(terminalnum,4);
            for j in 1:terminalnum
                priorities[j,:] = [parse(Int, s) for s in split(splitst[i+j-1],r"\t")];
            end
            i = i + terminalnum - 1;
            global prior = priorities;
        end
        i = i + 1;
    end
end
