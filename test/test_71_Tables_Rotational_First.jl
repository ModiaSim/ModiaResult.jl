module test_71_Tables_Rotational_First

using ModiaResult
using DataFrames
using CSV
ModiaResult.@usingModiaPlot

result1 = CSV.File("$(ModiaResult.path)/test/test_71_Tables_Rotational_First.csv")
result2 = DataFrames.DataFrame(result1)

println("\n... test_71_Tables_Rotational_First.jl:")
println("CSV-Table (result1 = CSV.File(fileName)):\n")
ModiaResult.printResultInfo(result1)

println("\nDataFrame-Table (result2 = DataFrame(result1)):\n")
ModiaResult.printResultInfo(result2)

plot(result1, ["damper.w_rel", "inertia3.w"], prefix="result1: ")
plot(result2, ["damper.w_rel", "inertia3.w"], prefix="result2: ", reuse=true)

end
