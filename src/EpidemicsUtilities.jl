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
# which defines the module `EpidemicsUtilities`.
module EpidemicsUtilities
# This module `EpidemicsUtilities` defines functions 
# which enable construction of illustration of simulations for
# $\SIR$ epidemics conditioned on removals being observed.

# The current version is `0.1.2.11` on branch `main`.
version = "$(read(`git describe --tags`, String)[1:end-1])"
branch  = "$(read(`git branch --show-current`, String)[1:end-1])"

# Exports
# -------
# This section lists the various exports of the module `EpidemicsUtilities`,
# in sub-sections corresponding to the sub-scripts in which the exports are defined.
#
# ### Controlling script
# The controlling script `EpidemicsUtilities.jl` exports objects but does not directly define them.
#
# ### Styles and colours
# The sub-script `02-Styles.jl` defines the function `load_style`, 
# which loads `YAML` data for a `style` structure,
# and the function `create_style`, which uses these data to create (and return) a `style`.
export load_style, create_style

# ### Template for plots
# The sub-script `03-Template.jl` defines a function `scaffolding`
# to draw the time axis and time-lines.
# thus providing a basic template for most of the simulation plots. 
export scaffolding

# ### `Gadfly` drawing Functions
# The sub-script `04-Gadfly.jl` defines specific drawing functions which use the `Gadfly` plot package.
# These functions do _not_ use the template produced by `scaffolding` from `03-Template.jl`.
export table_trajectories, plot_trajectories

# ### Drawing nodes
# The sub-script `05-Nodes.jl` defines three functions to draw sets of incidents.
export draw_incident, draw_elements, draw_realized_elements

# ### Drawing trajectories
# The sub-script `06-Trajectories.jl` defines no exported functions.

# ### Drawing zones
# The sub-script `07-Zones.jl` defines functions which (for now) are used only in `experiment.qmd`.
export compute_total_trajectory
export region_plot

# ### Graphics outputs
# The sub-script `08-Outputs.jl` defines  
# a function `create_nodes_view` to draw nodes and connectors 
# relating to a simulation, using functions defined in `05-Nodes.jl`,
export create_nodes_view
# and a function `create_epidemic_view`, additionally using functions defined in 
# `06-Trajectories.jl` and `07-Zones.jl`
# to draw an entire epidemic.
export create_epidemic_view
# It also defines
# a convenient drawing function  `depict`, creating `PNG` and `PDF` variants of a figure.
export depict

# Imports
# -------
# The module `EpidemicsUtilities` imports of the following modules. 
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly

# The ability to read `YAML` files facilitates configuration of styles (see `02-Styles.jl`).
import YAML

# The associated module `EpidemicsCFTP` is currently under development
# (therefore is added using `dev EpidemicsCFTP`).
using EpidemicsCFTP 

# List of included scripts
# ------------------------
include("02-Styles.jl")
include("03-Template.jl")
include("04-Gadfly.jl")
include("05-Nodes.jl")
include("06-Trajectories.jl")
include("07-Zones.jl")
include("08-Outputs.jl")

# This concludes the module.
end
