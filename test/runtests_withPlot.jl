module Runtests_withPlot

# Run all tests with the activated plot package

import ModiaResult
using Test

const  test_title = "Tests with plot package " * ModiaResult.currentPlotPackage()

@testset "$test_title" begin
    include("include_all.jl")
end

end