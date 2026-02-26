# make_tiffs.R
# Regenerates Figures 1 and 2 as TIFF (1200 DPI, LZW compression)
# for JAMA Neurology submission. Loads cached model objects — no Stan sampling.

suppressPackageStartupMessages({
  library(here)
  library(dplyr)
  library(tibble)
  library(stringr)
  library(ggplot2)
  library(ggrepel)
  library(brms)
  library(posterior)
})

here::i_am("run.R")

# load cached objects ----------------------------------------------------------
message("Loading cached model and draws...")
fit_ordinal <- readRDS(here("artifacts/fit_ordinal.rds"))
draws        <- readRDS(here("artifacts/draws.rds"))
message("Done.")

# figure one -------------------------------------------------------------------
message("Building Figure 1...")

trial_coefs <- coef(fit_ordinal, summary = FALSE)$trial[, , "treatmentthrombectomy"] %>%
  posterior_summary() %>%
  as_tibble(rownames = "trial") %>%
  arrange(Estimate) %>%
  mutate(trial = factor(trial, levels = trial))

pop_coef <- fixef(fit_ordinal) %>%
  as_tibble(rownames = "Parameter") %>%
  filter(Parameter == "treatmentthrombectomy") %>%
  mutate(trial = "Pooled")

pred_summary <- tibble(
  Estimate = mean(draws$logOR_pred_new_trial),
  Q2.5     = quantile(draws$logOR_pred_new_trial, 0.025),
  Q97.5    = quantile(draws$logOR_pred_new_trial, 0.975),
  trial    = "Predicted (new trial)"
)

all_coefs <- bind_rows(trial_coefs, pop_coef, pred_summary) %>%
  mutate(trial = factor(
    trial, levels = c(levels(trial_coefs$trial), "Pooled", "Predicted (new trial)"))
  ) %>%
  select(-Parameter)

all_coefs <- all_coefs %>%
  mutate(trial = if_else(
    trial %in% c("Pooled", "Predicted (new trial)"),
    trial,
    str_to_upper(trial)
  ))

trial_years <- c(
  "ANGEL" = 2023, "ATTENTION" = 2022, "BAOCHE" = 2022, "BASICS" = 2021,
  "BEST" = 2020, "DAWN" = 2018, "DEFUSE3" = 2018, "DISTAL" = 2025,
  "EASI" = 2017, "ESCAPE" = 2015, "ESCAPEMEVO" = 2025, "EXTENDIA" = 2015,
  "IMS3" = 2013, "LASTE" = 2024, "MRCLEAN" = 2015, "MRCLEANLATE" = 2023,
  "MRRESCUE" = 2013, "PISTE" = 2017, "POSITIVE" = 2022, "RESCUEJAPAN" = 2022,
  "RESILIENT" = 2020, "REVASCAT" = 2015, "SELECT2" = 2023, "SWIFTPRIME" = 2015,
  "SYNTHESIS" = 2013, "TENSION" = 2023, "TESLA" = 2024, "THERAPY" = 2016,
  "THRACE" = 2016, "THRILL" = 2016,
  "Pooled" = 3000, "Predicted (new trial)" = 3001
)

all_coefs <- all_coefs %>%
  mutate(year = trial_years[as.character(trial)]) %>%
  mutate(trial = factor(trial, levels = names(sort(trial_years, decreasing = TRUE))))

figure_one <- ggplot(all_coefs, aes(trial, Estimate, ymin = Q2.5, ymax = Q97.5)) +
  geom_pointrange() +
  coord_flip() +
  labs(x = "", y = "Common log odds ratio") +
  theme_classic() +
  geom_hline(yintercept = 0, linetype = "dashed") +
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
  filename = here("artifacts", "figure_one.tiff"),
  plot     = figure_one,
  device   = "tiff",
  width    = 7.5,
  height   = 5,
  units    = "in",
  dpi      = 1200,
  compression = "lzw"
)
message("Figure 1 TIFF saved.")

# figure two -------------------------------------------------------------------
message("Building Figure 2...")

re <- ranef(fit_ordinal)$trial

pts <- tibble(
  study     = rownames(re[,,1]),
  alpha_hat = re[, "Estimate", "Intercept"],
  beta_hat  = re[, "Estimate", "treatmentthrombectomy"]
) %>%
  mutate(study_lab = toupper(study))

dr    <- as_draws_df(fit_ordinal)
sd_a  <- dr$`sd_trial__Intercept`
sd_b  <- dr$`sd_trial__treatmentthrombectomy`
rho   <- dr$`cor_trial__Intercept__treatmentthrombectomy`
m     <- rho * (sd_b / sd_a)

xgrid <- seq(min(pts$alpha_hat), max(pts$alpha_hat), length.out = 200)
pred  <- sapply(xgrid, function(x) m * x)

summ <- tibble(
  x      = xgrid,
  y_mean = apply(pred, 2, mean),
  y_025  = apply(pred, 2, quantile, 0.025),
  y_25   = apply(pred, 2, quantile, 0.25),
  y_75   = apply(pred, 2, quantile, 0.75),
  y_975  = apply(pred, 2, quantile, 0.975)
)

base_plot <- ggplot(pts, aes(alpha_hat, beta_hat)) +
  geom_line(data = summ, inherit.aes = FALSE,
            aes(x, y = y_mean), linewidth = 0.5) +
  geom_ribbon(data = summ, inherit.aes = FALSE,
              aes(x, ymin = y_25, ymax = y_75), alpha = 0.15) +
  geom_ribbon(data = summ, inherit.aes = FALSE,
              aes(x, ymin = y_025, ymax = y_975), alpha = 0.1) +
  geom_point(size = 2, color = "black") +
  labs(x = "Control group outcome (centered log-odds)",
       y = "Treatment effect (centered log-odds)") +
  geom_hline(yintercept = 0, colour = "grey90", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "grey90", linewidth = 0.4) +
  theme_bw(base_size = 12) +
  theme(panel.grid = element_blank())

figure_two <- base_plot +
  ggrepel::geom_text_repel(
    data          = pts,
    aes(label     = study_lab),
    max.overlaps  = Inf,
    size          = 2.9,
    box.padding   = 0.25,
    point.padding = 0.15,
    segment.color = "grey75",
    segment.size  = 0.15,
    seed          = 42
  )

ggsave(
  filename = here("artifacts", "figure_two.tiff"),
  plot     = figure_two,
  device   = "tiff",
  width    = 7.5,
  height   = 5,
  units    = "in",
  dpi      = 1200,
  compression = "lzw"
)
message("Figure 2 TIFF saved.")

message("\nDone. Files written to artifacts/:")
message("  figure_one.tiff")
message("  figure_two.tiff")
