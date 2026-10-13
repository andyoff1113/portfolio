# 2022 England mpox (specimen date)

Copied from the `publication_data/` folder of the code and data repository
`nowcasting_the_2022_mpox_outbreak_in_england` accompanying Overton et al.
(2023), released under CC0 1.0 (see `LICENSE`).

- `full_data_specimen.csv`: daily cases by specimen date after backfilling
  (ground truth). `origin` is an anonymised day index.
- `nowcasting_input_specimen_<T>.csv`: reporting triangle as of day `T`
  (`value` is NA for cells not yet observed). Only the growth-phase
  snapshots used on the GMITS page (T = 75, 80, ..., 100) are included.

Reference: Overton, C. E., et al. (2023). Nowcasting the 2022 mpox outbreak
in England. arXiv:2302.09076.
