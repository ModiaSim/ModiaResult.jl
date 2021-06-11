
import ModiaResult
using  Test

const  test_title = "Test ModiaPlot_" * ModiaResult.activatedPlotPackage()
const  path = "$(ModiaResult.path)/test_plot"

@testset "$test_title" begin
    include("$path/test_01_OneScalarSignal.jl")
    include("$path/test_02_OneScalarSignalWithUnit.jl")
    include("$path/test_03_OneVectorSignalWithUnit.jl")
    include("$path/test_04_ConstantSignalsWithUnit.jl")
    include("$path/test_05_ArraySignalsWithUnit.jl")
    
    include("$path/test_06_OneScalarMeasurementSignal.jl")
    include("$path/test_07_OneScalarMeasurementSignalWithUnit.jl")
   
    include("$path/test_20_SeveralSignalsInOneDiagram.jl")
    include("$path/test_21_VectorOfPlots.jl")
    include("$path/test_22_MatrixOfPlots.jl")
    include("$path/test_23_MatrixOfPlotsWithTimeLabelsInLastRow.jl")
    include("$path/test_24_Reuse.jl")
    include("$path/test_25_SeveralFigures.jl")
    include("$path/test_26_TooManyLegends.jl")    
    
    include("$path/test_40_Warnings.jl")      
    include("$path/test_42_SaveFigure.jl") 
     
    include("$path/test_51_OneScalarMonteCarloMeasurementsSignal.jl")
    include("$path/test_52_MonteCarloMeasurementsWithDistributions.jl")

    include("$path/test_70_ResultDict.jl")
    include("$path/test_71_Tables_Rotational_First.jl")
    include("$path/test_72_ResultDictWithMatrixOfPlots.jl")

    include("$path/test_41_AllExportedFunctions.jl") 
    
    #include("test_compare/test_01_OneScalarSignal.jl")
    #include("test_compare/test_02_OneScalarSignalWithUnit.jl")
    
end
 
