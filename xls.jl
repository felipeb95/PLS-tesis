using XLSX;

XLSX.openxlsx("resultados.xlsx", mode="w") do xf
    sheet = xf[1]
    XLSX.rename!(sheet, "nueva hoja")
    sheet["A1"] = "this"
    sheet["A2"] = "is a"
    sheet["A3"] = "new file"
    sheet["A4"] = 100
end
