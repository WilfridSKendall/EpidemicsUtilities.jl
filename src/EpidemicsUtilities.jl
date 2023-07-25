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
# The controlling script for the `EpidemicsUtilities` package
# ===========================================================
module EpidemicsUtilities
# This module holds functions to help illustrate simulation for
# $\SIR$ epidemics conditioned on removals being observed.

# Exports
# -------

# ### [`EpidemicsUtilities`]
# This section defines no functions or other entities. 

# ### Template for plots [`03-Template.jl`]
# A function to draw the time axis and time-lines. 
export scaffolding

# ### `Gadfly` drawing Functions [`04-Gadfly.jl`]
# Specific `Gadfly` drawing functions
export table_trajectories, plot_trajectories

# ### Drawing nodes [`05-Nodes.jl`]
# Functions to draw nodes and connectors:
export create_nodes_view
# and (used only in `experiment.qmd`)
export draw_incident, draw_elements, draw_realized_elements

# ### Drawing trajectories [`06-Trajectories.jl`]
# No exports from this section.

# ### Drawing zones [`07-Zones.jl`]
# These functions are used only in `experiment.qmd`.
export compute_total_trajectory
export region_plot

# ### Graphics utilities [`08-Utility.jl`]
# This section defines 
# an exported function `create_epidemic_view` which uses functions defined in 
# `06-Trajectories.jl` and `07-Zones.jl`
# to draw an entire epidemic;
export create_epidemic_view
# and also defines `depict`,
# a convenient exported drawing function which creates `PNG` and `PDF` variants of a figure.
export depict

# Imports
# -------
# This module requires import of a number of other modules as follows. 
# Note that we introduce a prefix for `Gadfly`, to avoid excessive name-space pollution.
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly
gf = Gadfly ; 

# The next module is required in order to access the `subtypes` function.
using InteractiveUtils 

# The associated `EpidemicsCFTP` is a module currently under development,
# so has to be added using `dev EpidemicsCFTP`.
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
