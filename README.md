# Spatial Benchmarks

A testbed for benchmarking basic geospatial queries across a range of data stores.

## Findings

### TLDR

1 second of PostGIS time ≈ 6 seconds of Elasticsearch time ≈ 7 seconds of Mongo time

### Methodology

Perform [a set of 100 bounding box queries](queries.json) that represent a moving window, as might be fetched from a front-end map client, over a swath of the United States extending from New York to Florida.

Repeat this 100 times for each data store.

<img width="500" alt="queries" src="https://user-images.githubusercontent.com/140521/33589926-d6855218-d949-11e7-80bc-3966b85da281.png">

### Dataset

The spatial dataset for this benchmark is the [Museum Universe Data File](https://www.imls.gov/research-evaluation/data-collection/museum-universe-data-file), publised by the Institute of Museum and Library Services, a collection of ~33,000 museums and related organizations in the United States.

### Results

#### N=100

|Data store|Version|Index|Elapsed|Normalized|Throughput|
|---|---|---|---|---|---|
|Postgres / PostGIS|10.1 / 2.4|GiST|2.38 sec|1.0|4,210 queries/sec|
|Elasticsearch|2.4|n/a|14.90 sec|6.27|671 queries/sec|
|MongoDB|3.4|2dsphere|16.77 sec|7.06|596 queries/sec|

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
