# Shared GMITS functions for all portfolio pages.
# Single source of truth: pages load this file via a knitr `file =` chunk,
# and external analyses (e.g. RA/mpox/gmits_england) source() it.
#
# 2026-10-13 fix in gmits(): integrating dx1/dt + a * x1 = b over
# [t_{k-1}, t_k] gives x0_k * dt_k = -a * z_k * dt_k + b * dt_k, so the
# regression is x0_k = -a * z_k + b. The previous version used
# B <- cbind(-z * delta_t, delta_t), which scaled (a, b) by 1 / dt and
# was exact only for dt = 1 (it flipped the sign of a on some irregular
# grids). See D:/KnowledgeVault/research/grey_system/figures/gmits_dt_bug.png

mae <- function(actual, predicted) {
  mean(abs(actual - predicted), na.rm = TRUE)
}

mape <- function(actual, predicted) {
  valid <- actual != 0
  mean(
    abs((actual[valid] - predicted[valid]) / actual[valid]),
    na.rm = TRUE
  ) * 100
}

# n_ahead: out-of-sample steps using mean(delta_t) as step size.
# Returns $x0_future (and $t_future as numeric time offsets) when n_ahead > 0.
gmits <- function(count, date, n_ahead = 0) {
  valid <- !is.na(count) & !is.na(date)
  x0    <- count[valid]
  date  <- date[valid]
  if (length(x0) < 2) {
    warning("Not enough valid data points for modeling.")
    return(NULL)
  }
  if (x0[1] == 0) x0[1] <- 1e-3
  n <- length(x0)

  delta_t    <- as.numeric(
    difftime(date[2:n], date[1:(n - 1)], units = "days")
  )
  time_index <- cumsum(c(0, delta_t))

  x1 <- cumsum(c(x0[1], x0[2:n] * delta_t))
  z  <- 0.5 * (x1[2:n] + x1[1:(n - 1)])

  B <- cbind(-z, 1)
  Y <- x0[2:n]
  W <- diag(delta_t)
  p <- solve(t(B) %*% W %*% B) %*% t(B) %*% W %*% Y
  a_hat <- p[1]
  b_hat <- p[2]

  x1_hat <- c(
    x1[1],
    (x1[1] - b_hat / a_hat) *
      exp(-a_hat * (time_index[-1] - time_index[1])) +
      b_hat / a_hat
  )
  x0_hat <- c(x0[1], diff(x1_hat) / delta_t)

  result <- list(
    a = a_hat, b = b_hat,
    x1_hat = x1_hat, x0_hat = x0_hat,
    date = date, delta_t = delta_t
  )

  if (n_ahead > 0) {
    dt_mean  <- mean(delta_t)
    t_future <- time_index[n] + cumsum(rep(dt_mean, n_ahead))
    x1_fut   <- (x1[1] - b_hat / a_hat) *
      exp(-a_hat * (t_future - time_index[1])) + b_hat / a_hat
    result$x0_future   <- c(
      (x1_fut[1] - x1_hat[n]) / dt_mean,
      diff(x1_fut) / dt_mean
    )
    result$date_future <- date[n] + round(dt_mean * seq_len(n_ahead))
  }
  result
}

# n_ahead > 0: point/lower/upper each extend to n + n_ahead;
# last n_ahead entries are the out-of-sample prediction interval.
gmits_boot <- function(count, date, n_boot = 1000, ci = 0.95, n_ahead = 0) {
  base <- gmits(count, date, n_ahead = n_ahead)
  if (is.null(base)) return(NULL)

  valid      <- !is.na(count) & !is.na(date)
  x0         <- count[valid]
  dv         <- date[valid]
  n          <- length(x0)
  resid_pool <- (x0 - base$x0_hat)[2:n]
  n_out      <- n + n_ahead

  boot_mat <- replicate(n_boot, {
    e_boot  <- sample(resid_pool, n - 1, replace = TRUE)
    x0_boot <- c(x0[1], pmax(base$x0_hat[2:n] + e_boot, 0))
    res     <- tryCatch(
      gmits(x0_boot, dv, n_ahead = n_ahead),
      error = function(e) NULL
    )
    if (is.null(res)) return(rep(NA_real_, n_out))
    c(res$x0_hat, if (n_ahead > 0) res$x0_future else NULL)
  })

  alpha <- (1 - ci) / 2
  list(
    point = c(base$x0_hat,
              if (n_ahead > 0) base$x0_future else NULL),
    lower = apply(boot_mat, 1, quantile, probs = alpha,     na.rm = TRUE),
    upper = apply(boot_mat, 1, quantile, probs = 1 - alpha, na.rm = TRUE),
    a = base$a,
    b = base$b
  )
}

# Log-linear OLS baseline: log(y) ~ t.
# Only non-zero observations are used (consistent with gmits non-zero day approach).
# n_ahead: step forward using mean(delta_t) of the input dates.
exp_reg <- function(count, date, n_ahead = 0) {
  valid <- !is.na(count) & count > 0 & !is.na(date)
  x0 <- count[valid]
  dv <- date[valid]
  t_num <- as.numeric(dv - dv[1])
  fit <- lm(log(x0) ~ t_num)
  n <- length(x0)
  dt_mean <- if (n > 1) mean(diff(t_num)) else 1

  result <- list(
    alpha    = coef(fit)[["(Intercept)"]],
    beta     = coef(fit)[["t_num"]],
    x0_hat   = exp(fitted(fit)),
    date     = dv
  )
  if (n_ahead > 0) {
    t_future <- t_num[n] + cumsum(rep(dt_mean, n_ahead))
    result$x0_future   <- exp(
      predict(fit, newdata = data.frame(t_num = t_future))
    )
    result$date_future <- dv[n] + round(dt_mean * seq_len(n_ahead))
  }
  result
}

# Multiply the most recent n_recent observations by scale_factor
# before passing to gmits(), simulating upward correction of right-truncated data.
truncation_adjust <- function(count, n_recent = 1, scale_factor = 1.5) {
  adj <- count
  idx <- tail(seq_along(count), n_recent)
  adj[idx] <- count[idx] * scale_factor
  adj
}

