library("DeliveryMan")

myFunction <- function(trafficMatrix, carInfo, packageMatrix) {
  if (carInfo$load == 0) { # Need to pick up a package
    goal <- choosePickup(trafficMatrix, carInfo, packageMatrix)
  } else { # Need to deliver a package
    goal <- packageMatrix[carInfo$load, c(3,4)]
  }
  carInfo$nextMove <- aStarNextMove(trafficMatrix, carInfo, goal)
  return(carInfo)
}

choosePickup <- function(trafficMatrix, carInfo, packageMatrix) {
  distanceVector <- abs(packageMatrix[,1] - carInfo$x) + abs(packageMatrix[,2] - carInfo$y)
  distanceVector[packageMatrix[,5] != 0] <- Inf
  return(packageMatrix[which.min(distanceVector), c(1,2)])
}

aStarNextMove <- function(trafficMatrix, carInfo, goal) {
  if (carInfo$x == goal[1] && carInfo$y == goal[2]) {
    return(5)
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
    
    neighbors <- getNeighbors(current_node, trafficMatrix, goal, start_xy)
    for (child in neighbors) {
      if (!inClosed(child, closed_list)) {
        open_index <- findInOpen(child, open_list)
        if (open_index == -1) {
          open_list <- append(open_list, list(child))
        } else {
          if (child$g < open_list[[open_index]]$g) {
            open_list[[open_index]] <- child
          }
        }
      }
    }
  }
  return(5)
}

moveCost <- function(from_x, from_y, to_x, to_y, roads) {
  if (to_y == from_y && to_x == from_x + 1) return(roads$hroads[from_x, from_y])
  if (to_y == from_y && to_x == from_x - 1) return(roads$hroads[from_x - 1, from_y])
  if (to_x == from_x && to_y == from_y + 1) return(roads$vroads[from_x, from_y])
  if (to_x == from_x && to_y == from_y - 1) return(roads$vroads[from_x, from_y - 1])
  return(Inf)
}

getNeighbors <- function(current, traffic, goal_xy, start_xy) {
  grid_size <- nrow(traffic$vroads)
  step_dx <- c(1, -1, 0, 0)
  step_dy <- c(0, 0, 1, -1)
  neighbors <- list()
  
  for (i in 1:4) {
    next_x <- current$x + step_dx[i]
    next_y <- current$y + step_dy[i]
    
    if (next_x < 1 || next_x > grid_size || next_y < 1 || next_y > grid_size) next
    
    step_time <- moveCost(current$x, current$y, next_x, next_y, traffic)
    g_new <- current$g + step_time
    h_new <- heuristic(next_x, next_y, goal_xy)
    
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

inClosed <- function(node, closed_list) {
  for (closed_node in closed_list) {
    if (closed_node$x == node$x && closed_node$y == node$y) return(TRUE)
  }
  return(FALSE)
}

findInOpen <- function(node, open_list) {
  if (length(open_list) == 0) return(-1)
  for (i in 1:length(open_list)) {
    if (open_list[[i]]$x == node$x && open_list[[i]]$y == node$y) return(i)
  }
  return(-1)
}

heuristic <- function(x, y, goal) {
  return(abs(goal[1] - x) + abs(goal[2] - y))
}

runDeliveryMan(myFunction)

