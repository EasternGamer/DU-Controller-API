function Controller(a,b,c)local d={}if a==nil then a=true end;if a then b=false;c=false end;if b==nil then b=false end;if c==nil then c=true end;local e=system.getAxisValue;local function f()if c then return(e(3)+1)*0.5 else local g=e(3)if not a then return g else if g<0 then return 0 else return g end end end end;local function h()if b then return(e(4)+1)*0.5 elseif a then local g=-e(3)if g>0 then return g else return 0 end end;return 0 end;function d.getRawRoll()return e(0)end;function d.getRawPitch()return e(1)end;function d.getRawYaw()return e(2)end;function d.getRawThrottle()return f()end;function d.getRawBrake()return h()end;function d.getRawStrafe()return e(5)end;function d.getRawVertical()return e(6)end;function d.getRawAxis7()return e(7)end;function d.getRawAxis8()return e(8)end;function d.getRawAxis9()return e(9)end;return d end