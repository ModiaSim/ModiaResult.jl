module test_24_Reuse

import ModiaResult
include("$(ModiaResult.path)/test/test_24_Reuse.jl")

ModiaResult.@usingModiaPlot

plot(result1, ("phi", "w"), prefix="Sim 1:", heading="Test reuse")
plot(result2, ("phi", "w"), prefix="Sim 2:", reuse=true)

end