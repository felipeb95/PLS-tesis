function strConcat(str,epsilon)
          for x=1:length(epsilon)
                    str = string(str,"_$(epsilon[x])");  
          end
return str;
end
