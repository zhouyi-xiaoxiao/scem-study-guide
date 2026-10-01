# Original practice · 原创练习

These are independently written companion exercises covering Week 2 topics, not a copy of an official worksheet or its staff-only model answers. They are not an assessed submission template. Use your course's official materials for the actual task and required object names.

以下是原创练习与小型自检，不是官方题单或教师参考答案。**先预测，再运行，再解释**；能运行不等于推理正确。The accompanying [examples.R](examples.R) supplies runnable demonstrations, not full worked solutions to every extension below.

## 1. Index before you run · 先预测索引

Let `x <- c(3, 7, 11, 15)`. Predict `x[1]`, `x[-1]`, `x[0]`, and `x[x >= 10]`. Explain why `x[0]` is not the first element.

**Check / 自检：** `3`; `7, 11, 15`; an empty numeric vector; `11, 15`. R positions start at 1. Negative indices exclude positions; logical vectors select positions.

## 2. Columns versus rows · 选列还是筛行

Using `palmerpenguins::penguins`, retain `species`, `island`, `flipper_length_mm`, and `body_mass_g`. Then keep observations from Dream island with recorded flipper length. Name the two operations and state which changes the number of columns.

**Hint / 提示：** `dplyr::select()` selects variables; `dplyr::filter()` selects observations. Selecting these four fields gives four columns. Filtered rows should all have `island == "Dream"` and nonmissing flipper length.

## 3. A unit conversion · 新增一列

Create body mass in kilograms without overwriting the grams column. What would 4,200 grams become? Why preserve the original unit?

**Check / 自检：** `4.2` kg. Use `mutate()` with division by 1,000. The new column and original column should agree wherever mass is observed; missing values stay missing.

## 4. Sorting is not sampling · 排序不是抽样

Sort the filtered data by decreasing flipper length; inspect the first six rows. Does this form a random sample? Why might its mean be misleading as an estimate for all penguins?

**Hint / 提示：** `arrange(desc(...))`. Selecting the longest-flipper observations deliberately biases selection; ordering rows does not randomize them.

## 5. Group summaries with honest denominators · 分组与有效样本数

Group by both island and species. Report total rows, the count with observed body mass, and average observed mass for each group. Why should you report both counts?

**Check / 自检：** Summing group row counts recovers the original row count. The count used in the average may be smaller. `na.rm = TRUE` removes missing entries from the calculation; it does not repair missingness or prove that the remaining data are representative.

## 6. Mean, variance, SD and quantile · 四种统计量

For `c(2, 4, 6, 8)`, calculate the mean, sample variance, sample standard deviation, and 75th percentile using R's `quantile(type = 7)`. State the units of variance and standard deviation if observations are in grams.

**Check / 自检：** Mean `5`; sample variance `20/3`; SD `sqrt(20/3)`; 75th percentile `6.5`. Variance has squared units; SD retains grams. R's sample variance divides by `n-1`; quantile interpolation conventions matter.

## 7. Bayes with a rare condition · 贝叶斯公式

For a fictional population, prevalence is 3%, sensitivity is 90%, and specificity is 96%. Among positive results, what proportion have the condition? Write a function receiving all three probabilities; decide what it should do when positive results have zero probability.

**Hint / 提示：**

```text
P(condition | positive)
  = sensitivity × prevalence
    / [sensitivity × prevalence + (1 − specificity) × (1 − prevalence)]
```

**Check / 自检：** `0.027 / 0.0658 = 135/329`, approximately `0.410334`, not `0.90`. In 100,000 hypothetical people, expected true positives are 2,700 and expected false positives are 3,880. These are expectations, not guaranteed simulated counts. This is a mathematical exercise, not a real screening recommendation.

## 8. Match simulation to theory · 理论与模拟用同一组参数

With seed `20261002`, simulate 100,000 condition indicators as Bernoulli draws. Then simulate a positive result using probability `0.90` for those with the condition and `0.04` for those without. Estimate the fraction with the condition **among positives**.

**Check / 自检：** The denominator is the number of positive results, not 100,000. Compare with `135/329` using exactly the same parameters. Monte Carlo error is expected; approximate conditional standard error is `sqrt(p * (1-p) / number_positive)` with theoretical `p = 135/329`. A seed gives reproducibility within a compatible random-number setup, not equality with the theoretical probability.

## 9. One statistic versus many statistics · 一个均值与均值分布

Remove missing masses, regard the remaining masses as an empirical population, and draw a sample of 12 with replacement. Calculate its mean. Repeat with a fresh sample 2,000 times. What does each value in the resulting vector represent?

**Check / 自检：** Each value represents a mean from one sample of 12 masses. The vector length is 2,000, not 12. Replacement allows repeated rows and makes independent sampling from the empirical population explicit; it does not create new biological observations.

## 10. Change sample size, not replication count · 样本量与重复次数

Repeat Exercise 9 using samples of 72. Keep the replication count fixed at 2,000. Compare the SD of the sample means, not the SD inside one individual sample. Predict the ratio before running.

**Check / 自检：** Under independent draws, `SD(mean at n=72) / SD(mean at n=12) = sqrt(12/72)`, approximately `0.4082`. The observed ratio will fluctuate. Increasing replication count improves estimation of the sampling distribution; increasing sample size changes that distribution's spread.

## 11. Uniform CLT demonstration · 均匀分布

Draw fresh independent samples from `Uniform(-2,4)` for sample sizes 1, 8, 40 and 160. For each size, collect 2,000 means. Plot histograms using common bin edges and common horizontal and vertical limits within this family.

**Check / 自检：** Population mean is `1`, variance is `3`, and theoretical SD of a mean is `sqrt(3/n)`. At `n=1` the distribution is uniform, not approximately normal; larger `n` makes the mean distribution narrower and more bell-shaped. Separate automatic axes can hide the narrowing.

## 12. Exponential CLT demonstration · 偏斜分布

Repeat Exercise 11 for an exponential distribution with rate `0.5`. Compare how skewness changes. Explain why the raw observations remain exponentially distributed even when their sample means look approximately normal.

**Check / 自检：** Population mean is `2`, variance is `4`, and theoretical SD of a mean is `2/sqrt(n)`. CLT concerns standardized sums or means under suitable assumptions, not a transformation of the original population into a normal distribution. Finite-sample approximation quality depends on the population and sample size.

## 13. Stretch: variance and quantile estimators · 拓展

In the empirical mass example, collect sample variances and 75th percentiles instead of sample means. Compare their distributions for `n=12` and `n=72`. Must their sampling distributions have the same shape or the same theoretical standard-error formula as means?

**Hint / 提示：** No. Different estimators have different sampling behavior. Keep `quantile(type=7)` fixed to avoid changing the estimator. The simple `sigma/sqrt(n)` expression is for an independent-sample mean, not a universal formula for all statistics.

## 14. Explain, then debug · 解释与排错

A student says: “My mean is `NA`, my simulation differs from my friend's, and the two histograms look equally wide.” Give a separate diagnostic question for each claim rather than changing random code.

**Hints / 提示：** Check missing observations and the intended treatment; compare seeds and simulation parameters; compare axis limits and bins. Ask “What does one plotted value represent?” before interpreting any histogram.

## Running the examples · 运行说明

From a directory where you are happy to create a PDF:

```sh
Rscript examples.R
```

Base-R sections run without external packages. Optional penguin sections use `palmerpenguins` and `dplyr`; optional `purrr` shows one additional repetition style. The script reports unavailable packages and never installs anything automatically. It writes `sampling-distributions.pdf` in the working directory.

**Verification boundary / 核验边界：** These files were authored without an available local R runtime. Deterministic mathematical checks were independently checked in Python; execution of this R script, package compatibility, random simulation output and PDF appearance remain unverified until it is run in R. Assertions inside the script are checks to be executed, not evidence that execution has already passed.
