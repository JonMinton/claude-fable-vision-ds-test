# Flower-glyph engine for the edible plants page.
# Maps growing-condition variables onto petal geometry, Chernoff-face style.
library(tidyverse)

parse_days <- function(x) {
  map_dbl(x, \(s) {
    nums <- as.numeric(str_extract_all(s, "[0-9]+(\\.[0-9]+)?")[[1]])
    if (length(nums) == 0) NA_real_ else mean(nums)
  })
}

load_plants <- function(path = "data/edible_plants.csv") {
  read_csv(path, show_col_types = FALSE) |>
    mutate(
      water_lvl = case_when(
        str_detect(str_to_lower(water), "very low") ~ 1,
        str_detect(str_to_lower(water), "very high") ~ 5,
        str_detect(str_to_lower(water), "low") ~ 2,
        str_detect(str_to_lower(water), "high") ~ 4,
        str_detect(str_to_lower(water), "medium") ~ 3
      ),
      sun_lvl = case_when(
        str_detect(str_to_lower(sunlight), "full shade") |
          str_to_lower(sunlight) == "partial shade" ~ "Shade-tolerant",
        str_detect(str_to_lower(sunlight), "partial") ~ "Sun or part shade",
        TRUE ~ "Full sun"
      ),
      nutrient_lvl = case_when(
        str_detect(str_to_lower(nutrients), "high") ~ 3,
        str_detect(str_to_lower(nutrients), "medium") ~ 2,
        str_detect(str_to_lower(nutrients), "low") ~ 1
      ),
      harvest_days = parse_days(days_harvest),
      ph_mid = (preferred_ph_lower + preferred_ph_upper) / 2
    )
}

# One petal: an ellipse anchored at the flower centre, pointing along `angle`
petal_poly <- function(angle, len, wid, n = 36) {
  t <- seq(0, 2 * pi, length.out = n)
  radial <- len / 2 + (len / 2) * cos(t)
  tangential <- (wid / 2) * sin(t)
  tibble(
    x = radial * sin(angle) + tangential * cos(angle),
    y = radial * cos(angle) - tangential * sin(angle)
  )
}

# All petal polygons for one plant, in glyph-local coordinates
flower_polys <- function(n_petals, len, wid) {
  map2_dfr(
    seq_len(n_petals), (seq_len(n_petals) - 1) * 2 * pi / n_petals,
    \(i, a) petal_poly(a, len, wid) |> mutate(petal = i)
  )
}

# Build plotting data for a set of plants laid out on a grid
build_garden <- function(plants, ncol = 6, cell = 3.1) {
  glyphs <- plants |>
    mutate(
      n_petals = c("Shade-tolerant" = 5, "Sun or part shade" = 6,
                   "Full sun" = 8)[sun_lvl],
      petal_len = scales::rescale(sqrt(harvest_days), to = c(0.55, 1.40)),
      petal_wid = c(0.22, 0.30, 0.40, 0.50, 0.58)[water_lvl],
      centre_r = c(0.16, 0.26, 0.38)[nutrient_lvl],
      col0 = (row_number() - 1) %% ncol,
      row0 = (row_number() - 1) %/% ncol,
      cx = col0 * cell,
      cy = -row0 * cell
    )

  petals <- glyphs |>
    select(common_name, cx, cy, n_petals, petal_len, petal_wid, ph_mid) |>
    pmap_dfr(\(common_name, cx, cy, n_petals, petal_len, petal_wid, ph_mid) {
      flower_polys(n_petals, petal_len, petal_wid) |>
        mutate(x = x + cx, y = y + cy,
               common_name = common_name, ph_mid = ph_mid,
               id = paste(common_name, petal))
    })

  centres <- glyphs |>
    mutate(t = list(seq(0, 2 * pi, length.out = 40))) |>
    unnest(t) |>
    mutate(x = cx + centre_r * cos(t), y = cy + centre_r * sin(t))

  list(glyphs = glyphs, petals = petals, centres = centres)
}

# Hydrangea logic: acid soil -> blue, alkaline -> pink
ph_colours <- function() {
  scale_fill_gradient2(
    low = "#4a6fb5", mid = "#9277b8", high = "#d4699e",
    midpoint = 6.4, name = "Preferred soil pH",
    breaks = c(5.5, 6.5, 7.5)
  )
}

draw_garden <- function(garden, label_size = 2.7) {
  ggplot() +
    geom_polygon(
      data = garden$petals,
      aes(x, y, group = id, fill = ph_mid),
      colour = "white", linewidth = 0.35, alpha = 0.92
    ) +
    geom_polygon(
      data = garden$centres,
      aes(x, y, group = common_name),
      fill = "#e8b04b", colour = "#b07d22", linewidth = 0.4
    ) +
    geom_text(
      data = garden$glyphs,
      aes(cx, cy - 1.62, label = common_name),
      size = label_size, colour = "#4b3f2f", family = "Georgia"
    ) +
    ph_colours() +
    coord_fixed(clip = "off") +
    theme_void(base_family = "Georgia") +
    theme(
      plot.background = element_rect(fill = "#faf6ec", colour = NA),
      legend.position = "bottom",
      plot.title = element_text(size = 17, hjust = 0.5,
                                margin = margin(b = 2)),
      plot.subtitle = element_text(size = 10.5, hjust = 0.5,
                                   colour = "#6b5d49",
                                   margin = margin(b = 12)),
      legend.title = element_text(size = 9.5),
      plot.margin = margin(15, 20, 10, 20)
    )
}
