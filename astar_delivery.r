library("DeliveryMan")

myFunction <- function(trafficMatrix, carInfo, packageMatrix) {
  if (carInfo$load == 0) { # Need to pick up a package
    goal <- choosePickup(trafficMatrix, carInfo, packageMatrix)
  } else { # Need to deliver a package
    goal <- packageMatrix[carInfo$load, c(3,4)]
  }
  carInfo$nextMove <- aStarNextMove(trafficMatrix, carInfo, goal) # Move
  return(carInfo) 
}

choosePickup <- function(trafficMatrix, carInfo, packageMatrix) { # Choose the nearest available package
  distanceVector <- abs(packageMatrix[,1] - carInfo$x) + abs(packageMatrix[,2] - carInfo$y)
  distanceVector[packageMatrix[,5] != 0] <- Inf
  return(packageMatrix[which.min(distanceVector), c(1,2)])
}

aStarNextMove <- function(trafficMatrix, carInfo, goal) { # A* algorithm to find the next move
  if (carInfo$x == goal[1] && carInfo$y == goal[2]) {
    return(5) # Already at the goal
  }
  
  start_node <- makeNode(carInfo$x, carInfo$y, 0, heuristic(carInfo$x, carInfo$y, goal), NA)
  open_list <- list(start_node)
  closed_list <- list()
  start_xy <- c(carInfo$x, carInfo$y)
  
  while (length(open_list) > 0) {
    f_values <- sapply(open_list, function(node) node$f)
    current_node <- open_list[[which.min(f_values)]]
    open_list <- open_list[-which.min(f_values)]
    closed_list <- append(closed_list, list(current_node))
    
    if (current_node$x == goal[1] && current_node$y == goal[2]) {
      return(current_node$first_move)
    }
    
    # Expand neighbors,
    neighbors <- getNeighbors(current_node, trafficMatrix, goal, start_xy)
    for (child in neighbors) {
      if (!findInList(child, closed_list)) { # Not in closed list
        open_index <- findInList(child, open_list, return_index = TRUE)
        if (open_index == -1) { # Not in open list
          open_list <- append(open_list, list(child))
        } else { # Already in open list, check if this path is better
          if (child$g < open_list[[open_index]]$g) {
            open_list[[open_index]] <- child
          }
        }
      }
    }
  }
  return(5)
}

moveCost <- function(from_x, from_y, to_x, to_y, roads) { # Get the cost of moving from one cell to another
  if (to_y == from_y && to_x == from_x + 1) return(roads$hroads[from_x, from_y])
  if (to_y == from_y && to_x == from_x - 1) return(roads$hroads[from_x - 1, from_y])
  if (to_x == from_x && to_y == from_y + 1) return(roads$vroads[from_x, from_y])
  if (to_x == from_x && to_y == from_y - 1) return(roads$vroads[from_x, from_y - 1])
  return(Inf)
}

getNeighbors <- function(current, traffic, goal_xy, start_xy) { # Get valid neighboring nodes
  grid_size <- nrow(traffic$vroads) # square grid
  step_dx <- c(1, -1, 0, 0) # right, left, down, up
  step_dy <- c(0, 0, 1, -1) # right, left, down, up
  neighbors <- list()
  
  for (i in 1:4) { # Explore all 4 directions
    next_x <- current$x + step_dx[i]
    next_y <- current$y + step_dy[i]
    
    if (next_x < 1 || next_x > grid_size || next_y < 1 || next_y > grid_size) next # Boundary check
    
    step_time <- moveCost(current$x, current$y, next_x, next_y, traffic) # Cost of moving to the neighbor
    g_new <- current$g + step_time  # New cost from start to neighbor
    h_new <- heuristic(next_x, next_y, goal_xy) # Heuristic cost from neighbor to goal
    
    # If this is the first move, record it, otherwise inherit from current
    if (current$x == start_xy[1] && current$y == start_xy[2]) { 
      if (next_x > current$x) first_move <- 6 
      else if (next_x < current$x) first_move <- 4
      else if (next_y > current$y) first_move <- 8
      else first_move <- 2
    } else {
      first_move <- current$first_move
    }
    
    neighbors <- append(neighbors, list(makeNode(next_x, next_y, g_new, h_new, first_move))) 
  }
  return(neighbors)
}

makeNode <- function(x, y, g, h, first_move) { 
  list(x = x, y = y, g = g, h = h, f = g + h, first_move = first_move)
}

findInList <- function(node, node_list, return_index = FALSE) {
  if (length(node_list) == 0) {
    return(if (return_index) -1 else FALSE) 
  }
  
  for (i in 1:length(node_list)) { 
    if (node_list[[i]]$x == node$x && node_list[[i]]$y == node$y) {
      return(if (return_index) i else TRUE)
    }
  }
  return(if (return_index) -1 else FALSE)
}

heuristic <- function(x, y, goal) {
  return(abs(goal[1] - x) + abs(goal[2] - y))
}

runDeliveryMan(myFunction)

