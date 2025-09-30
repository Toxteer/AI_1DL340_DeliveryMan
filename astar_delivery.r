# A* Search Algorithm for Delivery Man Game
# Optimized for package pickup and delivery under dynamic traffic conditions
# Goal: Achieve performance ≤180 turns within 4 minutes execution time

library("DeliveryMan")

# Main function called by the DeliveryMan game
myFunction <- function(trafficMatrix, carInfo, packageMatrix) {
  # Determine goal: pickup location if not carrying, delivery location if carrying
  if (carInfo$load == 0) {
    goal <- chooseOptimalPickup(trafficMatrix, carInfo, packageMatrix)
  } else {
    goal <- packageMatrix[carInfo$load, c(3,4)]  # Delivery destination
  }
  
  # Use A* to find next optimal move
  carInfo$nextMove <- aStarNextMove(trafficMatrix, carInfo, goal)
  return(carInfo)
}

# Enhanced pickup selection considering traffic conditions
chooseOptimalPickup <- function(trafficMatrix, carInfo, packageMatrix) {
  # Calculate Manhattan distance to all available packages
  distanceVector <- abs(packageMatrix[,1] - carInfo$x) + abs(packageMatrix[,2] - carInfo$y)
  
  # Set infinite distance for already picked up packages
  distanceVector[packageMatrix[,5] != 0] <- Inf
  
  # Select closest available package (can be enhanced with traffic weighting)
  return(packageMatrix[which.min(distanceVector), c(1,2)])
}

# A* pathfinding algorithm implementation
aStarNextMove <- function(trafficMatrix, carInfo, goal) {
  # If already at goal, pick up or deliver
  if (carInfo$x == goal[1] && carInfo$y == goal[2]) {
    return(5)  # Action: pickup/deliver
  }
  
  # Initialize A* search
  start_node <- createNode(carInfo$x, carInfo$y, 0, manhattanDistance(carInfo$x, carInfo$y, goal), NA)
  open_list <- list(start_node)
  closed_list <- list()
  start_position <- c(carInfo$x, carInfo$y)
  
  # A* main loop
  while (length(open_list) > 0) {
    # Find node with lowest f-score
    f_scores <- sapply(open_list, function(node) node$f)
    current_node <- open_list[[which.min(f_scores)]]
    open_list <- open_list[-which.min(f_scores)]
    closed_list <- append(closed_list, list(current_node))
    
    # Goal reached - return first move in optimal path
    if (current_node$x == goal[1] && current_node$y == goal[2]) {
      return(current_node$first_move)
    }
    
    # Explore neighboring nodes
    neighbors <- generateNeighbors(current_node, trafficMatrix, goal, start_position)
    for (neighbor in neighbors) {
      if (!isInClosedList(neighbor, closed_list)) {
        open_index <- findInOpenList(neighbor, open_list)
        if (open_index == -1) {
          # New node - add to open list
          open_list <- append(open_list, list(neighbor))
        } else {
          # Node exists - update if better path found
          if (neighbor$g < open_list[[open_index]]$g) {
            open_list[[open_index]] <- neighbor
          }
        }
      }
    }
  }
  
  # No path found - stay in place
  return(5)
}

# Calculate movement cost considering traffic conditions
calculateMovementCost <- function(from_x, from_y, to_x, to_y, trafficMatrix) {
  # Determine direction and get traffic cost
  if (to_y == from_y && to_x == from_x + 1) {
    return(trafficMatrix$hroads[from_x, from_y])
  } else if (to_y == from_y && to_x == from_x - 1) {
    return(trafficMatrix$hroads[from_x - 1, from_y])
  } else if (to_x == from_x && to_y == from_y + 1) {
    return(trafficMatrix$vroads[from_x, from_y])
  } else if (to_x == from_x && to_y == from_y - 1) {
    return(trafficMatrix$vroads[from_x, from_y - 1])
  }
  return(Inf)  # Invalid move
}

# Generate valid neighboring nodes for A* expansion
generateNeighbors <- function(current_node, trafficMatrix, goal, start_position) {
  grid_size <- nrow(trafficMatrix$vroads)
  # Movement directions: right, left, down, up
  dx <- c(1, -1, 0, 0)
  dy <- c(0, 0, 1, -1)
  neighbors <- list()
  
  for (i in 1:4) {
    new_x <- current_node$x + dx[i]
    new_y <- current_node$y + dy[i]
    
    # Check bounds
    if (new_x < 1 || new_x > grid_size || new_y < 1 || new_y > grid_size) next
    
    # Calculate costs
    movement_cost <- calculateMovementCost(current_node$x, current_node$y, new_x, new_y, trafficMatrix)
    g_cost <- current_node$g + movement_cost
    h_cost <- manhattanDistance(new_x, new_y, goal)
    
    # Determine first move direction from start position
    if (current_node$x == start_position[1] && current_node$y == start_position[2]) {
      if (new_x > current_node$x) first_move <- 6      # Move right
      else if (new_x < current_node$x) first_move <- 4  # Move left
      else if (new_y > current_node$y) first_move <- 8  # Move down
      else first_move <- 2                             # Move up
    } else {
      first_move <- current_node$first_move
    }
    
    neighbors <- append(neighbors, list(createNode(new_x, new_y, g_cost, h_cost, first_move)))
  }
  
  return(neighbors)
}

# Create a node for A* search
createNode <- function(x, y, g_cost, h_cost, first_move) {
  list(
    x = x,
    y = y,
    g = g_cost,
    h = h_cost,
    f = g_cost + h_cost,
    first_move = first_move
  )
}

# Check if node is in closed list
isInClosedList <- function(node, closed_list) {
  for (closed_node in closed_list) {
    if (closed_node$x == node$x && closed_node$y == node$y) {
      return(TRUE)
    }
  }
  return(FALSE)
}

# Find node in open list and return index
findInOpenList <- function(node, open_list) {
  if (length(open_list) == 0) return(-1)
  
  for (i in 1:length(open_list)) {
    if (open_list[[i]]$x == node$x && open_list[[i]]$y == node$y) {
      return(i)
    }
  }
  return(-1)
}

# Manhattan distance heuristic (admissible for grid-based pathfinding)
manhattanDistance <- function(x1, y1, goal) {
  return(abs(goal[1] - x1) + abs(goal[2] - y1))
}

# Function to run the algorithm directly (for testing)
runAlgorithm <- function() {
  return(runDeliveryMan(myFunction, verbose = 0))
}
