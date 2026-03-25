# Formation R-Graphique

## Introduction

### Tour de table

- Marie-Christine BOIS (SRISE GES) : potentiel de R, n'a pas pratiqué, acculturation de son équipe (PED)
- Gérald PETIT (SDSSR/BSPCA) : fait des tableaux, mais pas de graphique. E.g., refaire des graphiques du GraphAgri
- Sébastien RAULO (SDSSR/BSSC) : léger sur R, pas de graphique
- Isabelle DEJEAN (DRAAF OCC) : doit reprendre du code tiers
- Tristan COLAS (SDSSR/BSPCA) : R régulier, graphique avec IA, "bachotage" de l'API
- Lucas ETCHEVERS (SRISE 971) : valorisation sous R, graphiques sous Excel : personnaliser
- Stéphanie HERANT (???) : débutant, ne plus passer par Excel
- Marie RAYMOND (SRISE GES) : (retard)

### Avantages `ggplot2`

- rester dans le même outil
- reproductible
- automatiser

### Discussion

Passer cartographie en `ggplot2` pour la cohérence inter-module ?

## Contenu

- <https://dreamrs.github.io/esquisse/> comme GUI `ggplot2`
- pas assez d'insistance sur le concept de _mapping_ entre données et géométries via les _aes_, le _mapping_ (dont _scale_ définit la fonction).
- exemples à (pré)voir dans la présentation ou en exercice
  - `coord_flip` et comparer à l'effet de l'inversion des axes x et y
  - `geom_density`
  - `stat_summary` pour ajouter une moyenne sur un _boxplot_
  
### Gotchas

- Pour la fusion de légende, on doit avoir le même _nom_ **et** les mêmes labels conceptuellement, on change le `linetype`

### Grammaire

> Extrait de <https://r-graphics.org/some-terminology-and-theory.html>.
>
> Before we go any further, it'll be helpful to define some of the terminology used in `ggplot2`:
>
> - **The** data is what we want to visualize. It consists of variables, which are stored as columns in a data frame.
> - **Geoms** are the geometric objects that are drawn to represent the data, such as bars, lines, and points.
> - **Aesthetic** attributes, or aesthetics, are visual properties of geoms, such as x and y position, line color, point shapes, etc.
> - There are **mappings** from data values to aesthetics.
> - **Scales** control the mapping from the values in the data space to values in the aesthetic space. A continuous y scale maps larger numerical values to vertically higher positions in space.
> - **Guides** show the viewer how to map the visual properties back to the data space. The most commonly used guides are the tick marks and labels on an axis.
