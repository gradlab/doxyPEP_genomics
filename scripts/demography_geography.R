library(tidyverse)
library(cowplot)
library(scales)

gisp2018 <- read_tsv("gisp2018_QCpassing_resistance_alleles.tsv")
pheno_geno_errors <- read_tsv("itol_unexplained_susceptibility_resistance.txt")
gisp2018 <- gisp2018 %>% filter(!wgs_id %in% pheno_geno_errors$wgs_id)

#combine data from HHS regions
gisp2018 <- gisp2018 %>%
  separate(region, c("region", "subregion"), sep = "-")

#summarize tetracycline resistance across regions
region_resistance <- gisp2018 %>%
  count(region, tetracycline_classify) %>% 
  pivot_wider(names_from = "tetracycline_classify",
              values_from = "n") %>%
  mutate(all_resistance = `HL-R` + R,
         total = `HL-R` + R + I + S,
         resistant_proportion = all_resistance/total,
         resistant_percent = percent(resistant_proportion))

p1 <- gisp2018 %>% 
  ggplot() +
  scale_fill_brewer(palette = "Greys", name = "") +
  geom_bar(aes(x=fct_relevel(region, "10", after = Inf), fill = fct_reorder(tetracycline_classify, tetracycline_numeric)), color = "black", size = 0.25) +
  xlab("HHS Region") +
  ylab("Number of High Quality Genomes") +
  geom_text(data = region_resistance, aes(x=region, y=total+10, label=percent(resistant_proportion, accuracy = 0.1)))+
  theme_half_open()

ggsave("tet_resistance_regions.pdf", p1, width = 178, height = 106, units = "mm")

gisp2018 %>% 
  count(sexual_behavior, tetracycline_classify) %>%
  group_by(sexual_behavior) %>%
  mutate(percent = 100*n/sum(n)) %>%
  pivot_wider(id_cols = sexual_behavior, names_from = tetracycline_classify, values_from = c("n", "percent"))
