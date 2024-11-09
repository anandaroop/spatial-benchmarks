# Spatial Benchmarks

This repo is a testbed for benchmarking basic geospatial queries across a range of data stores.

It is written in Ruby, and organized as series of Rake tasks.

## Findings

### TLDR

**1 second of PostGIS time ≈ 1.7 seconds of Elasticsearch time ≈ 1.5 seconds of Mongo time**

### Methodology

Perform [a set of 100 bounding box queries](queries.json) that represent a moving window, as might be fetched from a front-end map client, over a swath of the United States extending from New York to Florida.

Repeat this N times for each data store.

<img width="500" alt="queries" src="https://user-images.githubusercontent.com/140521/33589926-d6855218-d949-11e7-80bc-3966b85da281.png">

### Dataset

The spatial dataset for this benchmark is the [Museum Universe Data File](https://www.imls.gov/research-evaluation/data-collection/museum-universe-data-file), published in 2018 by the Institute of Museum and Library Services, a collection of ~30,000 museums and related organizations in the United States.

### Results

For **N=10**, i.e. 1000 bounding box queries, here are the results, based on wall-clock time:

| Data store         | Version    | Index    | Elapsed (real) | Normalized | Throughput       |
| ------------------ | ---------- | -------- | -------------- | ---------- | ---------------- |
| Elasticsearch      | 8.12       | n/a      | 1.74 sec       | 1.0        | 574 queries/sec  |
| Postgres / PostGIS | 15.4 / 3.3 | GiST     | 6.71 sec       | 3.85       | 149 queries/sec  |
| MongoDB            | 7.0        | 2dsphere | 65.79 sec      | 37.8       | 15.2 queries/sec |

Hardware note: This is on a 2023-vintage Mac laptop:

- MacBook Pro
- Apple M2 Pro, 12-core, 3.49GHz
- 32 GB RAM

## Running the benchmarks

### Prerequisites

You will need a working Docker installation.

This project includes a `docker-compose` configuration that will bring up services for:

- PostgreSQL with the PostGIS spatial extensions
- MongoDB
- Elasticsearch

### Steps

0. Clone this project and install its dependencies

```sh
git clone https://github.com/anandaroop/spatial-benchmarks.git

cd spatial-benchmarks
```

```sh
asdf install
```

```sh
bundle install
```

1. Obtain the MUDF csv datafile

```sh
bundle exec rake get_csv
```

2. Start the servers

```sh
docker-compose up
```

3. Create the spatial database and indexes, and load up the data

```sh
rake load
```

4. Run the benchmarks

```sh
rake benchmark
```
