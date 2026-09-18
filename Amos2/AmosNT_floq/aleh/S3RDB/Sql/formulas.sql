/* Pt */


create function pt
    (@px real, @py real)
Returns Real
AS
BEGIN
    Return ( select sqrt(@px*@px + @py*@py))
END

GO
/* ETA */

create function ETA
	(@px real,@py real, @pz real)
Returns Real
AS
BEGIN
Return (select 0.5*log(((sqrt(@px*@px + @py*@py + @pz*@pz)) + @pz) /
                       ((sqrt(@px*@px + @py*@py + @pz*@pz)) - @pz)))

END

GO


create function phi
	(@fx Real, @fy real)
returns Real
As
begin 
return atn2(-@fx,-@fy) + pi();
end
GO

create function phi_mpi_pi
	(@x real)
returns real
AS
begin
return @x + ceiling((-1.0/2.0)-@x/(2.0*pi()))*2*pi()
end

GO


create function effectiveMass
(@xMiss Real,@yMiss Real, @x31 Real,@y31 Real)
returns Real
AS
begin
return sqrt(abs(2.0*((@xMiss*@x31)+(@yMiss*@y31))*
		(1-cos(dbo.phi_mpi_pi(dbo.phi(@x31,@y31)-dbo.phi(@xMiss,@yMiss))))))
end


GO


/*Mod Of Vector*/


create function module
	(@v1 Real,@v2 Real)
returns real
As
begin
return sqrt(@v1*@v1+@v2*@v2)
end


GO

create function invmass
	(@ee real, @px real, @py real, @pz real, @r real)
returns real
AS
begin
return abs(sqrt(abs((@ee)*(@ee) - ((@px)*(@px) +
					(@py)*(@py) + (@pz)*(@pz)))) - @r)
end

GO






