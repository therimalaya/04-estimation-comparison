plot_data_transform <- function() {
  library(grid)
  
  grid.newpage()
  fctr_rect <- rectGrob(x = 0.1, y = 0.5, height = 0.8, width = 0.15)
  fctr_label <- textGrob(x = 0.1, y = 0.5, label = "Factors")
  fctr_grob <- gList(fctr_rect, fctr_label)
  
  n_rect <- function(start = 0.2, step = 0.025, n = 4, label = paste0("Y", 1:n)) {
    seq_ <- seq(start, by = step, length.out = n)
    out <- lapply(seq_along(seq_), function(x){
      rect <- rectGrob(x = seq_[x], y = 0.5, height = 0.8, width = step)
      txt <- textGrob(x = seq_[x], y = 0.5 + 0.25, 
                      label = label[x], hjust = 1.15,
                      rot = 90,
                      gp = gpar(fontsize = 10))
      gList(rect, txt)
    })
    do.call(gList, out)
  }
  pred_grob <- n_rect(0.2, 0.035, 4, label = paste0("PE", 1:4))
  pc_grob <- n_rect(0.4, 0.035, 4, label = paste0("PC", 1:4))
  dta_grob <- gList(fctr_grob, pred_grob, pc_grob)
  
  plt_dta <- data.frame(x = rnorm(1000))
  plt <- ggplot(plt_dta, aes(x)) + 
    geom_histogram(bins = 30, color = "grey", 
                   aes(y = ..density..), fill = NA) +
    stat_density(geom = "line") +
    labs(x = "PC1", y = "Density")
  plt_grob <- ggplotGrob(plt)
  
  arr1_grob <- linesGrob(c(0.33, 0.375), y = c(0.5, 0.5), gp = gpar(lwd = 2),
                         arrow = arrow(length = unit(2, "mm")))
  arr2 <- xsplineGrob(x = c(0.4, 0.475, 0.6, 0.7), 
                      y = c(0.85, 0.8, 1, 0.85),
                      shape = 0.75, gp = gpar(lwd = 2),
                      arrow = arrow(length = unit(2, 'mm')))
  arr2_dot <- circleGrob(0.4, y = 0.85, r = 0.01, gp = gpar(fill = "black"))
  arr2_grob <- gList(arr2, arr2_dot)
  
  vp1 <- viewport(x = 0, y = 0.5, height = 0.8, width = 0.6, just = "left")
  pushViewport(vp1)
  grid.newpage()
  grid.draw(dta_grob)
  
  vp2 <- viewport(x = 0.6, y = 0.5, height = 0.8, width = 0.4, just = "left")
  pushViewport(vp2)
  grid.draw(plt_grob)
  
  upViewport()
  grid.draw(arr1)
  grid.draw(arr2_grob)
}