using Plots

#Ejemplo de plotear un archivo
f1 = [337421,315306,331658,319210,313801,327082,323574,324860,309819]
f2 = [.2,.27,.22,.26,.28,.23,.25,.24,.29]
#scatter(f1,f2,label="Archivo")

#Ejemplo para plotear multiples frentes (util si queremos mostrar como iba cambiando el frente por iteracion)
f1 = [[300, 330, 320, 305] [200, 302, 239, 259]]
f2 = [[0.1, 0.2, 0.5, 0.7] [0.3, 0.6, 0.1, 0.3]]
a = scatter(f1,f2,label=["Ite 1" "Ite 2"])

fnA = "grafico1";
fnB = "grafico2";

## Guardar como imagen.
savefig(fnA)
savefig(a,fnA);


