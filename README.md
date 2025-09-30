# A* Search Algorithm for Delivery Man Game
An  A* pathfinding implementation for the Delivery Man game that efficiently handles package pickups and deliveries under dynamic traffic conditions.

## Performance Goal
- **Target**: ≤180 turns within 4 minutes execution time
- **Algorithm**: A* search with Manhattan distance heuristic

## Files

- `astar_delivery.r` - Main A* algorithm implementation
- `benchmark.r` - Performance testing and validation tool

## Quick Start

### Running the Algorithm
```bash
# Run a single test
Rscript -e "source('astar_delivery.r'); runAlgorithm()"

# Run comprehensive benchmark (10 tests by default)
Rscript benchmark.r
```

### Customizing Benchmark Runs
Edit the `NUM_RUNS` variable in `benchmark.r`:
```r
NUM_RUNS <- 20  # Run 20 tests instead of default 10
```

## Dependencies

- **R Package**: `DeliveryMan`
- **R Version**: Compatible with R 3.6+

