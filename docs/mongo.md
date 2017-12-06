### Misc notes

- use a `2dsphere` index on the geometry field
- use a `$geoWithin` query with the `$geometry` operator to hit the `2dsphere` index
- bbox queries that use index are ~30x faster
