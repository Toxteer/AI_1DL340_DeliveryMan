# A* Search Algorithm for Delivery Man Game

An optimized A* pathfinding implementation for the Delivery Man game that efficiently handles package pickups and deliveries under dynamic traffic conditions.

## Performance Goal
- **Target**: ≤180 turns within 4 minutes execution time
- **Algorithm**: A* search with Manhattan distance heuristic
- **Optimization**: Traffic-aware pathfinding with dynamic goal selection

## Files

- `astar_delivery.r` - Main A* algorithm implementation
- `benchmark.r` - Performance testing and validation tool
- `README.md` - This documentation

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

## Algorithm Features

### Core Components
- **A* Pathfinding**: Optimal path finding with f(n) = g(n) + h(n)
- **Manhattan Distance Heuristic**: Admissible heuristic for grid-based navigation
- **Traffic-Aware Costs**: Dynamic cost calculation based on real-time traffic conditions
- **Strategic Pickup Selection**: Closest available package selection strategy

### Key Optimizations
- **Efficient Node Management**: Optimized open/closed list operations
- **Early Goal Detection**: Immediate return when goal is reached
- **Memory Efficient**: Minimal memory footprint for large search spaces
- **Robust Error Handling**: Graceful handling of edge cases

## Performance Monitoring

The benchmark tool provides comprehensive performance analysis:

### Metrics Tracked
- **Turn Count**: Number of moves to complete all deliveries
- **Execution Time**: Total algorithm runtime
- **Success Rate**: Percentage of successful completions
- **Performance Distribution**: Categorization of results (Excellent/Good/Poor)

### Sample Output
```
A* Delivery Man Algorithm Benchmark
====================================

Target Performance: ≤180 turns within 4 minutes
Running 10 benchmark tests...

Test 1 of 10 ... Turns: 168 (✓ GOOD) | Time: 45.23s (✓ FAST)
Test 2 of 10 ... Turns: 145 (✓ GOOD) | Time: 38.91s (✓ FAST)
...

============================================================
BENCHMARK RESULTS
============================================================
Runs completed: 10/10 (100.0%)

PERFORMANCE ANALYSIS:
Average turns: 156.8 ✓ MEETS GOAL (≤180)
Average time: 42.15 seconds ✓ MEETS GOAL (≤240s)

🎯 OVERALL ASSESSMENT: ALGORITHM MEETS ALL PERFORMANCE TARGETS
```

## Algorithm Details

### A* Implementation
The algorithm uses classic A* search with:
- **g(n)**: Actual cost from start to node n (including traffic delays)
- **h(n)**: Manhattan distance heuristic (admissible and consistent)
- **f(n)**: Total estimated cost f(n) = g(n) + h(n)

### Traffic Integration
- Real-time traffic costs from `trafficMatrix`
- Dynamic route optimization based on current conditions
- Separate handling for horizontal and vertical road segments

### Strategy
1. **No Package**: Select closest available package using Manhattan distance
2. **Carrying Package**: Navigate directly to delivery destination
3. **Path Planning**: Use A* to find optimal route considering traffic
4. **Move Execution**: Return next optimal move (directions 2,4,6,8 or action 5)

## Dependencies

- **R Package**: `DeliveryMan`
- **R Version**: Compatible with R 3.6+

## Installation

```bash
# Install DeliveryMan package (if not already installed)
R -e "install.packages('DeliveryMan')"

# Clone and run
git clone <repository-url>
cd delivery-man-astar
Rscript benchmark.r
```

## Development

### Testing Changes
Always run the benchmark after modifications:
```bash
Rscript benchmark.r
```

### Performance Tuning
- Adjust heuristic weights in `manhattanDistance()`
- Modify pickup selection strategy in `chooseOptimalPickup()`
- Optimize node management in A* main loop

---

**Goal**: Achieve consistent performance ≤180 turns within 4 minutes execution time for optimal delivery operations.
