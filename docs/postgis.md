### Misc notes

- use PostGIS to add geometry columns
- use a GiST index on the geometry column
- perform bbox queries with `&& ST_MakeEnvelope(…)`
- bbox queries that use index are ~40x faster

# Steps

- `brew install postgresql postgis`
  - if need to install old formuale?
    - http://remarkablemark.org/blog/2017/02/03/install-brew-package-version/

- `postgis_topology` ?

  > The PostGIS Topology types and functions are used to manage topological objects such as faces, edges and nodes.

  - e.g. TIGER line data. So we will skip.


```sql
CREATE EXTENSION postgis;

-- add a spatial column to an existing db
SELECT AddGeometryColumn('orgs', 'location', 4326, 'POINT', 2)

-- preview how you will transform separate latlng cols into a geometry column
SELECT longitude, latitude, ST_GeomFromText('POINT( ' || longitude || ' ' || latitude || ')') from orgs limit 10;

-- do it!
UPDATE orgs SET location = ST_GeomFromText('POINT( ' || longitude || ' ' || latitude || ')', 4326);

-- review the results
SELECT mid, longitude, latitude, ST_AsText(location) FROM orgs;

-- do a bbox query
SELECT ST_AsText(location) AS geom
FROM orgs
WHERE location && ST_MakeEnvelope(-91, 29, -89, 31, 4326);

-- add a 2nd spatial column, which will be indexed
SELECT AddGeometryColumn('orgs', 'location_indexed', 4326, 'POINT', 2)

-- review
SELECT mid, longitude, latitude, ST_AsText(location), ST_AsText(location_indexed) FROM orgs;

-- create a gist index on the col
CREATE INDEX orgs_location_indexed_idx ON orgs USING GIST ( location_indexed ); 

-- collect table stats, to optimize query plans
VACUUM ANALYZE orgs;

-- do a bounding_box query on the indexed col
SELECT ST_AsText(location_indexed) AS geom
FROM orgs
WHERE location_indexed && ST_MakeEnvelope(-91, 29, -89, 31, 4326);

-- check that the index is being used
-- ...not on the original col...
EXPLAIN SELECT ST_AsText(location) AS geom
FROM orgs
WHERE location && ST_MakeEnvelope(-91, 29, -89, 31, 4326);
-- ...but on the indexed col...
EXPLAIN SELECT ST_AsText(location_indexed) AS geom
FROM orgs
WHERE location_indexed && ST_MakeEnvelope(-91, 29, -89, 31, 4326);
```
