# Spatial Benchmarks

This repo is a testbed for benchmarking basic geospatial queries across a range of data stores.

It is written in Ruby, and organized as series of Rake tasks.

## Findings

### TLDR

**1 second of PostGIS time ≈ 6 seconds of Elasticsearch time ≈ 7 seconds of Mongo time**

Well, sort of. On my machine, PostGIS and Mongo display steady throughput, while Elasticsearch is more erratic, possibly due to JVM garbage collection.

Between Mongo and Elastic, it seems that Elastic has better _peak_ throughput, but Mongo has better _average_ throughput.

Postgres is still the hands-down winner, nearly an order of magnitude faster.

### Methodology

Perform [a set of 100 bounding box queries](queries.json) that represent a moving window, as might be fetched from a front-end map client, over a swath of the United States extending from New York to Florida.

Repeat this 100 times for each data store.

<img width="500" alt="queries" src="https://user-images.githubusercontent.com/140521/33589926-d6855218-d949-11e7-80bc-3966b85da281.png">

### Dataset

The spatial dataset for this benchmark is the [Museum Universe Data File](https://www.imls.gov/research-evaluation/data-collection/museum-universe-data-file), published by the Institute of Museum and Library Services, a collection of ~33,000 museums and related organizations in the United States.

See it [on a map](https://roop.carto.com/builder/9aed5ede-157a-4e90-9a9d-bf4d8343f301/embed)

### Results

For **N=100**, i.e. 10,000 bounding box queries:

|Data store|Version|Index|Elapsed|Normalized|Throughput|
|---|---|---|---|---|---|
|Postgres / PostGIS|10.1 / 2.4|GiST|2.38 sec|1.0|4,210 queries/sec|
|Elasticsearch|2.4|n/a|14.90 sec|6.27|671 queries/sec|
|MongoDB|3.4|2dsphere|16.77 sec|7.06|596 queries/sec|

Hardware note: This is on my 2014-vintage Mac laptop:
- Macbook Pro
- Intel i7, quad-core, 2.3GHz
- 16 GB RAM

## Running the benchmarks

### Prerequisites

You will need working installations of:
- PostgreSQL with the PostGIS spatial extensions
- MongoDB
- Elasticsearch

With Homebrew this would be something like
```sh
brew install postgresql postgis
brew install mongodb
brew install elasticsearch
# follow post-install instructions

brew services start postgresql
brew services start mongodb
brew services start elasticsearch
```

This project will take care of creating the necessary databases and indexes when you do `rake load`.

You can configure the services and databases in [databases.yml](config/databases.yml).

### Steps

0. Clone this project and install its dependencies

```
$ git clone https://github.com/anandaroop/spatial-benchmarks.git

$ cd spatial-benchmarks

$ bundle install
```

1. Obtain the MUDF csv datafile:

```sh
$ bundle exec rake get_csv
```

2. Load up the data

```sh
$ rake load
```

3. Run the benchmarks

```sh
$ rake benchmark
```

If you run the benchmarks, why not open an issue or PR with the results 😀 ?
