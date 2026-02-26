# run.R
# this script fits all models and creates all figures
# outputs are saved to "artifacts" folder

suppressPackageStartupMessages({
  library(here)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(tibble)
  library(purrr)
  library(stringr)
  library(ggplot2)
  
  library(brms)
  library(cmdstanr)
  library(posterior)
  library(bayesplot)
  library(loo)
  
  library(ggrepel)
  library(priorsense)
  library(patchwork)
})

here::i_am("run.R")   

source(here("functions.R"))

seed <- 123
set.seed(seed)

dir.create(here("artifacts"), showWarnings = FALSE)

# set up data -------------------------------------------------------------
data <- read.csv(here("data.csv")) %>% 
  as_tibble() %>% 
  mutate(treatment = case_when(
    treatment == 1 ~ "thrombectomy",
    treatment == 0 ~ "medical"))

data$treatment <- factor(data$treatment)
data$trial <- factor(data$trial)

data_long <- data %>%
  pivot_longer(
    cols = -c(trial, year, treatment),
    names_to = "mrs_word",
    values_to = "count"
  ) %>%
  mutate(
    treatment = case_when(
      treatment %in% c(1, "1", "thrombectomy", "Thrombectomy") ~ "thrombectomy",
      treatment %in% c(0, "0", "medical", "Medical") ~ "medical",
      TRUE ~ NA_character_
    ),
    treatment = factor(treatment, levels = c("medical","thrombectomy")),
    trial = factor(trial)
  )

lvl_words <- c("zero","one","two","three","four","five","six")
lvl_nums  <- as.character(0:6)

data_long <- data_long %>%
  mutate(
    mrs = factor(lvl_nums[match(mrs_word, lvl_words)],
                 levels = lvl_nums, ordered = TRUE),
    mrs_better = factor(mrs, levels = rev(levels(mrs)), ordered = TRUE)
  )

data_long <- data_long %>%
  mutate(good = as.integer(as.character(mrs)) <= 2)

data_long %>% count(treatment, .drop = FALSE)
data_long %>% count(trial, .drop = FALSE)

nlevels(data_long$treatment)
nlevels(data_long$trial)

sum(is.na(data_long$treatment))
sum(is.na(data_long$trial))
sum(is.na(data_long$mrs_better))
sum(is.na(data_long$count))


saveRDS(data_long, here("artifacts/data_long.rds"))

# fit main ordinal model to data -------------------------------------------------------
formula <- ordinal_value ~ treatment + (1 + treatment | trial)

priors <- c(prior(normal(0, 1), class = "b"),
            prior(normal(0, 1), class = "sd"),
            prior(normal(0, 1), class = "Intercept"))

fit_ordinal <- brm(
  mrs_better | weights(count) ~ treatment + (1 + treatment | trial),
  data = data_long %>% filter(count > 0),
  family = cumulative(link = "logit"),
  prior = priors,
  backend = "cmdstanr",
  chains = 4, cores = 4,
  seed = seed,
  save_pars = save_pars(all = TRUE)
)

# fit model with unequal variances to data -------------------------------------
fit_uv <- brm(
  formula =
    bf(mrs_better | weights(count) ~ treatment + (1 + treatment | trial)) +
    lf(disc ~ 0 + treatment, cmc = FALSE),
  prior = priors,
  sample_prior = TRUE,
  data = data_long,
  family = cumulative(link = "logit"),
  chains = 4,
  cores = 4,
  threads = threading(4),
  backend = "cmdstanr",
  seed = seed,
  save_pars = save_pars(all = TRUE)
)

# fit adjacent category model (drops proportional odds assumption) -------------
fit_adjacent <- brm(
  mrs_better | weights(count) ~ treatment + (1 + treatment | trial),
  data = data_long %>% filter(count > 0),
  family = acat(link = "logit"),
  prior = priors,
  backend = "cmdstanr",
  chains = 4, cores = 4,
  seed = seed,
  save_pars = save_pars(all = TRUE)
)

# fit binary model to data -----------------------------------------------------
data_bin <- data_long %>%
  group_by(trial, year, treatment) %>%
  summarise(
    good_n  = sum(count[as.integer(as.character(mrs)) <= 2]),
    total_n = sum(count),
    .groups = "drop"
  )

fit_bin <- brm(
  good_n | trials(total_n) ~ treatment + (1 + treatment | trial),
  data = data_bin,
  family = binomial(link = "logit"),
  prior = priors,
  backend = "cmdstanr",
  chains = 4, cores = 4,
  seed = seed
)

# save fits --------------------------------------------------------------------
saveRDS(fit_ordinal, here("artifacts/fit_ordinal.rds"))
saveRDS(fit_uv, here("artifacts/fit_uv.rds"))
saveRDS(fit_adjacent, here("artifacts/fit_adjacent.rds"))
saveRDS(fit_bin, here("artifacts/fit_bin.rds"))

# get key estimates from model fits --------------------------------------------
fits <- list(
  ordinal_equal_var   = fit_ordinal,
  ordinal_unequal_var = fit_uv,
  ordinal_adjacent = fit_adjacent,
  binary_good_outcome = fit_bin
)

draws <- purrr::imap_dfr(fits, extract_key_param_draws)

# add posterior predictive treatment effect
draws <- draws %>%
  mutate(
    z1 = rnorm(n()),
    z2 = rnorm(n()),
    u_int_new   = sd_int * z1,
    u_slope_new = sd_trt * (cor_int_trt * z1 + sqrt(pmax(0, 1 - cor_int_trt^2)) * z2),
    logOR_pred_new_trial = b_logOR + u_slope_new
  ) %>%
  select(-z1, -z2, -u_int_new, -u_slope_new)



# save draws -----------------------------------------------------------
saveRDS(draws, here("artifacts/draws.rds"))

# convergence diagnostics for main model --------------------------------

# trace plots
p1 <- mcmc_trace(fit_ordinal, 
           pars = c("b_Intercept[1]", "b_Intercept[2]", "b_Intercept[3]", 
                    "b_Intercept[4]", "b_Intercept[5]", "b_Intercept[6]"),
           facet_args = list(nrow = 3, ncol = 2)) +
  ggtitle("Ordinal Thresholds")

p2 <- mcmc_trace(fit_ordinal, 
           pars = "b_treatmentthrombectomy") +
  ggtitle("Treatment Effect")

p3 <- mcmc_trace(fit_ordinal, 
           pars = c("sd_trial__Intercept", 
                    "sd_trial__treatmentthrombectomy",
                    "cor_trial__Intercept__treatmentthrombectomy"),
           facet_args = list(nrow = 3, ncol = 1)) +
  ggtitle("Hyperparameters")


ordinal_trace_plots <- p1 + (p2 / p3)

ggsave(
  filename = here::here("artifacts", "ordinal_trace_plots.pdf"),
  plot = ordinal_trace_plots,
  device = pdf,  
  width = 8.5,          
  height = 11.0,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "ordinal_trace_plots.svg"),
  plot = ordinal_trace_plots,
  width = 8.5,          
  height = 11.0,          
  units = "in",
  dpi = 300
)

# rhat values
p1 <- mcmc_rhat(brms::rhat(fit_ordinal)) +
  ggtitle("Ordinal model: r-hat values")

# effective sample size
p2 <- mcmc_neff(neff_ratio(fit_ordinal), size = 2) +
  ggtitle("Ordinal model: effective sample sizes")

ordinal_convergence_values <- p1 + p2

ggsave(
  filename = here::here("artifacts", "ordinal_convergence_values.pdf"),
  plot = ordinal_convergence_values,
  device = pdf,  
  width = 7.5,          
  height = 5.0,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "ordinal_convergence_values.svg"),
  plot = ordinal_convergence_values,
  width = 7.5,          
  height = 5.0,          
  units = "in",
  dpi = 300
)

# posterior predictive check for main model ------------------------------------
data_ppc <- data_long %>%
  filter(count > 0) %>%
  tidyr::uncount(count) %>%
  mutate(count = 1)

p1 <- pp_check(
  fit_ordinal,
  type = "bars_grouped",
  group = "treatment",
  ndraws = 500,
  newdata = data_ppc
) +
  ggtitle("Ordinal model: posterior predictive check") +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  guides(fill = "none", color = "none")

ggsave(
  filename = here::here("artifacts", "ordinal_posterior_predictive_check.pdf"),
  plot = p1,
  device = pdf,  
  width = 7.5,          
  height = 5.0,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "ordinal_posterior_predictive_check.svg"),
  plot = p1,
  width = 7.5,          
  height = 5.0,          
  units = "in",
  dpi = 300
)



# power scaling sensitivity assessment for main model --------------------------------------
p1 <- priorsense::powerscale_plot_dens(fit_ordinal, 
                                 variable = c("b_treatmentthrombectomy",
                                              "sd_trial__Intercept", 
                                              "sd_trial__treatmentthrombectomy",
                                              "cor_trial__Intercept__treatmentthrombectomy"))

p1 <- p1 + theme(
  strip.text.x = element_text(size = 8),
  strip.text.y = element_text(size = 8)
)

ggsave(
  filename = here::here("artifacts", "ordinal_power_scaling_sensitivity.pdf"),
  plot = p1,
  device = pdf,  
  width = 10,          
  height = 5.0,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "ordinal_power_scaling_sensitivity.svg"),
  plot = p1,
  width = 10,          
  height = 5.0,          
  units = "in",
  dpi = 300
)


# figure one -------------------------------------------------------------------

# extract the trial-specific coefficients
trial_coefs <- coef(fit_ordinal, summary = FALSE)$trial[, , "treatmentthrombectomy"] %>%
  posterior_summary() %>%
  as_tibble(rownames = "trial") %>%
  # sort by Estimate value
  arrange(Estimate) %>%
  # convert trial to a factor with levels in the sorted order
  mutate(trial = factor(trial, levels = trial)) 

# extract the population-level coefficient 
pop_coef <- fixef(fit_ordinal) %>%
  as_tibble(rownames = "Parameter") %>%
  filter(Parameter == "treatmentthrombectomy") %>%
  mutate(trial = "Pooled")

pred_summary <- tibble(
  Estimate = mean(draws$logOR_pred_new_trial),
  Q2.5 = quantile(draws$logOR_pred_new_trial, 0.025),
  Q97.5 = quantile(draws$logOR_pred_new_trial, 0.975),
  trial = "Predicted (new trial)"
  
)

# combine all coefficients
all_coefs <- bind_rows(trial_coefs, pop_coef, pred_summary) %>%
  mutate(trial = factor(
    trial, levels = c(levels(trial_coefs$trial), "Pooled", "Predicted (new trial)"))
  ) %>% 
  select(-Parameter)

all_coefs <- all_coefs %>%
  mutate(trial = if_else(
    trial %in% c("Pooled", "Predicted (new trial)"),
    trial,
    stringr::str_to_upper(trial)
  ))

trial_years <- c(
  "ANGEL" = 2023,
  "ATTENTION" = 2022,
  "BAOCHE" = 2022,
  "BASICS" = 2021,
  "BEST" = 2020,
  "DAWN" = 2018,
  "DEFUSE3" = 2018,
  "DISTAL" = 2025,
  "EASI" = 2017,
  "ESCAPE" = 2015,
  "ESCAPEMEVO" = 2025,
  "EXTENDIA" = 2015,
  "IMS3" = 2013,
  "LASTE" = 2024,
  "MRCLEAN" = 2015,
  "MRCLEANLATE" = 2023,
  "MRRESCUE" = 2013,
  "PISTE" = 2017, 
  "POSITIVE" = 2022,
  "RESCUEJAPAN" = 2022,
  "RESILIENT" = 2020,
  "REVASCAT" = 2015,
  "SELECT2" = 2023,
  "SWIFTPRIME" = 2015, 
  "SYNTHESIS" = 2013,
  "TENSION" = 2023,
  "TESLA" = 2024,
  "THERAPY" = 2016,
  "THRACE" = 2016,
  "THRILL" = 2016,
  "Pooled" = 3000,
  "Predicted (new trial)" = 3001
)

# assign a 'year' column
all_coefs <- all_coefs %>%
  mutate(year = trial_years[as.character(trial)])  

all_coefs <- all_coefs %>%
  mutate(trial = factor(trial,
                        levels = names(sort(trial_years, decreasing = TRUE))))

figure_one <- ggplot(all_coefs, aes(trial, Estimate, ymin = Q2.5, ymax = Q97.5)) +
  geom_pointrange() +
  coord_flip() +
  labs(x = "", y = "Common log odds ratio") +
  theme_classic() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  # Add the highlight rectangle
  geom_rect(data = subset(all_coefs, trial %in% c("Pooled", "Predicted (new trial)")),
            aes(xmin = as.numeric(trial) - 0.5, 
                xmax = as.numeric(trial) + 0.5,
                ymin = -Inf, ymax = Inf),
            fill = "lightgrey", alpha = 0.3) +
  geom_pointrange(data = subset(all_coefs, trial == "Pooled"),
                  size = 0.5, color = "grey10") +
  geom_pointrange(data = subset(all_coefs, trial == "Predicted (new trial)"),
                  size = 0.5, color = "grey10", linetype = "dashed")

ggsave(
  filename = here::here("artifacts", "figure_one.pdf"),
  plot = figure_one,
  device = pdf,  
  width = 7.5,       
  height = 5,         
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "figure_one.svg"),
  plot = figure_one,
  width = 7.5,
  height = 5,
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "figure_one.tiff"),
  plot = figure_one,
  device = "tiff",
  width = 7.5,
  height = 5,
  units = "in",
  dpi = 1200,
  compression = "lzw"
)

# figure two -------------------------------------------------------------------

re <- ranef(fit_ordinal)$trial

pts <- tibble(
  study = rownames(re[,,1]),
  alpha_hat = re[,"Estimate","Intercept"],
  beta_hat  = re[,"Estimate","treatmentthrombectomy"]    
) %>% 
  mutate(study_lab = toupper(study))

dr <- as_draws_df(fit_ordinal)
sd_a <- dr$'sd_trial__Intercept'
sd_b <- dr$'sd_trial__treatmentthrombectomy'
rho <- dr$'cor_trial__Intercept__treatmentthrombectomy'
m <- rho * (sd_b / sd_a) 

xgrid <- seq(min(pts$alpha_hat), max(pts$alpha_hat), length.out = 200)
pred  <- sapply(xgrid, function(x) m * x)   # matrix: draws x grid

summ <- tibble(
  x = xgrid,
  y_mean = apply(pred, 2, mean),
  y_025 = apply(pred, 2, quantile, 0.025),
  y_25 = apply(pred, 2, quantile, 0.25),
  y_75 = apply(pred, 2, quantile, 0.75),
  y_975   = apply(pred, 2, quantile, 0.975)
)

plot <- ggplot(pts, aes(alpha_hat, beta_hat)) +
  geom_line(data = summ, 
            inherit.aes = FALSE,
            aes(x, y = y_mean), 
            linewidth = 0.5) +
  geom_ribbon(data = summ, 
              inherit.aes = FALSE, 
              aes(x, ymin = y_25, ymax = y_75), 
              alpha = 0.15) +
  geom_ribbon(data = summ,
              inherit.aes = FALSE,
              aes(x, ymin = y_025, ymax = y_975),
              alpha = 0.1) +
  geom_point(size = 2, color = "black") +
  labs(
    x = "Control group outcome (centered log-odds)",
    y = "Treatment effect (centered log-odds)"
  ) +
  geom_hline(yintercept = 0, colour = "grey90", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "grey90", linewidth = 0.4) +
  theme_bw(base_size = 12) +
  theme(panel.grid = element_blank())

# choose a few trials to label (extremes on x/y)
label_df <- pts %>%
  slice_min(alpha_hat, n = 2) %>%
  bind_rows(pts %>% slice_max(alpha_hat, n = 2)) %>%
  bind_rows(pts %>% slice_min(beta_hat,  n = 2)) %>%
  bind_rows(pts %>% slice_max(beta_hat,  n = 2)) %>%
  distinct(study, .keep_all = TRUE)

figure_two <- plot +
  ggrepel::geom_text_repel(
    data = pts,
    aes(label = study_lab),
    max.overlaps = Inf,
    size = 2.9,
    box.padding = 0.25,
    point.padding = 0.15,
    segment.color = "grey75",
    segment.size = 0.15,
    seed = 42
  )

ggsave(
  filename = here::here("artifacts", "figure_two.pdf"),
  plot = figure_two,
  device = pdf,  
  width = 7.5,          
  height = 5,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "figure_two.svg"),
  plot = figure_two,
  width = 7.5,
  height = 5,
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "figure_two.tiff"),
  plot = figure_two,
  device = "tiff",
  width = 7.5,
  height = 5,
  units = "in",
  dpi = 1200,
  compression = "lzw"
)

# figure three -----------------------------------------------------------------
plot_df <- draws %>%
  group_by(model_id) %>%
  summarise(
    median = median(cor_int_trt),
    q025   = unname(quantile(cor_int_trt, 0.025)),
    q975   = unname(quantile(cor_int_trt, 0.975)),
    .groups = "drop"
  ) %>%
  mutate(
    model = recode(model_id,
                   ordinal_equal_var   = "Ordinal (PO)",
                   ordinal_unequal_var = "Ordinal (PO + unequal var)",
                   ordinal_adjacent    = "Ordinal (adjacent-category)",
                   binary_good_outcome = "Binary"
    ),
    model = factor(model, levels = c(
      "Ordinal (PO)",
      "Ordinal (PO + unequal var)",
      "Ordinal (adjacent-category)",
      "Binary"
    ))
  )

figure_three <- ggplot(plot_df, 
                       aes(y = model, x = median, xmin = q025, xmax = q975)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.6, alpha = 0.4) +
  geom_errorbarh(height = 0, linewidth = 0.6, color = "black") +
  geom_point(size = 2.6, color = "black") +
  coord_cartesian(xlim = c(min(plot_df$q025) - 0.05, 0.05)) +
  labs(x = expression(paste("Intercept-slope correlation (", rho, ")")), y = NULL) +
  theme_bw(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_text(size = 11),
    axis.text.x = element_text(size = 11),
    plot.margin = margin(t = 8, r = 8, b = 8, l = 6)
  )

ggsave(
  filename = here::here("artifacts", "figure_three.pdf"),
  plot = figure_three,
  device = pdf,  
  width = 7.5,          
  height = 5,          
  units = "in",
  dpi = 300
)

ggsave(
  filename = here::here("artifacts", "figure_three.svg"),
  plot = figure_three,
  width = 7.5,          
  height = 5,          
  units = "in",
  dpi = 300
)

# figure four ------------------------------------------------------------------
pgood_draws <- purrr::imap_dfr(fits, extract_trial_pgood_draws)

rd_draws <- pgood_draws %>%
  tidyr::pivot_wider(names_from = treatment, values_from = p_good) %>%
  mutate(
    p_control = medical,
    p_treat   = thrombectomy,
    RD = p_treat - p_control
  )

rd_summ <- rd_draws %>%
  group_by(model_id, trial) %>%
  summarise(
    pC_med = median(p_control),
    RD_med = median(RD),
    pC_q025 = quantile(p_control, 0.025),
    pC_q975 = quantile(p_control, 0.975),
    RD_q025 = quantile(RD, 0.025),
    RD_q975 = quantile(RD, 0.975),
    .groups = "drop"
  ) %>% 
  mutate(
    model = recode(model_id,
                   ordinal_equal_var   = "Ordinal (PO)",
                   ordinal_unequal_var = "Ordinal (PO + unequal var)",
                   ordinal_adjacent    = "Ordinal (adjacent-category)",
                   binary_good_outcome = "Binary"
    ),
    model = factor(model, levels = c(
      "Ordinal (PO)",
      "Ordinal (PO + unequal var)",
      "Ordinal (adjacent-category)",
      "Binary"
    )))

df <- rd_summ %>% 
  filter(model_id == "ordinal_equal_var") %>%
  mutate(trial_lab = toupper(trial))

# can be used to label fewer points
# label_df <- df %>%
#   slice_min(pC_med, n = 3) %>%
#   bind_rows(df %>% slice_max(pC_med, n = 3)) %>%
#   bind_rows(df %>% slice_max(RD_med, n = 3)) %>%
#   bind_rows(df %>% slice_min(RD_med, n = 3)) %>%
#   distinct(trial, .keep_all = TRUE)


fig_four <- rd_summ %>%
  ggplot(aes(x = pC_med, y = RD_med)) +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.6, alpha = 0.6) +
  geom_point(size = 2.0, color = "black") +
  geom_smooth(method = "loess", span = 0.9, se = TRUE, color = "black") +
  facet_wrap(~model, ncol = 2) +
  labs(
    x = "P(mRS 0-2) [control]",
    y = "P(mRS 0-2) [treatment - control]"
  ) +
  theme_bw(base_size = 12) +
  theme(panel.grid = element_blank())

fig_four <- rd_summ %>%
  ggplot(aes(x = pC_med, y = RD_med)) +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.6, alpha = 0.6) +
  geom_point(size = 2.0, color = "black") +
  geom_smooth(method = "loess", span = 0.9, se = TRUE, color = "black") +
  facet_wrap(~model, ncol = 2) +
  labs(
    x = expression(P[control]),
    y = expression(P[treatment]-P[control])
  ) +
  theme_bw(base_size = 12) +
  theme(panel.grid = element_blank())

ggsave(here::here("artifacts", "figure_four.pdf"),
       fig_four, device = pdf, width = 7.5, height = 5.5, units = "in")
ggsave(here::here("artifacts", "figure_four.svg"),
       fig_four, width = 6.5, height = 4.5, units = "in")
