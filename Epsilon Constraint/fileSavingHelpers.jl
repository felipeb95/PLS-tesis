function strConcat(str,epsilon)
          for x=1:length(epsilon)
                    str = string(str,"$(epsilon[x])");
                    if x != length(epsilon)
                              str = string(str,"_");
                    end
          end
return str;
end
