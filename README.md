# LargeScaleAnalysis
Analysis of RIPE Atlas, CAIDA Manic and Orange WebView measurements.

```bash
fetchmesh fetch --af 4 --type ping --start-date 2020-02-01 --stop-date 2020-02-08 --dry-run --sample-pairs 0.01 --half --no-self --save-pairs mesh_half_noself_001.pairs --jobs 4
fetchmesh fetch --af 4 --type ping --start-date 2020-02-01 --stop-date 2020-02-08 --dry-run --only-self --save-pairs mesh_self.pairs --jobs 4

fetchmesh fetch --af 4 --type ping --start-date 2020-02-01 --stop-date 2020-02-08 --load-pairs mesh_half_noself_001.pairs --jobs 4 --dir ping_v4_1580511600_1581116400_noself
fetchmesh fetch --af 4 --type traceroute --start-date 2020-02-01 --stop-date 2020-02-08 --load-pairs mesh_half_noself_001.pairs --jobs 4 --dir ping_v4_1580511600_1581116400_self
fetchmesh unpack --af 4 --type ping ping_v4_1580511600_1581116400_noself ping_v4_1580511600_1581116400_noself_pairs
fetchmesh unpack --af 4 --type ping ping_v4_1580511600_1581116400_self ping_v4_1580511600_1581116400_self_pairs
```
