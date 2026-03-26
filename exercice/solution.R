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
    filename = here("exercice", "output", "exercice_1.png"),
    plot = exo_1,
    device = ragg::agg_png
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

exo_3 <- camille_total |>
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
exo_3

ggsave(
    filename = here("exercice", "output", "exercice_3.png"),
    plot = exo_3,
    device = ragg::agg_png
)

## Reprise avec légende séparée pour les
## Test suite à question en séance du 2026-03-25

camille_total |>
    mutate(agregat = sexe == "Total") |>
    mutate(label = paste0(sexe, agregat)) |>
    ggplot(aes(x = annais, y = nombre, color = sexe, linetype = agregat)) +
    geom_line() +
    scale_color_manual(
        name = "Sexe",
        values = c(
            "Filles" = "green",
            "Garçons" = "purple",
            "Total" = "orange"
        ),
    ) +
    scale_linetype_manual(
        name = "Sexe", # même "name" que color fusionne les légendes
        values = c("dashed", "solid", "solid")
    )

# Exo 3' : ajouter accessibilité (Okabe), markdown et labels ---------------------------

# Palette de couleur Okabe
# https://wilkelab.org/SDS375/slides/color-scales.html#1
# https://clauswilke.com/dataviz/color-pitfalls.html#fig:palette-Okabe-Ito

okabe <- c4a("misc.okabe", n = 3)
# "#E69F00" "#56B4E9" "#009E73"
colorspace::specplot(okabe)

exo_3bis <-
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
exo_3bis

ggsave(
    filename = here("exercice", "output", "exercice_3bis.png"),
    plot = exo_3bis,
    device = ragg::agg_png
)

# Exo 4 : nouvelles représentations en colonnes et patchwork ------------------

exo_4_p1 <- camille_total |>
    filter(sexe != "Total") |>
    ggplot(aes(x = annais, weight = nombre, fill = sexe)) +
    geom_bar(position = "fill", show.legend = FALSE) +
    scale_fill_discrete_c4a_cat("misc.okabe", name = "Genre") +
    scale_y_continuous(labels = scales::percent) +
    labs(
        y = "Proportion",
        x = NULL
    ) +
    theme(
        plot.title = element_markdown()
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne"
    )
exo_4_p1

exo_4_p2 <- camille_total |>
    filter(sexe != "Total") |>
    ggplot(aes(x = annais, weight = nombre, fill = sexe)) +
    geom_bar(show.legend = FALSE) +
    scale_fill_discrete_c4a_cat("misc.okabe", name = "Genre") +
    scale_y_continuous(
        labels = scales::label_number(big.mark = " ", decimal.mark = ",")
    ) +
    labs(
        y = "Effectif",
        x = NULL
    ) +
    theme(
        plot.title = element_markdown()
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne"
    )
exo_4_p2

#  "#E69F00" "#56B4E9" "#009E73"

exo_4_title <- "Effectifs et proportions <i style='color:#E69F00'>Filles</i> et <i style='color:#56B4E9'>Garçons</i> pour le prénom \"_Camille_\" depuis 2000"

exo_4 <- (exo_4_p2 + exo_4_p1) +
    plot_annotation(
        title = exo_4_title,
        theme = theme(
            legend.position = "bottom",
            plot.title = element_markdown()
        )
    )
exo_4

ggsave(
    filename = here("exercice", "output", "exercice_4.png"),
    plot = exo_4,
    device = ragg::agg_png
)

# Exo 5 : facettes sur plusieurs prénoms épincènes ------------------

prenoms_epicenes <- tribble(
    ~prenom     ,
    "Camille"   ,
    "Dominique" ,
    "Claude"    ,
    "Noa"
)

exo_5_data <- prenoms |>
    semi_join(prenoms_epicenes, by = join_by(prenom)) |>
    filter(annais |> between(1950, 2020)) |>
    summarise(nombre = sum(nombre), .by = c(prenom, annais, sexe)) |>
    bind_rows(
        prenoms |>
            semi_join(prenoms_epicenes, by = join_by(prenom)) |>
            filter(annais |> between(1950, 2020)) |>
            summarise(nombre = sum(nombre), .by = c(prenom, annais)) |>
            mutate(sexe = "T")
    )

exo_5_labels <- c("F" = "Filles", "G" = "Garçons", "T" = "Total")
exo_5_linetypes <- c("F" = "dashed", "G" = "dashed", "T" = "solid")

exo_5 <- exo_5_data |>
    ggplot(aes(x = annais, y = nombre)) +
    geom_line(aes(color = sexe, linetype = sexe)) +
    scale_linetype_manual(
        name = "Genre",
        values = exo_5_linetypes,
        labels = exo_5_labels
    ) +
    scale_color_discrete_c4a_cat(
        palette = "misc.okabe",
        name = "Genre",
        labels = exo_5_labels
    ) +
    labs(
        y = "Effectif",
        x = "Année",
        title = "Effectif par genre sur la période 1950-2000",
        subtitle = "Source https://ssm-agriculture.github.io/"
    ) +
    theme(
        strip.background = element_rect(
            fill = NA,
            color = NA
        )
    ) +
    theme_hc(
        base_size = 14,
        base_family = "Marianne",
    ) +
    facet_wrap(~prenom, scales = "free_y")
exo_5

ggsave(
    filename = here("exercice", "output", "exercice_5.png"),
    plot = exo_5,
    device = ragg::agg_png
)
