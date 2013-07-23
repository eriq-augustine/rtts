# This will not block.
# Returns true on success.
# Failure of this function is probably because the lambda takes more than 1 parameter.
# |callbackLambda| must return true to get called again.
def timerCallback(interval, callbackLambda)
   if (!callbackLambda || callbackLambda.arity != 0)
      return false
   end

   Thread.new{
      while true
         # Seeing some more consistent results with select than with sleep.
         select(nil, nil, nil, interval)

         if (!callbackLambda.call())
            break
         end
      end
   }

   return true
end
