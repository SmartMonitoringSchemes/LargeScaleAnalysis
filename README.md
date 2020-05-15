# LargeScaleAnalysis
Analysis of RIPE Atlas, CAIDA Manic and Orange WebView measurements.

```bash
fetchmesh fetch --af 4 --type ping --start-date 2020-02-01 --stop-date 2020-02-08 --load-pairs mesh_half_noself_001.pairs --jobs 4
fetchmesh fetch --af 4 --type traceroute --start-date 2020-02-01 --stop-date 2020-02-08 --load-pairs mesh_half_noself_001.pairs --jobs 4
fetchmesh unpack --af 4 --type ping ping_v4_1580511600_1581116400/
```
