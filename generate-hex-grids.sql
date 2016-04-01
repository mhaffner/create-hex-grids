--This script is a modified version of what Rex Douglas created here:
--http://rexdouglass.com/spatial-hexagon-binning-in-postgis/ , which
--was a heavily modified version from the PostGIS docs and can be 
--found here: https://trac.osgeo.org/postgis/wiki/UsersWikiGenerateHexagonalGrid
--
--It improves on the functionality of what Rex created by generating
--regular hexagons and receiving command line arguments for the 
--parameters.

DROP TABLE IF EXISTS hex_grid;
DROP FUNCTION IF EXISTS genhexagons(diam float, xmin float, ymin float, xmax float, ymax float);
CREATE TABLE hex_grid (gid serial not null primary key);
SELECT addgeometrycolumn('hex_grid','the_geom', 0, 'POLYGON', 2); 

CREATE OR REPLACE FUNCTION genhexagons(diam float, xmin float, ymin float, xmax float, ymax float)
RETURNS float AS $total$
declare

	x1 float :=diam*cos(2*pi()*1/6);
	y1 float :=diam*sin(2*pi()*1/6);

	x2 float :=diam*cos(2*pi()*2/6);
	y2 float :=diam*sin(2*pi()*2/6);

	x3 float :=diam*cos(2*pi()*3/6);
	y3 float :=diam*sin(2*pi()*3/6);

	x4 float :=diam*cos(2*pi()*4/6);
	y4 float :=diam*sin(2*pi()*4/6);

	x5 float :=diam*cos(2*pi()*5/6);
	y5 float :=diam*sin(2*pi()*5/6);

	x6 float :=diam*cos(2*pi()*6/6);
	y6 float :=diam*sin(2*pi()*6/6);

	height float :=y2-y4;
	width float :=x6-x3;
	ncol float :=ceil(abs(xmax-xmin)/width);
	nrow float :=ceil(abs(ymax-ymin)/height);

	polygon_string varchar := 'POLYGON((' ||
					x1 || ' ' || y1 || ' , ' ||
					x2 || ' ' || y2 || ' , ' ||
                                        x3 || ' ' || y3 || ' , ' ||
					x4 || ' ' || y4 || ' , ' ||
					x5 || ' ' || y5 || ' , ' ||
					x6 || ' ' || y6 || ' , ' ||
					x1 || ' ' || y1 ||
	                            '))';
BEGIN
    INSERT INTO hex_grid (the_geom) 
	SELECT ST_Translate(the_geom, x_series*6*x1+xmin, y_series*2*y1+ymin)
    	from generate_series(0, ncol::int,1) as x_series,
    	generate_series(0, nrow::int,1) as y_series,
    	(
       		SELECT polygon_string::geometry as the_geom
       		UNION
       		SELECT ST_Translate(polygon_string::geometry, 3*x1, y1)  as the_geom
    	) as two_hex;
    ALTER TABLE hex_grid
    ALTER COLUMN the_geom TYPE geometry(Polygon, 2163)
	USING ST_SetSRID(the_geom,2163);
    RETURN NULL;
END;
$total$ LANGUAGE plpgsql;

SELECT 
	genhexagons(:v1/2,:v2,:v3,:v4,:v5);

-- v1: hexagon diameter in the units of the projection (for EPSG:2163 this would be meters)
-- v2: min x
-- v3: min y
-- v4: max x
-- v5: max y
