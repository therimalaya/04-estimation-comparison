library(readr)
library(tidyverse)
library(pls)
library(Renvlp)

source("scripts/00-function.r")

response <- read.csv("data/diesel_prop.csv", skip = 8, na.string = 'NaN', strip.white = TRUE, stringsAsFactors = FALSE) %>%
  as_tibble()
response$Label <- response$X
response <- response[,-c(2, 10)]

predictor <- read.csv("data/diesel_spec.csv", skip = 9, na.strings = 'NaN', strip.white = TRUE, stringsAsFactors = FALSE) %>%
  as_tibble() %>% select(-1, -X.1)
names(predictor)[1] <- "Label"

dta <- na.omit(response) %>%
  left_join(predictor, by = "Label")

dta_ <- data.frame(
  y = I(dta %>% select(BP50:VISC) %>% as.matrix()),
  x = I(dta %>% select(-Label:-VISC) %>% as.matrix())
)

mdl <- plsr(y ~ x, data = dta_, validation = "LOO")
summary(mdl)

y_na_idx <- setdiff(response$Label, na.omit(response)$Label)
new_pred <- data.frame(x = I(predictor %>% filter(Label %in% y_na_idx) %>% select(-Label) %>% as.matrix()))

y_pred <- drop(predict(mdl, newdata = new_pred, ncomp = 4))

response_ <- response
resp_with_na <- response_ %>%
  filter(Label %in% y_na_idx) %>%
  gather(Variable, Value, -Label) %>%
  group_by(Label, Variable)

resp_pred <- cbind(Label = y_na_idx, y_pred) %>%
  as_tibble() %>%
  gather(Variable, Value, -Label) %>%
  group_by(Label, Variable)

resp_without_na <- resp_with_na %>% filter(is.na(Value)) %>%
  select(-Value) %>%
  left_join(resp_pred) %>%
  bind_rows(resp_with_na %>% filter(!is.na(Value))) %>%
  spread(Variable, Value)

plot(prcomp(resp_without_na[, -1], center = TRUE, scale. = TRUE))


new_dta <- na.omit(resp_without_na) %>%
  left_join(predictor, by = "Label") %>%
  ungroup()

new_df <- data.frame(
  y = I(new_dta %>% select(BP50:VISC) %>% as.matrix()),
  x = I(new_dta %>% select(-Label:-VISC) %>% as.matrix())
)

df_with_pc <- get_data(`colnames<-`(new_df, c("Y", "X")), need_pc = TRUE, prop = 0.99, ncomp = 10)

test_idx <- sample(nrow(df_with_pc), 0.2*nrow(df_with_pc))
train_pc_df <- df_with_pc[-test_idx,]
train_df <- new_df[-test_idx,]

test_pc_df <- df_with_pc[test_idx,]
test_df <- new_df[test_idx,]


## Fitting some model:

model <- list()
model$pcr  <- fit_model(train_df, method = "PCR")
model$pls1 <- fit_model(train_df, method = "PLS1")
model$pls2 <- fit_model(train_df, method = "PLS2")
model$xenv <- fit_model(train_pc_df, method = "Xenv")
model$senv <- fit_model(train_pc_df, method = "Senv")


pred <- list()

pred$pcr <- predict(model$pcr, newdata = test_df, ncomp = 1:10) %>% plyr::alply(3)
names(pred$pcr) <- paste0('ncomp', 1:length(pred$pcr))
dnames <- dimnames(pred$pcr[[1]])

pred$pls2 <- predict(model$pls2, newdata = test_df, ncomp = 1:10) %>% plyr::alply(3)
names(pred$pls2) <- paste0('ncomp', 1:length(pred$pls2))

pred$pls1 <- sapply(model$pls1, function(mdl){
    predict(mdl, newdata = test_df, ncomp = 1:10)
}, simplify = 'array')
pred$pls1 <- drop(pred$pls1) %>% plyr::alply(2)
names(pred$pls1) <- paste0('ncomp', 1:length(pred$pls1))
for (x in pred$pls1) dimnames(x) <- dnames

pred$xenv <- lapply(model$xenv, function(m){
    out <- apply(test_pc_df$x, 1, function(xn){
        out <- Renvlp::pred.xenv(m, xn)
        out$value
    })
    t(out)
})
names(pred$xenv) <- paste0("ncomp", 1:length(pred$xenv))
pred$xenv <- lapply(pred$xenv, `dimnames<-`, dnames)

pred$senv <- lapply(model$senv, function(m){
    out <- apply(test_pc_df$x, 1, function(xn){
        out <- Renvlp::pred.stenv(m, xn)
        out$value
    })
    t(out)
})
names(pred$senv) <- paste0("ncomp", 1:length(pred$senv))
pred$senv <- lapply(pred$senv, `dimnames<-`, dnames)


pred_err <- lapply(pred, function(mdl){
    lapply(mdl, function(nc){
        y <- test_df$y
        yhat <- nc
        out <- (t(y-yhat) %*% (y-yhat)) / nrow(y)
        return(out)
    })
})

pred_err_df <- map_df(pred_err, function(mdl){
    map_df(mdl, function(nc) {
        out <- as.data.frame(diag(nc))
        names(out) <- "Pred_Error"
        out <- rownames_to_column(out, var = "Response")
    }, .id = "ncomp")
}, .id = "Model") %>% as_tibble() %>%
    mutate(ncomp = factor(ncomp, paste0("ncomp", 1:10)))

ggplot(pred_err_df, aes(ncomp, Pred_Error, color = Model)) +
    geom_line(aes(group = Model)) +
    geom_point() +
    facet_grid(Response~., scales = 'free') +
    theme(legend.position = "bottom") +
    labs(x = NULL, y = "Prediction Error")


