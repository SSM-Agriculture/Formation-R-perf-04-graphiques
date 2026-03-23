# 1. Tracer la courbe de l’évolution du nombre de naissances de Camille depuis 2000.
#    Choisir une largeur de ligne de 1 et colorer la courbe en orange.
# 2. Tracer la courbe de l'évolution du nombre de naissances de « Camille » selon le sexe de l’enfant.
# 3. Pour aller plus loin : ajouter au graphique la courbe représentant le total (F+G)
#    et mettre en pointillés les deux autres courbes.

# résultat attendu - exercice 1 :  voir img/clipboard-exercice1.png

library(here)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(ggplot2)
library(ggtext)
library(ggthemes)
library(ggrepel)
library(patchwork)
library(cols4all)

# Données ---------------------------------------------------------------------

# Do once
# prenoms <- read_rds(here("exercice", "data", "prenoms.rds")) |>
#     mutate(annais = as.integer(annais))
# arrow::write_parquet(prenoms, here("exercice", "data", "prenoms.parquet"))

prenoms <- arrow::read_parquet(here("exercice", "data", "prenoms.parquet"))
prenoms

camille_annee <- prenoms |>
    filter(str_to_title(prenom) == "Camille" & annais >= 2000) |>
    summarise(nombre = sum(nombre), .by = annais)

# Exo 1 -----------------------------------------------------------------------

exo_1 <- camille_annee |>
    ggplot(aes(x = annais, y = nombre)) +
    geom_line(color = "orange", lwd = 1) +
    theme_clean()
exo_1

ggsave(
    here("exercice", "output", "exercice_1.png"),
    plot = exo_1,
    device = ragg::agg_png()
)

# Exo 2 & 3 -------------------------------------------------------------------

# Nombre de Camille par genre + calcul du total
camille_total <- prenoms |>
    filter(str_to_title(prenom) == "Camille" & annais >= 2000) |>
    summarise(nombre = sum(nombre), .by = c(sexe, annais)) |>
    mutate(
        sexe = case_match(
            sexe,
            "G" ~ "Garçons",
            "F" ~ "Filles"
        )
    ) |>
    bind_rows(
        camille_annee |> mutate(sexe = "Total")
    )

camille_total |>
    ggplot(aes(x = annais, y = nombre)) +
    geom_line(aes(color = sexe, linetype = sexe)) +
    scale_color_manual(
        name = "Genre",
        values = c(
            "Filles" = "green",
            "Garçons" = "purple",
            "Total" = "orange"
        ),
    ) +
    scale_linetype_manual(
        name = "Genre", # même "name" que color fusionne les légendes
        values = c(
            "Filles" = "dashed",
            "Garçons" = "dashed",
            "Total" = "solid"
        ),
    ) +
    labs(
        y = "Effectif",
        x = "Année",
        title = "Effectif par genre pour le prénom Camille depuis 2000",
        subtitle = "Source https://ssm-agriculture.github.io/"
    ) +
    theme_hc(base_size = 14, base_family = "Marianne")


ggsave(
    here("exercice", "output", "exercice_3.png"),
    plot = get_last_plot(),
    device = ragg::agg_png()
)

# Exo 3' : accessibilité (Okabe), markdown et label ---------------------------

# Palette de couleur Okabe
# https://wilkelab.org/SDS375/slides/color-scales.html#1
# https://clauswilke.com/dataviz/color-pitfalls.html#fig:palette-Okabe-Ito

okabe <- c4a("misc.okabe", n = 3)
colorspace::specplot(okabe)

camille_total |>
    ggplot(aes(x = annais, y = nombre)) +
    geom_line(aes(color = sexe, linetype = sexe), show.legend = FALSE) +
    geom_point(
        data = camille_total |> filter(annais == max(annais)),
        mapping = aes(color = sexe),
        show.legend = FALSE
    ) +
    geom_text(
        data = camille_total |> filter(annais == max(annais)),
        mapping = aes(
            colour = sexe,
            label = sexe
        ),
        show.legend = FALSE,
        vjust = -0.25,
        position = position_identity(),
        hjust = "outward"
    ) +
    scale_color_discrete_c4a_cat("misc.okabe") +
    # scale_color_colorblind() +
    scale_linetype_manual(
        name = "Genre", # même "name" que color fusionne les légendes
        values = c(
            "Filles" = "dashed",
            "Garçons" = "dashed",
            "Total" = "solid"
        ),
    ) +
    coord_cartesian(xlim = c(2000, 2022), clip = "off") +
    labs(
        y = "Effectif",
        x = "Année",
        title = "Effectif par genre pour le prénom \"_Camille_\" depuis 2000",
        subtitle = "Source https://ssm-agriculture.github.io/"
    ) +
    theme(
        plot.title = element_markdown()
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne"
    )

ggsave(
    here("exercice", "output", "exercice_3bis.png"),
    plot = get_last_plot(),
    device = ragg::agg_png()
)

# Exo 4 : pourcentage et patchwork --------------------------------------------

p1 <- camille_total |>
    filter(sexe != "Total") |>
    ggplot(aes(x = annais, weight = nombre, fill = sexe)) +
    geom_bar(position = "fill") +
    scale_fill_discrete_c4a_cat("misc.okabe", name = "Genre") +
    labs(
        y = "Proportion",
        x = NULL,
        # title = "Répartition de genre pour le prénom \"_Camille_\" depuis 2000",
        # subtitle = "Source https://ssm-agriculture.github.io/"
    ) +
    theme(
        plot.title = element_markdown()
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne"
    )
p1

p2 <- camille_total |>
    filter(sexe != "Total") |>
    ggplot(aes(x = annais, weight = nombre, fill = sexe)) +
    geom_bar() +
    scale_fill_discrete_c4a_cat("misc.okabe", name = "Genre") +
    labs(
        y = "Effectif",
        x = NULL,
        # title = "Répartition de genre pour le prénom \"_Camille_\" depuis 2000",
        # subtitle = "Source https://ssm-agriculture.github.io/"
    ) +
    theme(
        plot.title = element_markdown()
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne"
    )
p2

(p2 + p1) +
    plot_annotation(
        title = "Répartition et effectif par genre pour le prénom \"_Camille_\" depuis 2000",
        theme = theme(
            legend.position = "bottom",
            plot.title = element_markdown()
        )
    ) +
    plot_layout(guides = "collect")


ggsave(here("exercice", "output", "exercice_4.png"), device = ragg::agg_png())
