# Spatial Benchmarks

A testbed for benchmarking basic geospatial queries across a range of data stores.

## Findings

### TLDR

1 second of PostGIS time ≈ 6 seconds of Elasticsearch time ≈ 7 seconds of Mongo time

### The test

Perform [a set of ~100 bounding box queries](queries.json) that represent a moving window, as might be fetched from a front-end map client, over a swath of the USA extending from New York to Florida.

Repeat this 100 times for each data store.

### The results

#### N=100

|Data store|Version|Index|Duration|Normalized|
|---|---|---|---|---|
|Postgres / PostGIS|10.1 / 2.4|GiST|2.69 sec|1.0|
|Elasticsearch|2.4|n/a|14.97 sec|5.72|
|MongoDB|3.4|2dsphere|18.44 sec|7.04|

### Misc notes

- Mongo
  - use a `2dsphere` index on the geometry field
  - use a `$geoWithin` query with the `$geometry` operator to hit the `2dsphere` index
  - bbox queries that use index are ~30x faster

- Postgres
  - use PostGIS to add geometry columns
  - use a GiST index on the geometry column
  - perform bbox queries with `&& ST_MakeEnvelope(…)`
  - bbox queries that use index are ~40x faster


## Running the benchmarks

### Prerequisites

#### PostgreSQL

You will need a working installation of PostgreSQL with the PostGIS spatial extensions:

```sh
# For example...

# Install PostgreSQL and PostGIS
brew install postgresql postgis
# then, follow post-install instructions

# create the database
createdb mudf_benchmark
```
