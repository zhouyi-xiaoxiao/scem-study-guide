#!/usr/bin/env Rscript
# Original companion examples: SCEM Week 2 topics.
# Not an official assignment, answer sheet, or university-endorsed resource.
# Run: Rscript examples.R
# No packages are installed automatically. Base-R sections work without packages.

cat("\n1. Indexing / 索引\n")
x <- c(3, 7, 11, 15)
print(x[1])
print(x[-1])
print(x[0])
print(x[x >= 10])
stopifnot(identical(x[1], 3), identical(x[-1], c(7, 11, 15)),
          length(x[0]) == 0L, identical(x[x >= 10], c(11, 15)))
small <- data.frame(name = c("A", "B", "C"), score = c(4, NA, 8))
stopifnot(identical(small[, "score"], small$score))
cat("Indexing self-checks passed.\n")

cat("\n2. Summaries and missing values / 统计量与缺失值\n")
z <- c(2, 4, 6, 8)
print(c(mean = mean(z), variance = var(z), sd = sd(z),
        q75 = unname(quantile(z, 0.75, type = 7))))
stopifnot(mean(z) == 5, isTRUE(all.equal(var(z), 20 / 3)),
          isTRUE(all.equal(sd(z)^2, var(z))),
          unname(quantile(z, 0.75, type = 7)) == 6.5,
          is.na(mean(small$score)), mean(small$score, na.rm = TRUE) == 6)
# R var() uses denominator n-1. quantile(type=7) interpolates by default.
cat("Summary self-checks passed.\n")

cat("\n3. Bayes: fictional screening / 贝叶斯：虚构检测例子\n")
bayes_positive_demo <- function(prevalence, sensitivity, specificity) {
  p <- c(prevalence, sensitivity, specificity)
  if (length(prevalence) != 1L || length(sensitivity) != 1L ||
      length(specificity) != 1L || any(!is.finite(p)) ||
      any(p < 0 | p > 1)) stop("Provide three finite probabilities in [0,1].")
  denominator <- sensitivity * prevalence +
    (1 - specificity) * (1 - prevalence)
  if (denominator == 0) stop("P(positive)=0: conditional probability undefined.")
  sensitivity * prevalence / denominator
}
prevalence <- 0.03
sensitivity <- 0.90
specificity <- 0.96
theory <- bayes_positive_demo(prevalence, sensitivity, specificity)
stopifnot(isTRUE(all.equal(theory, 135 / 329)))
cat(sprintf("Theoretical P(condition | positive): %.6f\n", theory))
set.seed(20261002)
people <- 100000L
condition <- rbinom(people, size = 1L, prob = prevalence) == 1L
positive_probability <- ifelse(condition, sensitivity, 1 - specificity)
positive <- rbinom(people, size = 1L, prob = positive_probability) == 1L
stopifnot(sum(positive) > 0L)
simulation <- mean(condition[positive])
mc_se <- sqrt(theory * (1 - theory) / sum(positive))
print(c(theory = theory, simulation = simulation,
        positive_count = sum(positive), approximate_MC_SE = mc_se))
cat("Monte Carlo estimates fluctuate; exact equality is not expected.\n")
# This is a mathematical example, not medical advice or a real test specification.

cat("\n4. Sampling distributions and CLT / 抽样分布与中心极限定理\n")
set.seed(4102)
replications <- 2000L
sample_sizes <- c(1L, 8L, 40L, 160L)
draw_means <- function(generator, n, repetitions = replications) {
  # Each column is a fresh independent sample; no cumulative/prefix samples.
  colMeans(matrix(generator(n * repetitions), nrow = n, ncol = repetitions))
}
uniform_means <- lapply(sample_sizes, function(n)
  draw_means(function(k) runif(k, min = -2, max = 4), n))
exponential_means <- lapply(sample_sizes, function(n)
  draw_means(function(k) rexp(k, rate = 0.5), n))

describe_means <- function(values, population_mean, population_variance) {
  data.frame(n = sample_sizes,
             observed_mean = vapply(values, mean, numeric(1)),
             observed_SD = vapply(values, sd, numeric(1)),
             theoretical_mean = population_mean,
             theoretical_SD = sqrt(population_variance / sample_sizes))
}
cat("Uniform(-2,4): population mean 1; variance 3\n")
print(describe_means(uniform_means, 1, 3))
cat("Exponential(rate=0.5): population mean 2; variance 4\n")
print(describe_means(exponential_means, 2, 4))

plot_family <- function(values, label, expected_mean) {
  # Shared breaks AND shared x/y limits make widths directly comparable.
  shared_breaks <- seq(min(unlist(values)) - 1e-8,
                       max(unlist(values)) + 1e-8, length.out = 51L)
  hs <- lapply(values, hist, breaks = shared_breaks, plot = FALSE)
  shared_ylim <- c(0, max(vapply(hs, function(h) max(h$density), numeric(1))))
  for (i in seq_along(values)) {
    plot(hs[[i]], freq = FALSE, xlim = range(shared_breaks), ylim = shared_ylim,
         main = paste(label, "n =", sample_sizes[i]),
         xlab = "One sample mean", col = "lightblue", border = "white")
    abline(v = expected_mean, col = "firebrick", lwd = 2)
  }
}
# Save to the current working directory; avoids an interactive plotting device.
pdf("sampling-distributions.pdf", width = 12, height = 7)
par(mfrow = c(2, 4), mar = c(4, 4, 3, 1))
plot_family(uniform_means, "Uniform", 1)
plot_family(exponential_means, "Exponential", 2)
invisible(dev.off())
cat("Wrote sampling-distributions.pdf in the working directory.\n")
cat("Normal-looking means do not imply normal-looking original observations.\n")

cat("\n5. Optional penguin data manipulation / 可选企鹅数据整理\n")
required <- c("palmerpenguins", "dplyr")
available <- vapply(required, requireNamespace, logical(1), quietly = TRUE)
if (!all(available)) {
  cat("Skipped optional penguin examples. Missing packages:",
      paste(required[!available], collapse = ", "), "\n")
  cat('If permitted in your own R environment, run install.packages(c("palmerpenguins", "dplyr")).\n')
  cat("All preceding base-R examples remain available; no installation was attempted.\n")
} else {
  penguins <- palmerpenguins::penguins
  # select chooses columns; filter chooses rows.
  chosen <- dplyr::select(penguins, species, island, flipper_length_mm, body_mass_g)
  on_dream <- dplyr::filter(chosen, island == "Dream", !is.na(flipper_length_mm))
  converted <- dplyr::mutate(on_dream, body_mass_kg = body_mass_g / 1000)
  ordered <- dplyr::arrange(converted, dplyr::desc(flipper_length_mm))
  print(head(ordered, 6))
  grouped <- dplyr::group_by(penguins, island, species)
  summary_by_group <- dplyr::summarise(grouped,
    rows = dplyr::n(), observed_mass = sum(!is.na(body_mass_g)),
    mean_mass_g = mean(body_mass_g, na.rm = TRUE), .groups = "drop")
  print(summary_by_group)
  stopifnot(ncol(chosen) == 4L, all(on_dream$island == "Dream"),
            sum(summary_by_group$rows) == nrow(penguins))

  # Treat observed masses as a finite empirical population for this demonstration.
  # Replacement makes these independent draws from that empirical distribution.
  masses <- penguins$body_mass_g[!is.na(penguins$body_mass_g)]
  set.seed(5202)
  sample_mean <- function(n) mean(sample(masses, size = n, replace = TRUE))
  empirical_means <- lapply(c(12L, 72L), function(n)
    replicate(2000L, sample_mean(n)))
  empirical_population_sd <- sqrt(mean((masses - mean(masses))^2))
  print(data.frame(n = c(12L, 72L),
    mean_of_means = vapply(empirical_means, mean, numeric(1)),
    SD_of_means = vapply(empirical_means, sd, numeric(1)),
    expected_SD = empirical_population_sd / sqrt(c(12, 72))))
  cat("This empirical resampling exercise is not proof about all wild penguins.\n")
  if (requireNamespace("purrr", quietly = TRUE)) {
    set.seed(6202)
    via_purrr <- purrr::map_dbl(seq_len(100L), function(i) sample_mean(12L))
    stopifnot(length(via_purrr) == 100L, all(is.finite(via_purrr)))
    cat("Optional purrr::map_dbl example completed.\n")
  } else {
    cat("purrr unavailable: optional map_dbl example skipped; replicate() already demonstrates repetition.\n")
  }
}
cat("\nFinished examples. Review concepts, not just whether code runs.\n")
