module Runtests

using Test

@testset "Test ModiaResult/test" begin
    include("test_01_OneScalarSignal.jl")
    include("test_02_OneScalarSignalWithUnit.jl")
    include("test_03_OneVectorSignalWithUnit.jl")
    include("test_04_ConstantSignalsWithUnit.jl")
    include("test_05_ArraySignalsWithUnit.jl")
    include("test_06_OneScalarMeasurementSignal.jl")
    include("test_07_OneScalarMeasurementSignalWithUnit.jl") 

    include("test_20_SeveralSignalsInOneDiagram.jl")
    include("test_21_VectorOfPlots.jl")
    include("test_22_MatrixOfPlots.jl")
    include("test_23_MatrixOfPlotsWithTimeLabelsInLastRow.jl")
    include("test_24_Reuse.jl")
    include("test_25_SeveralFigures.jl")
    include("test_26_TooManyLegends.jl")    
    
    include("test_40_Warnings.jl")    
    
    include("test_51_OneScalarMonteCarloMeasurementsSignal.jl")
    include("test_52_MonteCarloMeasurementsWithDistributions.jl")    
        
    include("test_70_ResultDict.jl")
    include("test_71_Tables_Rotational_First.jl")  
    include("test_72_ResultDictWithMatrixOfPlots.jl")
end

end