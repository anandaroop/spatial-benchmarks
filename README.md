# Spatial Benchmarks

This will be a testbed for benchmarking basic geospatial queries across a range of data stores.

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
