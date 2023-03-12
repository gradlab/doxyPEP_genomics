library(tidyverse)
library(stringr)

tet <- read_tsv("data/doxyPEP_QCpassing.tsv")

# plot tet MICs

tet %>% ggplot(aes(x=tetM, y = tetracycline_numeric, group = tetM)) +
  geom_violin(adjust = 1.1) +
  scale_y_continuous(trans = "log2") +
  theme_minimal()

# calculate high-level resistance explained by tetM
tet %>% filter(tetracycline_numeric > 8) %>% count(tetM) %>% mutate(proportion = n/sum(n))


# calculate tetM+ isolates with MIC <= 8
tet %>% filter(tetracycline_numeric <= 8) %>% count(tetM)
tet %>% count(tetM)

# write list of isolates
#tet %>% select(wgs_id) %>% write_tsv("qc_pass_test_isolates.txt")


# unexplained susceptibility on tree
susceptible <- tet %>% filter(tetracycline_numeric < 4, tetM == "1")

itol <- susceptible %>% mutate(susceptible_triangle = 0) %>%
  select(wgs_id, susceptible_triangle, tetracycline)

# unexplained high-level resistance

unexplained_hl <- tet %>% filter(tetracycline_numeric > 8, tetM == "0")

itol_unexplained_hl <- unexplained_hl %>% mutate(resistant_triangle = 1) %>% select(wgs_id, resistant_triangle, tetracycline)

itol <- itol %>% full_join(itol_unexplained_hl)

itol <- itol %>% replace_na(list(susceptible_triangle = -1, resistant_triangle = -1))
itol <- itol %>% select(wgs_id, susceptible_triangle, resistant_triangle)
itol %>% write_tsv("data/itol/itol_unexplained_susceptibility_resistance.txt")

itol_tetM <- tetM_presence %>% mutate(color = case_when(tetM == 0 ~ "#d7b5d8", tetM == 1 ~ "#ce1256")) %>% select(wgs_id, color, tetM)

#itol_tetM %>% write_tsv("data/itol/itol_tetM.txt")

susceptible %>% count(reference)

# itol geography
itol_geography <- tet %>% mutate(color = case_when(continent == "Africa" ~ "#7fc97f",
                                                   continent == "Oceania" ~ "#beaed4",
                                                   continent == "South America" ~ "#fdc086",
                                                   continent == "Asia" ~ "#ffff99",
                                                   continent == "Europe" ~ "#386cb0",
                                                   continent == "North America" ~ "#f0027f"))

itol_geography <- itol_geography %>% select(wgs_id, color, continent)

#itol_geography %>% write_tsv("data/itol/itol_geography.txt")
