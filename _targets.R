library(targets)
library(tarchetypes)


# Set target options:
tar_option_set(
  packages = c(
    "archive", "dplyr", "here", "sf", "stringr", "terra"
  )
)

tar_source()

# ---

scenes <- data.frame(
  city_name = c("lille", "marseille", "paris"),
  url = c(
    "https://earthexplorer.usgs.gov/scene/metadata/full/5e83d14f2fc39685/LC81990252022225LGN00/",
    "https://earthexplorer.usgs.gov/scene/metadata/full/5e83d14f2fc39685/LC91960302022196LGN00/",
    "https://earthexplorer.usgs.gov/scene/metadata/full/5e83d14f2fc39685/LC81990262022225LGN00/"
  ),
  product_id = c(
    "LC08_L2SP_199025_20220813_20220824_02_T1",
    "LC09_L2SP_196030_20220715_20220719_02_T1",
    "LC08_L2SP_199026_20220813_20220824_02_T1"
  ),
  contour_id = c("200093201",
                 "ARR_DEP_FXX_000000000047",
                 "200054781")
)

list(
  tar_target(
    src_data,
    load_src_data()
  ),
  tar_target(
    filo_grid,
    load_filosofi()
  ),
  tar_map(
    values = scenes,
    names = "city_name",
    tar_target(
      contours,
      prepare_contours(src_data, contour_id),
    ),
    tar_target(
      cities,
      crop_cities(src_data, contours),
    ),
    tar_target(
      qpvs,
      crop_qpvs(src_data, contours)
    ),
    tar_target(
      grid,
      crop_filo_grid(filo_grid, contours)
    ),
    tar_target(
      band_10_file,
      extract_b10(product_id, contours),
      format = "file"
    ),
    tar_target(
      lst,
      prepare_lst_raster(city_name, band_10_file, contours),
      format = "file"
    ),
    tar_target(
      enriched_grid,
      enrich_grid(grid, lst),
    ),
    tar_target(
      geopackage,
      write_geopackage(city_name, contours, cities, qpvs, enriched_grid),
      format = "file"
    )
  )
)
