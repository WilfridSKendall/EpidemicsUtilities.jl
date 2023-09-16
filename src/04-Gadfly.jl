# Plotting functions using the plot package `Gadfly` (`04-Gadfly.jl`)
# ===================================================================
# `Gadfly`-based functions, respectively `table_trajectories`
# and `plot_trajectories`^[The functions `table_trajectories` and `plot_trajectories` are **exported**.],
# construct and plot a dataframe
# of trajectories as knots of piecewise constant functions, having used
# `EpidemicsCFTP.evolution`
# to deliver the \(\SIR\) trajectory `trajectory`
# and a sorted list of realized incidents in `realized`.
function table_trajectories(duration, initial, trajectory)
  states = [initial]
  t = [state.t for state in trajectory] ; push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in trajectory], inner=2)
  i = repeat([state.i for state in trajectory], inner=2)
  r = repeat([state.r for state in trajectory], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

# For the next function `plot_trajectories`, 
# the argument `flow` is a `DataFrame` of the form computed by `table_trajectories` above.
# Note that `plot_trajectories` uses the `julia` plotting package `Gadfly`.
function plot_trajectories(flow; deco=default_deco)
  gf = Gadfly
  infection_layer   = gf.layer(flow, x=:t, y=:Infectives, color=[sty.colour(Infection(0.0,1,2))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  removal_layer     = gf.layer(flow, x=:t, y=:Removals, color=[sty.colour(Removal(0.0, 1))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  susceptible_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[sty.scaffold], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(susceptible_layer, removal_layer, infection_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"), 
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end
