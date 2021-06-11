using ModiaResult
using Unitful


time0 = [0.0, 15.0]
t     = ([time0], [time0], ModiaResult.TimeSignal)

time1 = 0.0  : 0.1 : 3.0
time2 = 5.0  : 0.1 : 9.5
time3 = 11.0 : 0.1 : 15.0
time4 = 0.0  : 0.1 : 15.0
sigA1 = 0.9*sin.(time1)u"m"
sigA2 = cos.(time2)u"m"
sigA3 = 1.1*sin.(time3)u"m"
sigA  = ([time1, time2, time3], 
         [sigA1, sigA2, sigA3 ], 
         ModiaResult.Continuous)
sigB  = ([time4], [0.7*sin.(time4)u"m/s"], ModiaResult.Continuous)
sigC  = ([time2], [sin.(time2)u"N*m"]    , ModiaResult.Clocked)    
    
result = ModiaResult.ResultDict("time" => t, 
                                "sigA" => sigA,
                                "sigB" => sigB,
                                "sigC" => sigC,
                                defaultHeading = "Signals from test_70_ResultDict.jl")  

println("\n... test_70_ResultDict.jl:\n")
ModiaResult.showInfo(result)

