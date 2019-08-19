f = open("parametros.txt") do f
   line = 1
   while !eof(f)
     x = readline(f)
     xx = split(x, ":")
     println(x)
     line += 1
   end
 end
