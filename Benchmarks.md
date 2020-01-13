# Benchmarks
All dataset used in benchmark are located in FcaKit/datasets. Benchmarks were performed on MacBook Pro 2018 with Touchbar, CPU Intel Core i7 Quad core 2.7 GHz, 16 GB RAM. Each algortihm was run 100 times on the same dataset and final execution time is average of each execution.

### Mushrooms Dataset
Size: 8124 x 119, 221525 concepts

| Algorithm    | Time  |
|:-------------|:------------:|
|Next Closure | 18.304s |
|Close by One | 15.311s |
|Fast Close by One | 5.393s |
|Parallel Close by One | 10.286s |
|Parallel Fast Close by One | 3.428s |
|In-Close2 | 4.873s |
|In-Close4 | 3.554s |

### Cloud Dataset
Size: 108 x 56, 1030 concepts

| Algorithm    | Time  |
|:-------------|:------------:|
|Next Closure | 0.037s |
|Upper Neighbor | 0.157s |
|Closed by One | 0.033s |
|Fast Close by One | 0.030s |
|Parallel Closed by One | 0.097s |
|Parallel Fast Closed by One | 0.047s |
|ELL | 0.174s |
|In-Close2 | 0.015s |
|In-Close4 | 0.007s |


### Wine Dataset
Size: 130 x 132, 5524 concepts

| Algorithm    | Time  |
|:-------------|:------------:|
|Next Closure | 0.439s |
|Upper Neighbor | 1.306s |
|Close by One | 0.498s |
|Fast Close by One | 0.301s |
|Parallel Close by One | 0.751s |
|Parallel Fast Close by One | 0.372s |
|ELL | 1.069s |
|In-Close2 | 0.159s |
|In-Close4 | 0.072s |


### Panther Dataset
Size: 30x130, 1471 concepts

| Algorithm    | Time  |
|:-------------|:------------:|
|Next Closure | 0.123s |
|Upper Neighbor | 0.083s |
|Closed by One | 0.171s |
|Fast Close by One | 0.069s |
|Parallel Close by One | 0.226s |
|Parallel Fast Close by One | 0.103s |
|ELL | 0.066s |
|In-Close2 | 0.044s |
|In-Close4 | 0.026s |
