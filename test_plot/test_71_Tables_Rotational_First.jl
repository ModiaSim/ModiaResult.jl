module test_11_Tables_Rotational_First

import ModiaResult
include("$(ModiaResult.path)/test/test_71_Tables_Rotational_First.jl")

ModiaResult.@usingModiaPlot

plot(result1, ["damper.w_rel", "inertia3.w"], prefix="result1: ")
plot(result2, ["damper.w_rel", "inertia3.w"], prefix="result2: ", reuse=true)

end