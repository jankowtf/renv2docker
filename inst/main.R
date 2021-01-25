# Enable {renv} -----------------------------------------------------------

source("renv/activate.R")

# Package dependencies ----------------------------------------------------

# library("magrittr")

# Start API server --------------------------------------------------------

counter <- 1
counter_max <- 5

while (counter <= counter_max) {
  message(Sys.time())
  Sys.sleep(10)
  counter <- counter + 1
}
