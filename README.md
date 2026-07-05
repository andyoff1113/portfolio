# Research Portfolio

Live site: **https://andyoff1113.github.io/portfolio/**

A small R Markdown website showcasing past epidemiology / biostatistics
analyses:

- **HFRS Incubation Period Estimation** — Bayesian (Stan/HMC) and MLE
  estimation using a doubly interval-censored likelihood.
- **Internship at TWCR** — data visualization from an internship at the
  Taiwan Cancer Registry.
- **Bongkrekic Acid Food Poisoning (2024)** — early-stage outbreak
  forecasting with GMITS (Grey Model for Irregular Time Series),
  including a companion conference poster.

## Structure

- `src/` — the R Markdown source. Each page is a standalone `.Rmd` file,
  plus `Grey model.Rproj`, `_site.yml` (shared navbar and output style:
  theme, code folding, table CSS), `build.R`, `site_style.css`, and page
  assets (`images/`, `bongkrek_poster.pdf`). `src/archive/` holds older
  pages that are kept for reference but not published.
- `docs/` — the built output, served by GitHub Pages
  (Settings → Pages → branch `main` → `/docs`).

## Rebuilding the site

Open `src/Grey model.Rproj` in RStudio. After editing any `.Rmd`,
rebuild before committing so the deployed site stays in sync with the
source:

```r
source("build.R")
```

This renders each page in its own fresh `Rscript` process rather than
calling `rmarkdown::render_site()` directly. Knitting every page in one
shared R session lets an earlier page's leftover graphics-device state
blank out a later page's plot (a known knitr issue:
https://github.com/yihui/knitr/issues/1325) — that's exactly what broke
the Internship heatmap once. `build.R` sidesteps it entirely by giving
each page a clean process. `_site.yml`'s `output_dir: "../docs"` still
sends every page's output to the top-level `docs/`.

Then commit and push, including the regenerated `docs/` folder.
