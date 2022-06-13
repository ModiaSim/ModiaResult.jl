module test_70_MissingValues

using ModiaResult
using ModiaResult.OrderedCollections
using ModiaResult.Unitful
@usingModiaPlot

time1 =  0.0 : 0.1 : 3.0
time2 =  3.0 : 0.1 : 11.0
time3 = 11.0 : 0.1 : 15
t     = vcat(time1,time2,time3)*u"s"
sigA  = vcat(0.5*sin.(time1), 0.5*sin.(time2), 0.5*sin.(time3))*u"m"
sigB  = vcat(fill(missing,length(time1)), 1.1*sin.(time2)u"m/s", 1.1*sin.(time3)u"m/s")     
sigC  = vcat(fill(missing,length(time1)), cos.(time2)u"N*m", fill(missing,length(time3)))  #should be clocked

result = OrderedDict{String,Any}("time" => t, 
                                 "sigA" => sigA,
                                 "sigB" => sigB,
                                 "sigC" => sigC)  

println("\n... test_70_MissingValues:\n")
ModiaResult.showResultInfo(result)

plot(result, ("sigA", "sigB", "sigC"))



end