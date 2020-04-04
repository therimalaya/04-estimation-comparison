mthds <- c(PCR = "PCR", PLS1 = "PLS1", PLS2 = "PLS2", Xenv = "Xenv", Senv = "Senv")

simulate_n_compute <- function(design, d_idx = 29, nobs = 100, mthd) {
  mthds <- c(PCR = "PCR", PLS1 = "PLS1", PLS2 = "PLS2", Xenv = "Xenv", Senv = "Senv")
  mthd_idx <- grep(mthd, mthds)
  need_pc <- all(mthd %in% c("Xenv", "Senv"), with(design[d_idx,], n < p))
  out <- map(1:50, function(r) {
    dgn_chr  <- formatC(d_idx, digits = 0, width = 2, format = "f", flag = "0")
    mthd_chr <- formatC(mthd_idx, digits = 0, width = 2, format = "f", flag = "0")
    rep_chr  <- formatC(r, digits = 0, width = 2, format = "f", flag = "0")
    seed     <- as.numeric(paste0(dgn_chr, mthd_chr, rep_chr))
    set.seed(seed)
    res <- design %>%
      get_design(d_idx) %>%
      list_modify(n = nobs) %>% 
      simulate()
    # res <- res %>%
    #   coef_errors(mthd, need_pc = need_pc, ncomp = 20, scale = TRUE)
    return(res)
  })
  return(out)
}


source("scripts/00-function.r")
source("scripts/01-setup.r")


## ---- N vs Estimation Error ----
nobs <- round(10^(c(2, 2.5, 3)))
dgn <- 29
simulations <- crossing(mthds, nobs) %>% 
  mutate(err = map2(mthds, nobs, 
                    ~simulate_n_compute(design, d_idx = dgn, nobs = ..2, ..1)))
save(simulations, file = paste0("scripts/robj/simulation-", dgn, "-many-n.rdata"))

min_error <- simulations %>% 
  group_by(mthds, nobs) %>% 
  transmute(est_err = map(err, map_df, "estimation_error", .id = "Replication")) %>% 
  unnest_legacy(est_err) %>% 
  group_by(mthds, nobs, Replication, Response) %>% 
  summarize(Est_Error = min(Est_Error)) %>% 
  mutate(Response = paste0("Y", Response))

plt1 <- ggplot(min_error, aes(nobs, Est_Error, color = mthds)) +
  stat_summary(fun = mean, geom = "line", aes(group = mthds)) +
  stat_summary(fun = mean, geom = "point", aes(group = mthds)) +
  facet_grid(. ~ Response) +
  labs(x = "Number of Observations",
       y = "Minimum Estimation Error\n(Averaged over 50 training sets)",
       title = "Minimum Estimation Error",
       subtitle = "Changes over increased number of observations",
       color = "Methods")
ggsave(plt1, filename = "scripts/robj/plots/n-vs-est-err.pdf", 
       width = 7, height = 4, units = "in")

dgn <- 29
nobs <- 10000
simulations <- mthds %>% 
  map(~simulate_n_compute(design, d_idx = dgn, nobs = nobs, ..1))

save(simulations, file = paste0("scripts/robj/simulation-", dgn, ".rdata"))

est_error <- simulations %>% 
  map_df(~map_df(..1, "estimation_error",  .id = "Replications"),
         .id = "Method")
pred_error <- simulations %>% 
  map_df(~map_df(..1, "prediction_error",  .id = "Replications"),
         .id = "Method")
error_df <- left_join(pred_error, est_error,
                      by = names(pred_error)[-ncol(pred_error)]) %>% 
  as_tibble() %>% 
  rename(Prediction = Pred_Error,
         Estimation = Est_Error) %>% 
  pivot_longer(
    cols = ends_with("tion"),
    names_to = "Error_Type",
    values_to = "Error"
  )

min_error <- error_df %>% 
  filter(Error_Type == "Estimation") %>%
  mutate_at("Response", as_factor) %>% 
  select(-Error_Type) %>% 
  group_by(Method, Response, Tuning_Param) %>% 
  summarize_at("Error", mean) %>% 
  summarize(
    Tuning_Param = Tuning_Param[which.min(Error)],
    Error = min(Error)
  )

plt2 <- ggplot(error_df %>% 
         filter(Error_Type == "Estimation") %>% 
         mutate_at("Response", ~paste0("Y", ..1)), 
       aes(Tuning_Param, log10(Error), color = Response,
           group = Response)) +
  facet_grid(rows = vars(Error_Type), cols = vars(Method),
             scales = 'free_y') +
  stat_summary(fun = mean, geom = "point") +
  stat_summary(fun = mean, geom = "line") +
  geom_text(data = min_error %>% 
              mutate_at("Response", ~paste0("Y", ..1)), 
            aes(x = c(rep(2, 12), rep(8, 8)), y = 1,
                vjust = rep(seq.int(5, by = 2, length.out = 4), 5),
                label = round(Error, 3)),
            family = "mono") +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  theme(legend.position = "bottom",
        plot.subtitle = element_text(family = "mono")) +
  labs(x = "Number of Components",
       y = "Log10(Estimation Error)",
       title = "Log of Estimation Error for different methods",
       subtitle = paste0("n=", nobs, ", design=", dgn))
plot(plt2)
ggsave(plt2, filename = "scripts/robj/plots/large-n-est-error.pdf",
       width = 7, height = 4, units = "in")
