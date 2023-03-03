function internal_floor_division(dividend,divisor)
 --assumes both are counting numbers
 local quotient=0
 while dividend>=divisor do
  quotient=quotient+1
  dividend=dividend-divisor
 end
 return quotient
end
function internal_natural_number_power(base,exponent)
 local power=new_rational(1,1)
 for round=1,exponent do
  power=power*base
 end
 return power
end
function internal_nth_root_of_integer(degree,radicand)
 --returns an integer
 --assumes degree is a counting number
 --assumes radicand is an integer
 local root=0
 local root_found=false
 if radicand<0 then
  if internal_floor_division(degree,2)*2==degree then
   error("power is imaginary or irrational")
  else
   root=-internal_nth_root_of_integer(degree,-radicand)
  end
 elseif radicand==0 then
  return 0
 else
  --radicand is positive
  while root<=radicand do
   if internal_natural_number_power(new_rational(root,1),degree)==new_rational(radicand,1) then
    root_found=true
    break
   end
   root=root+1
  end
  if root_found==false then
   error("power is imaginary or irrational")
  end
 end
 return root
end
function internal_nth_root_of_rational(degree,radicand)
 --raises an error if the answer is irrational or imaginary
 local root=new_rational(internal_nth_root_of_integer(degree,radicand.numerator),internal_nth_root_of_integer(degree,radicand.denominator)) 
 return root
end
function internal_greatest_common_factor(m,n)
 --assumes n is positive and both are nonzero integers
 m=math.abs(m)
 local greatest_common_denominator=0
 for possible_factor=1,math.min(m,n) do
  if internal_floor_division(m,possible_factor)*possible_factor==m and internal_floor_division(n,possible_factor)*possible_factor==n then
   greatest_common_denominator=possible_factor
  end
 end
 return greatest_common_denominator
end
--metamethod definitions
function internal_return_error()
 error("attempt to directly modify numerator or denominator of rational or add extraneous information")
end
function internal_add_rationals(augend,addend)
 return new_rational(augend.numerator*addend.denominator+addend.numerator*augend.denominator,augend.denominator*addend.denominator)
end
function internal_negate_rational(rational)
 return new_rational(-rational.numerator,rational.denominator)
end
function internal_subtract_rationals(minuend,subtrahend)
 return minuend+-subtrahend
end
function internal_multiply_rationals(multiplier,multiplicand)
 return new_rational(multiplier.numerator*multiplicand.numerator,multiplier.denominator*multiplicand.denominator)
end
function internal_divide_rationals(dividend,divisor)
 if divisor.numerator==0 then
  error("attempt to divide by 0")
 else
  return new_rational(dividend.numerator*divisor.denominator,dividend.denominator*divisor.numerator)
 end
end
function internal_exponentiate_rationals(base,exponent)
 --raises an error if the answer is irrational or imaginary
 reciprocate=exponent<new_rational(0,1)
 local power=internal_natural_number_power(base,math.abs(exponent.numerator))
 power=internal_nth_root_of_rational(exponent.denominator,power)
 if reciprocate then
  power=new_rational(1,1)/power
 end
 return power
end
function floor_of_rational(rational)
 --returns an integer
 if rational.numerator<0 then
  if rational.denominator~=1 then
   local minus_rational=-rational
   return -(internal_floor_division(minus_rational.numerator,minus_rational.denominator)+1)
  else
   return rational.numerator
  end
 elseif rational.numerator==0 then
  return new_rational(0,1)
 else
  return internal_floor_division(rational.numerator,rational.denominator)
 end
end
function internal_floor_divide_rationals(dividend,divisor)
 --returns an integer
 return floor_of_rational(internal_divide_rationals(dividend,divisor))
end
function internal_length_of_rational()
 error("attempt to find length of rational")
end
function internal_rationals_are_equal(left_hand_side,right_hand_side)
 if left_hand_side.numerator==right_hand_side.numerator and left_hand_side.denominator==right_hand_side.denominator then
  return true
 else
  return false
 end
end
function internal_left_hand_rational_is_less_than_right_hand_rational(left_hand_side,right_hand_side)
 if left_hand_side.numerator*right_hand_side.denominator<right_hand_side.numerator*left_hand_side.denominator then
  return true
 else
  return false
 end
end
function internal_left_hand_rational_is_less_than_or_equal_to_right_hand_rational(left_hand_side,right_hand_side)
 if left_hand_side.numerator*right_hand_side.denominator<=right_hand_side.numerator*left_hand_side.denominator then
  return true
 else
  return false
 end
end
function internal_rational_to_string(rational)
 return rational.numerator.."/"..rational.denominator
end
function new_rational(numerator,denominator)
 numerator=math.tointeger(numerator)
 denominator=math.tointeger(denominator)
 if numerator==nil or denominator==nil then
  error("attempt to create rational with numerator or denominator not integer")
 end
 if denominator==0 then
  error("attempt to create rational with denominator 0")
 end
 local reduced_numerator=1
 local reduced_denominator=1
 if numerator==0 then
  reduced_numerator=0
  reduced_denominator=1
 else
  if denominator<0 then
   numerator=-numerator
   denominator=-denominator
   print("here")
  end
  if numerator>0 then
   reduced_numerator=internal_floor_division(numerator,internal_greatest_common_factor(numerator,denominator))
  else
   reduced_numerator=-internal_floor_division(-numerator,internal_greatest_common_factor(numerator,denominator))
  end
  reduced_denominator=internal_floor_division(denominator,internal_greatest_common_factor(numerator,denominator))
 end
 local rational={}
 local rational_metatable={__metatable="metatable for rational"}
 --metamethods go into metatable
 rational_metatable.__add=internal_add_rationals
 rational_metatable.__sub=internal_subtract_rationals
 rational_metatable.__mul=internal_multiply_rationals
 rational_metatable.__div=internal_divide_rationals
 rational_metatable.__pow=internal_exponentiate_rationals
 rational_metatable.__unm=internal_negate_rational
 rational_metatable.__idiv=internal_floor_divide_rationals
 rational_metatable.__len=internal_length_of_rational
 rational_metatable.__eq=internal_rationals_are_equal
 rational_metatable.__lt=internal_left_hand_rational_is_less_than_right_hand_rational
 rational_metatable.__le=internal_left_hand_rational_is_less_than_or_equal_to_right_hand_rational
 rational_metatable.__index={numerator=reduced_numerator,denominator=reduced_denominator}
 rational_metatable.__newindex=internal_return_error
 rational_metatable.__name=reduced_numerator.."/"..reduced_denominator
 rational_metatable.__tostring=internal_rational_to_string
 setmetatable(rational,rational_metatable)
 return rational
end
