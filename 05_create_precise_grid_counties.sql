\set county_grid :v3

SELECT 
	A.*
INTO 
	:county_grid
FROM 
	temp_hex_grid as A, us_counties as B
WHERE
	ST_Intersects(B.geom,A.the_geom)
AND
	B.geoid=:'v1';
