formats <- commandArgs(trailingOnly = TRUE)
wd <- getwd()
setwd(wd)
library(crayon)
if (length(formats) == 0) formats <- names(yaml::read_yaml("_output.yml"))
if (file.exists("Estimation-Paper.Rmd")) {
  file.remove("Estimation-Paper.Rmd")
}
time_keeper <- sapply(formats, function(frmt) {
  cat(blue("Working with"), green(frmt), blue("output.\n"))
  time_taken <- system.time({
    suppressWarnings({
      bookdown::render_book(".", frmt, preview = FALSE, quiet = TRUE)
    })
  })
  return(time_taken[3])
})
cat(green("Rendering has successfully finished."))
cat(crayon::bold(crayon::green("\nSummary:")))
time_taken <- tibble::tibble(
  format = formats,
  time_taken = time_keeper
)
print(knitr::kable(time_taken, format = "markdown"))

