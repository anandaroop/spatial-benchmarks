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

| Data store         | Version    | Index    | Elapsed (real) | Normalized | Throughput      |
| ------------------ | ---------- | -------- | -------------- | ---------- | --------------- |
| Elasticsearch      | 8.12       | n/a      | 1.92 sec       | 1.0        | 521 queries/sec |
| Postgres / PostGIS | 15.4 / 3.3 | GiST     | 7.05 sec       | 3.67       | 142 queries/sec |
| MongoDB            | 7.0        | 2dsphere | 128.66 sec     | 67.0       | 8 queries/sec   |

<!--
# elastic

#<Benchmark::Tms:0x000000011e697d68 @label="", @real=1.9180430000124034, @cstime=0.0, @cutime=0.0, @stime=0.189089, @utime=0.471092, @total=0.660181>
Queries: 1000, Hits: 19290, QPS: 521.3647452082844

# postgres

#<Benchmark::Tms:0x00000001261f7e40 @label="", @real=7.0500020000035875, @cstime=0.0, @cutime=0.0, @stime=0.05959500000000001, @utime=0.248973, @total=0.308568>
Queries: 1000, Hits: 19290, QPS: 141.84393139172033

# mongo

#<Benchmark::Tms:0x000000012029b0f0 @label="", @real=128.65957600000547, @cstime=0.0, @cutime=0.0, @stime=0.352108, @utime=4.187479, @total=4.539587>
Queries: 1000, Hits: 19290, QPS: 7.772449055793231
-->

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
