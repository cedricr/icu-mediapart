library("here")

DATA_DIR <- here("data")
OUTPUT_DIR <- here("output")
dir.create(OUTPUT_DIR, showWarnings = FALSE)
# ---


load_src_data <- function() {
  admin_express_path <- here(DATA_DIR, "Admin_Express_3.2")
  districts_path <- here(admin_express_path, "ARRONDISSEMENT.shp")
  epcis_path <- here(admin_express_path, "EPCI.shp")
  cities_path <- here(admin_express_path, "COMMUNE.shp")
  qpvs_path <- here(DATA_DIR, "QPV", "QP_METROPOLE_LB93.shp")

  list(
    cities = st_read(cities_path, quiet = TRUE) |> st_transform(2154),
    epcis = st_read(epcis_path, quiet = TRUE) |> st_transform(2154),
    districts = st_read(districts_path, quiet = TRUE) |> st_transform(2154),
    qpvs = st_read(qpvs_path, quiet = TRUE) |> st_transform(2154)
  )
}

load_filosofi <- function() {
  filosofi_path <- here(DATA_DIR, "Filosofi2017_carreaux_200m_met.gpkg")
  st_read(filosofi_path, quiet = TRUE) |> st_transform(2154)
}

prepare_contours <- function(src_data, contour_id) {
  if (startsWith(contour_id, "ARR_DEP")) {
    src_data$districts |>
      filter(ID == contour_id) |>
      st_transform(2154)
  } else {
    src_data$epcis |>
      filter(CODE_SIREN == contour_id) |>
      st_transform(2154)
  }
}

crop_cities <- function(src_data, contour) {
  src_data$cities[contour, ]
}

crop_qpvs <- function(src_data, contour) {
  src_data$qpvs[contour, ]
}

crop_filo_grid <- function(filo_grid, contour) {
  filo_grid[contour, ]
}

extract_b10 <- function(landsat_product_id, contour) {
  tar_file <- here("data", "Landsat", str_c(landsat_product_id, ".tar"))
  b10_filename <- str_c(landsat_product_id, "_ST_B10.TIF")
  archive_extract(tar_file,
    dir = here("tmp"),
    files = b10_filename
  )
  here("tmp", b10_filename)
}

prepare_lst_raster <- function(city_name, band_10_file, contour) {
  to_celsius <- function(img) {
    mult_const <- 0.00341802
    add_const <- 149.0
    img * mult_const + add_const - 273.15
  }

  lst <- to_celsius(rast(band_10_file)) |>
    project("epsg:2154", gdal = TRUE) |>
    crop(contour) |>
    mask(contour)
  names(lst)[1] <- "land_surface_temperature"
  raster_file <- here("tmp", str_c("lst_", city_name, ".tif"))

  writeRaster(lst, raster_file, overwrite = TRUE)
  raster_file
}


enrich_grid <- function(grid, lst_raster) {
  stats <- extract(rast(lst_raster), grid, fun = mean)
  enriched_grid <- grid |>
    cbind(stats) |>
    st_as_sf() |>
    filter(!is.na(land_surface_temperature)) |>
    mutate(
      mean_std_living = Ind_snv / Ind,
      poverty_ratio = Men_pauv / Men
    ) |>
    rename(
      num_people = Ind,
      imputed = I_est_200,
      id = Idcar_200m
    ) |>
    select(id, imputed, num_people, mean_std_living, poverty_ratio, land_surface_temperature)
}


write_geopackage <- function(city_name, contour, cities, qpvs, enriched_grid) {
  data_file <- here(OUTPUT_DIR, str_c(city_name, ".gpkg"))

  st_write(contour,
    data_file,
    layer = "epci",
    delete_layer = TRUE, quiet = TRUE
  )

  st_write(cities,
    data_file,
    layer = "cities",
    delete_layer = TRUE, quiet = TRUE
  )

  st_write(qpvs,
    data_file,
    layer = "qpvs",
    delete_layer = TRUE, quiet = TRUE
  )

  st_write(enriched_grid,
    data_file,
    layer = "enriched_grid",
    delete_layer = TRUE, quiet = TRUE
  )

  data_file
}
