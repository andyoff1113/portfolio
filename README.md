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
  theme, code folding, table CSS), `site_style.css`, and page assets
  (`images/`, `bongkrek_poster.pdf`).
- `docs/` — the built output, served by GitHub Pages
  (Settings → Pages → branch `main` → `/docs`).

## Rebuilding the site

Open `src/Grey model.Rproj` in RStudio. After editing any `.Rmd`,
rebuild before committing so the deployed site stays in sync with the
source (`_site.yml`'s `output_dir: "../docs"` sends the build output to
the top-level `docs/`):

```r
rmarkdown::render_site()
```

Then commit and push, including the regenerated `docs/` folder.
