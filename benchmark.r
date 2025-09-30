# A* Delivery Man Algorithm Benchmark
# Goal: Validate performance ≤180 turns within 4 minutes execution time

library("DeliveryMan")
source("astar_delivery.r") 

NUM_RUNS <- 10  # Change this value to adjust number of benchmark runs

cat("A* Delivery Man Algorithm Benchmark\n")
cat("====================================\n\n")
cat("Target Performance: ≤180 turns within 4 minutes\n")
cat("Running", NUM_RUNS, "benchmark tests...\n\n")

# Function to run a single test
runSingleBenchmark <- function() {
  start_time <- Sys.time()
  
  # Run the algorithm and capture results
  turns <- runDeliveryMan(myFunction, verbose = 0)
  
  end_time <- Sys.time()
  execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  return(list(
    turns = turns,
    execution_time = execution_time,
    success = !is.na(turns) && turns > 0
  ))
}

# Main benchmark function
runBenchmark <- function(num_runs = NUM_RUNS) {
  # Initialize result vectors
  valid_turns <- c()
  valid_times <- c()
  successful_runs <- 0
  
  # Run benchmark tests
  for (i in 1:num_runs) {
    cat("Test", i, "of", num_runs, "... ")
    
    tryCatch({
      result <- runSingleBenchmark()
      
      if (result$success) {
        valid_turns <- c(valid_turns, result$turns)
        valid_times <- c(valid_times, result$execution_time)
        successful_runs <- successful_runs + 1
        
        # Performance indicator
        performance_status <- if (result$turns <= 180) "✓ GOOD" else "⚠ HIGH"
        time_status <- if (result$execution_time <= 240) "✓ FAST" else "⚠ SLOW"
        
        cat("Turns:", result$turns, paste0("(", performance_status, ")"),
            "| Time:", round(result$execution_time, 2), "s", paste0("(", time_status, ")\n"))
      } else {
        cat("FAILED\n")
      }
    }, error = function(e) {
      cat("ERROR:", e$message, "\n")
    })
  }
  
  # Calculate and display statistics
  if (length(valid_turns) > 0) {
    displayResults(valid_turns, valid_times, num_runs, successful_runs)
  } else {
    cat("\n❌ No successful runs completed!\n")
  }
}

# Display comprehensive benchmark results
displayResults <- function(turns, times, total_runs, successful_runs) {
  cat("\n", paste(rep("=", 60), collapse = ""), "\n")
  cat("BENCHMARK RESULTS\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  # Success rate
  success_rate <- (successful_runs / total_runs) * 100
  cat("Runs completed:", successful_runs, "/", total_runs, 
      paste0("(", round(success_rate, 1), "%)\n\n"))
  
  # Performance analysis
  avg_turns <- mean(turns)
  avg_time <- mean(times)
  performance_goal_met <- avg_turns <= 180
  time_goal_met <- avg_time <= 240
  
  cat("PERFORMANCE ANALYSIS:\n")
  cat("Average turns:", round(avg_turns, 1))
  if (performance_goal_met) {
    cat(" ✓ MEETS GOAL (≤180)\n")
  } else {
    cat(" ❌ EXCEEDS GOAL (>180)\n")
  }
  
  cat("Average time:", round(avg_time, 2), "seconds")
  if (time_goal_met) {
    cat(" ✓ MEETS GOAL (≤240s)\n\n")
  } else {
    cat(" ❌ EXCEEDS GOAL (>240s)\n\n")
  }
  
  # Detailed statistics
  cat("DETAILED STATISTICS:\n")
  cat("Turns  - Min:", min(turns), "| Max:", max(turns), 
      "| Median:", median(turns), "| SD:", round(sd(turns), 1), "\n")
  cat("Time   - Min:", round(min(times), 2), "s | Max:", round(max(times), 2), 
      "s | Median:", round(median(times), 2), "s | SD:", round(sd(times), 2), "s\n\n")
  
  # Performance distribution
  excellent_runs <- sum(turns <= 150)
  good_runs <- sum(turns > 150 & turns <= 180)
  poor_runs <- sum(turns > 180)
  
  cat("PERFORMANCE DISTRIBUTION:\n")
  cat("Excellent (≤150 turns):", excellent_runs, paste0("(", round(excellent_runs/length(turns)*100, 1), "%)\n"))
  cat("Good (151-180 turns)   :", good_runs, paste0("(", round(good_runs/length(turns)*100, 1), "%)\n"))
  cat("Poor (>180 turns)      :", poor_runs, paste0("(", round(poor_runs/length(turns)*100, 1), "%)\n\n"))
  
  # Overall assessment
  if (performance_goal_met && time_goal_met) {
    cat("🎯 OVERALL ASSESSMENT: ALGORITHM MEETS ALL PERFORMANCE TARGETS\n")
  } else if (performance_goal_met) {
    cat("⚠️  OVERALL ASSESSMENT: GOOD TURN PERFORMANCE, BUT SLOW EXECUTION\n")
  } else if (time_goal_met) {
    cat("⚠️  OVERALL ASSESSMENT: FAST EXECUTION, BUT HIGH TURN COUNT\n")
  } else {
    cat("❌ OVERALL ASSESSMENT: ALGORITHM NEEDS OPTIMIZATION\n")
  }
}

# Run the benchmark
runBenchmark()
