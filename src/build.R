# Build the site with each page rendered in its own fresh R process.
#
# rmarkdown::render_site() with no `input` knits every page in one shared
# R session. That leaves later pages exposed to whatever graphics-device
# or option state an earlier page's chunks left behind -- a known
# knitr issue (https://github.com/yihui/knitr/issues/1325) that once
# produced a blank ggplot on this site. Rendering each page in its own
# process sidesteps that entirely.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grepl("^--file=", args)])
script_dir <- dirname(normalizePath(file_arg))
setwd(script_dir)

rmd_pages <- list.files(".", pattern = "\\.Rmd$", full.names = FALSE)
rscript <- file.path(R.home("bin"), "Rscript")

for (page in rmd_pages) {
  cat("== Building", page, "==\n")
  status <- system2(
    rscript,
    args = c("-e", shQuote(sprintf(
      'rmarkdown::render_site(input = "%s")', page
    ))),
    stdout = "", stderr = ""
  )
  if (status != 0) {
    stop("Build failed for ", page)
  }
}

cat("All pages built successfully.\n")
