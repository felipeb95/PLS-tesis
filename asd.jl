function hyperVolume(archivo,epsilons,refPointX,refPointY)
    _area = 0;
    _epsilons = epsilons; ## Se agrega la coordenada Y del punto de referencia para encerrar el polígono.
    push!(_epsilons,refPointY);
    print(_epsilons);
    for i in 1:length(epsilons)-1
          yLarge = epsilons[i+1] - epsilons[i];
           pointsFoundForEps = filter(x->x.f2 == epsilons[i],_archivo); ## Todos los puntos cuyo epsilon es igual a epsilon[i].
           onlyXList= map( i -> pointsFoundForEps[i].f1, 1:length(pointsFoundForEps)); ## Guardo solo la coordenada x de los puntos encontados para ese epsilon[i].
          xLowest = minimum(onlyXList); ## Busco el minimo valor X que me retornó la función para aquel epsilon[i].
          xLarge = refPointX - xLowest;
          _area = _area + yLarge*xLarge;    
    end
return _area
end