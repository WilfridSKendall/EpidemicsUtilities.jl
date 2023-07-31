# ---
# title:  "EpidemicsUtilities module"
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
#
# The `EpidemicsUtilities` package
# ================================
# The controlling script for this package is  `EpidemicsUtilities.jl`, 
# which defines the module `EpidemicsUtilities` which implements the package.
module EpidemicsUtilities
# This module `EpidemicsUtilities` defines functions 
# which enable construction of illustration of simulations for
# $\SIR$ epidemics conditioned on removals being observed.

# Exports
# -------
# This section lists the various exports of the module `EpidemicsUtilities`,
# in sub-sections corresponding to the sub-scripts in which the exports are defined.
#
# ### Styles and colours
# The sub-script `02-Styles.jl` defines `load_style`, loading `YAML` data for the `default_style` structure,
# and `create_style`, using these data to create (and return) a style.
export load_style, create_style

# ### Template for plots
# The sub-script `03-Template.jl` defines a function `scaffolding`
# to draw the time axis and time-lines.
# thus providing a basic template for most of the simulation plots. 
export scaffolding

# ### `Gadfly` drawing Functions
# The sub-script `04-Gadfly.jl` defines specific drawing functions which use `Gadfly`
# rather than the template produced by `scaffolding` from `03-Template.jl`.
export table_trajectories, plot_trajectories

# ### Drawing nodes
# The sub-script `05-Nodes.jl` defines the function `create_nodes_view` to draw nodes and connectors 
# relating to the simulations.
export create_nodes_view
# Three further functions are used only in `experiment.qmd`.
export draw_incident, draw_elements, draw_realized_elements

# ### Drawing trajectories
# The sub-script `06-Trajectories.jl` defines no exported functions.

# ### Drawing zones
# The sub-script `07-Zones.jl` defines functions which (for now) are used only in `experiment.qmd`.
export compute_total_trajectory
export region_plot

# ### Graphics utilities
# The sub-script `08-Utility.jl` defines  
# an exported function `create_epidemic_view`, using functions defined in 
# `06-Trajectories.jl` and `07-Zones.jl`
# to draw an entire epidemic.
export create_epidemic_view
# It also defines
# a convenient exported drawing function  `depict`, creating `PNG` and `PDF` variants of a figure.
export depict

# Imports
# -------
# The module `EpidemicsUtilities` requires import of a number of other modules as follows. 
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly

# The `subtypes` function from `InteractiveUtils` is required
# in order to construct the `BasicIncident` type (see `02-Styles.jl`).
using InteractiveUtils 

# The ability to read `YAML` files allows easier configuration of styles 
# more easily (see `02-Styles.jl`).
import YAML

# The associated `EpidemicsCFTP` is a module currently under development
# (therefore added using `dev EpidemicsCFTP` .
using EpidemicsCFTP 

# List of included scripts
# ------------------------
include("02-Styles.jl")
include("03-Template.jl")
include("04-Gadfly.jl")
include("05-Nodes.jl")
include("06-Trajectories.jl")
include("07-Zones.jl")
include("08-Utility.jl")

# This concludes the module.
end
