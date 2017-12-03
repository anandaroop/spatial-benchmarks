# Spatial Benchmarks

This will be a testbed for benchmarking basic geospatial queries across a range of data stores.

## Findings

- TLDR
  - 1 second of PostGIS time
  - ≈
  - 7 seconds of Mongo time
  - ≈
  - 6 seconds of Elasticsearch time

- Mongo
  - use a $geoWithin with $geometry to hit the 2dsphere index
  - bbox queries that use index are ~30x faster

## Prerequisites

### PostgreSQL

- Need a working installation of PostgreSQL with the PostGIS spatial extensions:
  ```sh
  # For example...

  # Install PostgreSQL and PostGIS
  brew install postgresql postgis
  # then, follow post-install instructions

  # create the database
  createdb mudf_benchmark
  ```
