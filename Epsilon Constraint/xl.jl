using XLSX;

epsilons = collect(0.2:0.1:1.0);
abc = collect('A':'Z');
totalExps = 50;
currentExp = 1;

XLSX.openxlsx("resultados.xlsx", mode="w") do xf
    sheet = xf[1]
	XLSX.rename!(sheet, "resultados")

	row = 1;

	for i in 1:totalExps;
		objectivesA = rand(1:50, 9);
		
		# CELL WITH EXPERIMENT COUNT
		expCell = string("A",row);
		sheet[expCell] = string("EXPERIMENTO ",i);
		
		# CELL WITH EPSILON HEADER
		epsHCell = string("A",row+1);
		sheet[epsHCell] = "Epsilon";

		# CELL WITH FO HEADER
		foCell = string("A",row+2);
		sheet[foCell] = "FO1";

		# CELL WITH HYPERVOLUME HEADER
		hvRow = string("A",row+3);
		sheet[hvRow] = "hyperVolume";
		
		# CELL WITH HYPERVOLUME VALUE
		hvRow = string(abc[2],row+3);
		sheet[hvRow] = rand(250:400);

		for j in 1:length(epsilons)
		
			# ROW WITH EPSILON HEADERS
			epsCell = string(abc[j+1],row+1);
			sheet[epsCell] = epsilons[j];

			# ROW WITH OBJECTIVE VALUES
			valueCell = string(abc[j+1],row+2);
			sheet[valueCell] = objectivesA[j];

		end

	row += 5;

	end
    
end
