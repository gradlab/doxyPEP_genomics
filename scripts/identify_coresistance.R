library(tidyverse)
library(infer)
library(cowplot)
library(scales)

metadata_tet <- read_tsv("doxyPEP_QCpassing.tsv")
pheno_geno_errors <- read_tsv("itol_unexplained_susceptibility_resistance.txt")
metadata_tet <- metadata_tet %>% filter(!wgs_id %in% pheno_geno_errors$wgs_id)
metadata_tet_long <- metadata_tet %>% select(wgs_id, tetracycline_classify, ends_with("numeric")) %>% pivot_longer(ends_with("numeric"), names_to = "antibiotic", values_to = "mic")

metadata_tet_long <- metadata_tet_long %>%
  mutate(susceptible_breakpoint = case_when(
    antibiotic == "ceftriaxone_numeric" ~ 0.125,
    antibiotic == "azithromycin_numeric" ~ 1,
    antibiotic == "ciprofloxacin_numeric" ~ 0.25,
    antibiotic == "tetracycline_numeric" ~ 0.25,
    antibiotic == "penicillin_numeric" ~ 0.06),
    resistant_breakpoint = case_when(
      antibiotic == "ceftriaxone_numeric" ~ 0.125,
      antibiotic == "azithromycin_numeric" ~ 1,
      antibiotic == "ciprofloxacin_numeric" ~ 1,
      antibiotic == "tetracycline_numeric" ~ 2,
      antibiotic == "penicillin_numeric" ~ 2
    ),
    max_mic = case_when(
      antibiotic == "ceftriaxone_numeric" ~ 2,
      antibiotic == "azithromycin_numeric" ~ 256,
      antibiotic == "ciprofloxacin_numeric" ~ 64,
      antibiotic == "tetracycline_numeric" ~ 256,
      antibiotic == "penicillin_numeric" ~ 128
    ),
    min_mic = case_when(
      antibiotic == "ceftriaxone_numeric" ~ 0.0003,
      antibiotic == "azithromycin_numeric" ~ 0.008,
      antibiotic == "ciprofloxacin_numeric" ~ 0.001,
      antibiotic == "tetracycline_numeric" ~ 0.008,
      antibiotic == "penicillin_numeric" ~ 0.002
    ),
  )
global <- metadata_tet_long %>% 
  filter(antibiotic != "tetracycline_numeric") %>% 
  mutate(antibiotic = str_to_title(str_replace(antibiotic, "_numeric", ""))) %>%
  ggplot() + 
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = resistant_breakpoint, ymax = max_mic*2), fill = "grey50") +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = susceptible_breakpoint, ymax = resistant_breakpoint), fill = "grey90") +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = min_mic, ymax = susceptible_breakpoint), fill = "white") +
  geom_boxplot(aes(x = fct_relevel(tetracycline_classify, "I", after = 2), y = mic)) + 
  scale_y_continuous(trans = "log2", labels = label_number(accuracy = 0.001)) +
  facet_wrap(~antibiotic, scales = "free_y", ncol = 1) +
  xlab("Tetracycline") +
  ylab("MIC")+
  theme_cowplot(12) +
  theme(strip.background = element_rect(
    color="white", fill="white"),
    strip.text = element_text(
      size = 12, color = "black", face = "bold"
    ))



#GISP 2018
metadata_tet_reimche <- metadata_tet %>% filter(reference == "Reimche2021")

metadata_tet_reimche <- metadata_tet_reimche %>% select(wgs_id, qc, sexual_behavior, region, tetracycline_classify, ends_with("numeric"))

metadata_tet_reimche_long <- metadata_tet_reimche %>% pivot_longer(ends_with("numeric"), names_to = "antibiotic", values_to = "mic")

metadata_tet_reimche_long <- metadata_tet_reimche_long %>%
  mutate(susceptible_breakpoint = case_when(
  antibiotic == "ceftriaxone_numeric" ~ 0.125,
  antibiotic == "azithromycin_numeric" ~ 1,
  antibiotic == "ciprofloxacin_numeric" ~ 0.25,
  antibiotic == "tetracycline_numeric" ~ 0.25,
  antibiotic == "penicillin_numeric" ~ 0.06),
  resistant_breakpoint = case_when(
    antibiotic == "ceftriaxone_numeric" ~ 0.125,
    antibiotic == "azithromycin_numeric" ~ 1,
    antibiotic == "ciprofloxacin_numeric" ~ 1,
    antibiotic == "tetracycline_numeric" ~ 2,
    antibiotic == "penicillin_numeric" ~ 2
  ),
  max_mic = case_when(
    antibiotic == "ceftriaxone_numeric" ~ 2,
    antibiotic == "azithromycin_numeric" ~ 256,
    antibiotic == "ciprofloxacin_numeric" ~ 64,
    antibiotic == "tetracycline_numeric" ~ 256,
    antibiotic == "penicillin_numeric" ~ 128
  ),
  min_mic = case_when(
    antibiotic == "ceftriaxone_numeric" ~ 0.0003,
    antibiotic == "azithromycin_numeric" ~ 0.008,
    antibiotic == "ciprofloxacin_numeric" ~ 0.001,
    antibiotic == "tetracycline_numeric" ~ 0.008,
    antibiotic == "penicillin_numeric" ~ 0.002
  ),
)
us <- metadata_tet_reimche_long %>% 
  filter(antibiotic != "tetracycline_numeric") %>% 
  mutate(antibiotic = str_to_title(str_replace(antibiotic, "_numeric", ""))) %>%
  ggplot() + 
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = resistant_breakpoint, ymax = max_mic*2), fill = "grey50") +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = susceptible_breakpoint, ymax = resistant_breakpoint), fill = "grey90") +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = min_mic, ymax = susceptible_breakpoint), fill = "white") +
  geom_boxplot(aes(x = fct_relevel(tetracycline_classify, "I", after = 2), y = mic)) + 
  scale_y_continuous(trans = "log2", labels = label_number(accuracy = 0.001)) +
  facet_wrap(~antibiotic, scales = "free_y", ncol = 1) +
  xlab("Tetracycline") +
  ylab("MIC") +
  theme_cowplot(12) +
  theme(strip.background = element_rect(
    color="white", fill="white"),
    strip.text = element_text(
      size = 12, color = "black", face = "bold"
    ))

p1 <- plot_grid(global, us, labels = c('A', 'B'), label_size = 12)
ggsave("doxyPEP_coresistance.pdf", p1, units = "mm", width = 183, height = 183)

# significance tests (p value threshold for significance p < 0.002)
wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("HL-R", "R")))

wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("HL-R", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("HL-R", "R")))

wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("I", "R")))

wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("I", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("I", "R")))

wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet %>% filter(tetracycline_classify %in% c("S", "R")))

wilcox.test(azithromycin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(ceftriaxone_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(ciprofloxacin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("S", "R")))
wilcox.test(penicillin_numeric ~ tetracycline_classify, data=metadata_tet_reimche %>% filter(tetracycline_classify %in% c("S", "R")))

# co-resistance determinants in reimche dataset

metadata_tet_reimche %>% filter(tetracycline_classify %in% c("R", "HL-R")) %>%
  count(azithromycin_classify, tetM)
metadata_tet_reimche %>% filter(tetracycline_classify %in% c("R", "HL-R")) %>%
  count(ciprofloxacin_classify, tetM)


