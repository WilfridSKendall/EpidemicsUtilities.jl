# ---
# title:  "EpidemicsUtilities module"
# author: "Wilfrid Kendall"
# date: 24/07/2023
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
# `EpidemicsUtilities` module
# ===========================
module EpidemicsUtilities
# This module holds functions to help illustrate simulation for
# $\SIR$ epidemics conditioned on removals being observed.

# Exports
# -------

# ### Compose drawing functions
# A convenient drawing function to create `PNG` and `PDF` variants of a figure.
export depict

# A function to draw the time axis and time-lines. 
export scaffolding

# Functions to draw nodes and regions and connectors.
export create_nodes_view, create_epidemic_view

# (Used only in `experiment.qmd`.)
export draw_incident, draw_elements, draw_realized_elements

# ### `Gadfly` drawing Functions
# Specific `Gadfly` drawing functions
export trajectory_table, plot_trajectories

# ## Further drawing functions using markers.
# (Used only in `experiment.qmd`.)
export compute_total_trajectory
export region_plot

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

# Included files
# --------------
include("01-EpidemicsUtilitiesFunctions.jl")

# Conclusion of module.
end
