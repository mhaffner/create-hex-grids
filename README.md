# create-hex-grids

The script `generate-hex-grids.sql` generates hexogonal grids in
PostgreSQL/PostGIS. It is set up to be called from a terminal with the
parameters as command line arguments. 

Example:

`psql -U <user-name> -d <database-name> -a -f -v v1=1000 -v v2=0 -v v3=0 -v v4=5000 -v v5=5000`

where

`v1 = diameter of each hexagon in the units of the projection

v2 = minimum x coordinate

v3 = minimum y coordinate

v4 = maximum x coordinate

v5 = maximum y coordinate`
