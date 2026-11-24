# ---
# title:  "EpidemicsUtilities module documentation"
# author: "Wilfrid Kendall"
# date: today
# date-format: D MMMM YYYY
# 
# papersize:  a4
#
# from: markdown+tex_math_single_backslash
# 
# execute:
#   eval: false
# format:
#   html:
#     toc: true
#     toc-depth: 1
#     code-fold: true
#     self-contained: true
#   pdf:
#     link-citations: true
#     numbersections: true
#     mainfont: "Times New Roman"
#     monofont: "JuliaMono"
#     monofontoptions:
#        - Scale=0.7
#
# engine:    julia
# ---
#
# \newcommand{\SIR}{\operatorname{S-I-R}}
#
# ::: {.callout-note}
# # This documentation was produced using the following versions:
# ```{julia}
# #| echo: false
# #| eval: true
# #| cache: false
# import Markdown, EpidemicsCFTP, EpidemicsUtilities
# Markdown.parse("""
# |_Software_           |_Version_                       | _Branch_                    | _Last commit_       |
# |:---------------------|:------------------------------|:-----------------------------|:---------------------------|
# |`julia` version     |`$VERSION`                     | ---                          |                             |
# |`EpidemicsUtilities`|`$(EpidemicsUtilities.version)`|`$(EpidemicsUtilities.branch)`| $(EpidemicsUtilities.date)|
# |`EpidemicsCFTP`     |`$(EpidemicsCFTP.version)`     |`$(EpidemicsCFTP.branch)`     | $(EpidemicsCFTP.date)   |
# """)
# ```
# :::
#
# The `EpidemicsUtilities` package
# ================================
# The controlling script for this package is  `EpidemicsUtilities.jl`.
module EpidemicsUtilities
loc = dirname(dirname(pathof(EpidemicsUtilities)))
version = "$(read(Cmd(`git describe --tags`, dir=loc), String)[1:end-1])"
branch  = "$(read(Cmd(`git branch --show-current`, dir=loc), String)[1:end-1])"
date    = replace(split(read(Cmd(`git log -1`, dir=loc), String), "\n")[3], 
                "Date:   " => "", " +0000" => "")
summary = "EpidemicsUtilities version $version checked in on $date"
#
# The functions defined in this module are intended for
# construction of illustration of simulations for
# $\SIR$ epidemics when conditioned on removals being observed.

# Exports
# -------
# Here are the various module exports:
# sub-sections correspond to relevant sub-scripts.
#
# ### Controlling script
# The controlling script `EpidemicsUtilities.jl` exports objects but does not directly define them.
#
# ### Themes and colours
# Sub-script `02-Theme.jl` defines the function `load_theme`, 
# loading `YAML` data to specify a `theme` structure,
# and the function `create_theme`, using these data to create (and return) a `theme`.
export load_theme, create_theme
# Also exporting some functions for use in axis labelling.
export timelinelabels_circled, timelinelabels_bracketed, timelinelabel_raw
#
# ### `DataFrames` Functions
# Sub-script `03-DataFrames.jl` defines functions producing data frames to be used in `Gadfly` plot package.
export table_trajectories1, table_trajectories2, prepare_screen
#
# ### Drawing nodes
# Sub-script `04-Nodes.jl` defines three functions to draw sets of incidents.
export draw_incident, draw_connect, draw_feasible_incident
export draw_elements, draw_activated_elements
# and also three functions to plot higher-level quantities on `template`s.
export draw_regions!, draw_innovation!, draw_evolution!
#
# ### Graphics output
# Sub-script `05-Outputs.jl` defines  
# convenient drawing functions
#
# (a) `depict`, creating `PNG` and `PDF` variants of a figure,
# (b) also `new_figure`, allowing assembly of a list of `Gadfly` constructs into a single figure.
export depict, new_figure

# Imports
# -------
# The module also imports the following `julia` modules:
#
# (a) Availability of related modules.
using Colors, Compose, Measures
import Cairo, Fontconfig
import InteractiveUtils: subtypes
import Gadfly: Coord, Geom, Guide, Plot, Scale, Theme, plot, layer, style
# The following two packages are used in `03-DataFrames.jl` by `table_trajectories4`.
import Impute, ShiftedArrays
#
# (b) The ability to use `DataFrame` constructions
using DataFrames
#
# (c) The ability to read `YAML` files facilitates configuration of theme[rations] (see `02-Theme.jl`).
import YAML
#
# The resulting module `EpidemicsCFTP` is currently under development
# (therefore should be added using `dev EpidemicsCFTP`).
using EpidemicsCFTP

# List of included scripts
# ------------------------
include("02-Theme.jl")
include("03-DataFrames.jl")
include("04-Nodes.jl")
include("05-Outputs.jl")

# This concludes the module.
end
