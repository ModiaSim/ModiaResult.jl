module test_00_BasicTests

using ModiaResult
using ModiaResult.OrderedCollections
using ModiaResult.Unitful
using Test

# Test units ------------------------------------------------

s = 2.1u"m/s"
v = [1.0, 2.0, 3.0]u"m/s"

s_unit = ModiaResult.unitAsParseableString(s)
v_unit = ModiaResult.unitAsParseableString(v)

@test s_unit == "m*s^-1"
@test v_unit == "m*s^-1"

# Check that parsing the unit string works
s_unit2 = uparse(s_unit)
v_unit2 = uparse(s_unit)


# Test dictionary result ------------------------------------

mutable struct DummyStruct
    r1::Float64
    r2::Float64
end

mutable struct MotorStruct
    r1::Float64
    r2::Float64
end


value1 = 1.0
value2 = [1.0, 2.0]
value3 = [11 12 13; 21 22 23]
structValue = DummyStruct(1.0, 2.0)
motorStruct = MotorStruct(1.0, 2.0)

println("\nDictionary without units")
t1 = range(0.0, stop=10.0, length=100)
result1 = OrderedDict{String,Any}()
result1["time"]        = t1
result1["phi"]         = sin.(t1)
result1["b"]           = Bool[sin(t) > 0 for t in t1]
result1["m"]           = OneValueSignal(value1, length(t1))
result1["r"]           = OneValueSignal(value2, length(t1))
result1["inertia"]     = OneValueSignal(value3, length(t1))
result1["dummyStruct"] = OneValueSignal(structValue, length(t1))
result1["fileName"]    = OneValueSignal("data.txt", length(t1))
ModiaResult.showResultInfo(result1)

println("\nDictionary with units")
t2 = range(0.0, stop=10.0, length=100)
result2 = OrderedDict{String,Any}()
result2["time"]        = t2*u"s"
result2["b"]           = Bool[sin(t) > 0 for t in t2]
result2["phi"]         = sin.(t2)*u"rad"
result2["m"]           = OneValueSignal(value1*u"kg"    , length(t2))
result2["r"]           = OneValueSignal(value2*u"m"     , length(t2))
result2["inertia"]     = OneValueSignal(value3*u"kg*m^2", length(t2))
result2["dummyStruct"] = OneValueSignal(structValue, length(t2))
result2["fileName"]    = OneValueSignal("data.txt", length(t2))
ModiaResult.showResultInfo(result2)
@show typeof( signalValues(result2, "time"    , unitless=true) )
@show typeof( signalValues(result2, "phi"     , unitless=true) )
@show typeof( signalValues(result2, "r"       , unitless=true) )
@show typeof( signalValues(result2, "inertia" , unitless=true) )

println("\nDictionary with missing (Vectors with missing cannot be associated with units)")
time1 = 0.0 : 0.1  : 2.0
time2 = 2.0 : 0.01 : 3.5
time3 = 3.5 : 0.1  : 7.0
t3 = collect(time1)
append!(t3, collect(time2))
append!(t3, collect(time3))
 
sigA = sin.(time1)u"rad"
append!(sigA, cos.(time2)u"rad")
append!(sigA, sin.(time3)u"rad")

sigB = Vector{Union{Missing,quantity(Float64,u"rad/s")}}(missing,length(time1)) 
append!(sigB, sin.(time2)u"rad/s")
append!(sigB, fill(missing, length(time3)))

sigC = Vector{Union{Missing,quantity(Float64,u"rad/s")}}(missing,length(time1))
append!(sigC,fill(missing, length(time2)))
append!(sigC, sin.(time3)u"rad/s")

function sigD()
    global t3, time1, time2
    sigDaux = Vector{Union{Missing,Float64}}(undef, length(t3))
    
    j = 1
    for i = length(time1)+1:length(time1)+length(time2)
        if j == 1 
            sigDaux[i] = 0.5*cos(t3[i])
        end
        j = j > 3 ? 1 : j+1
    end
    return ArraySignal(sigDaux, kind=ModiaResult.Clocked, unit="rad/s")
end

result3 = Dict{String,Any}("time"       => t3*u"s",
                           "load.phi"   => sigA,
                           "load.w"     => sigB,
                           "load.f"     => OneValueSignal([1.0, 2.0, 3.0]*u"N", length(t3)),
                           "load.r_abs" => zeros(length(t3),3)*u"m",                           
                           "motor.J"    => OneValueSignal(1.2*u"kg*m^2", length(t3)),
                           "motor.w_m"  => sigD(),
                           "motor.data" => OneValueSignal(motorStruct, length(t3)),
                           "motor.b"    => Bool[sin(t) > 0 for t in t3],                    
                           "reference"  => OneValueSignal("reference.txt", length(t3))
                           )             
showResultInfo(result3)


end