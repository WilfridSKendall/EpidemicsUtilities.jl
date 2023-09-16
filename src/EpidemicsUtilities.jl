# ---
# title:  "EpidemicsUtilities module documentation"
# author: "Wilfrid Kendall"
# date: today
# date-format: D MMMM YYYY
# ---
# 
# ---
# papersize:  a4
# 
# execute:
#   eval: false
# format:
#   html:
#     toc: true
#     toc-depth: 2
#     code-fold: true
#     self-contained: true
#   pdf:
#     link-citations: true
#     numbersections: true
#     mainfont: "Times New Roman"
#     monofont: "JuliaMono"
#     monofontoptions:
#        - Scale=0.7
# jupyter:    julia-1.9
# ---
#
# \newcommand{\SIR}{\operatorname{S-I-R}}
# ::: {.callout-note}
# # This documentation was produced using the following versions:
# ```{julia}
# #| echo: false
# #| eval: true
# #| cache: false
# import Markdown, EpidemicsCFTP, EpidemicsUtilities
# Markdown.parse("""
# | Module                | Version                         | Branch                         |
# |:----------------------|:--------------------------------|-------------------------------:|
# | `julia`               | `$VERSION`                      |                                |
# | `EpidemicsUtilities`  | `$(EpidemicsUtilities.version)` | `$(EpidemicsUtilities.branch)` |
# | `EpidemicsCFTP`       | `$(EpidemicsCFTP.version)`      | `$(EpidemicsCFTP.branch)`      |
# """)
# ```
# :::
#
# The `EpidemicsUtilities` package
# ================================
# The controlling script for this package is  `EpidemicsUtilities.jl`.
module EpidemicsUtilities
loc     = dirname(dirname(pathof(EpidemicsUtilities)))
version = "$(read(Cmd(`git describe --tags`, dir=loc), String)[1:end-1])"
branch  = "$(read(Cmd(`git branch --show-current`, dir=loc), String)[1:end-1])"
#
# The functions defined in this module are aimed at
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
# ### Deco[rations] and colours
# Sub-script `02-Deco.jl` defines the function `load_deco`, 
# loading `YAML` data to specify a `deco` structure,
# and the function `create_deco`, using these data to create (and return) a `deco`[ration].
export load_deco, create_deco
#
# ### Template for plots
# Sub-script `03-Template.jl` defines a function `scaffolding`
# to draw the time axis and time-lines.
# thus providing a basic template for most of the simulation plots. 
export scaffolding
# ::: {.callout-tip}
# Note that much of this might be better provided by `Gadfly` functions.
# :::
#
# ### `Gadfly` drawing Functions
# Sub-script `04-Gadfly.jl` defines specific drawing functions using the `Gadfly` plot package.
# These functions do _not_ use the template produced by `scaffolding` from `03-Template.jl`.
export table_trajectories, plot_trajectories
# ::: {.callout-tip}
# See previous tip concerning possibility of using `Gadfly` for axes and coordinates.
# :::
#
# ### Drawing nodes
# Sub-script `05-Nodes.jl` defines three functions to draw sets of incidents.
export draw_incident, draw_elements, draw_realized_elements
#
# ### Drawing trajectories
# Sub-script `06-Trajectories.jl` currently defines no exported functions.
#
# ### Drawing zones
# Sub-script `07-Zones.jl` defines functions which (for now) are used only in `experiment.qmd`.
export compute_total_trajectory, region_plot

# ### Graphics outputs
# Sub-script `08-Outputs.jl` defines  
# a function `create_nodes_view` to draw nodes and connectors 
# relating to a simulation, using functions defined in `05-Nodes.jl`,
# and a function `create_epidemic_view`, additionally using functions defined in 
# `06-Trajectories.jl` and `07-Zones.jl`
# to draw an entire epidemic.
export create_nodes_view, create_epidemic_view
# It also defines
# a convenient drawing function  `depict`, creating `PNG` and `PDF` variants of a figure.
export depict

# Imports
# -------
# The module also imports the following `julia` modules. 
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly

# The ability to read `YAML` files facilitates configuration of deco[rations] (see `02-Deco.jl`).
import YAML

# The associated module `EpidemicsCFTP` is currently under development
# (therefore should be added using `dev EpidemicsCFTP`).
using EpidemicsCFTP 

# List of included scripts
# ------------------------
include("02-Deco.jl")
include("03-Template.jl")
include("04-Gadfly.jl")
include("05-Nodes.jl")
include("06-Trajectories.jl")
include("07-Zones.jl")
include("08-Outputs.jl")

# This concludes the module.
end
