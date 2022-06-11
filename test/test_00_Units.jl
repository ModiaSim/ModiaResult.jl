module test_00_Units

import ModiaResult
using  Unitful
using  Test

s = 2.1u"m/s"
v = [1.0, 2.0, 3.0]u"m/s"

s_unit = ModiaResult.unitAsParseableString(s)
v_unit = ModiaResult.unitAsParseableString(v)

@test s_unit == "m*s^-1"
@test v_unit == "m*s^-1"

# Check that parsing the unit string works
s_unit2 = uparse(s_unit)
v_unit2 = uparse(s_unit)

end