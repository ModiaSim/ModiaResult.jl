using ModiaResult
using DataFrames
using CSV

result1 = CSV.File("$(ModiaResult.path)/test/test_71_Tables_Rotational_First.csv")
result2 = DataFrames.DataFrame(result1)

println("\n... test_71_Tables_Rotational_First.jl:")
println("CSV-Table (result1 = CSV.File(fileName)):\n")
ModiaResult.showInfo(result1)

println("\nDataFrame-Table (result2 = DataFrame(result1)):\n")
ModiaResult.showInfo(result2)