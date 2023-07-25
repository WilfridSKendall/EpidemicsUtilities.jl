#
#
# Drawing functions using `Gadfly` [`04-Gadfly.jl`]
# =================================================
# Define `Gadfly`-based functions,
# respectively `table_trajectories`
# and `plot_trajectories`^[The functions `table_trajectories` and `plot_trajectories` are **exported**.],
# to construct and plot a dataframe
# of trajectories as knots of piecewise constant functions, having used `evolution`
# to deliver the \(\SIR\) trajectory `traj`
# as well as a sorted list of realized incidents in `realized`.
function table_trajectories(duration, initial, traj)
  states = [initial]
  t = [state.t for state in traj] ; push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in traj], inner=2)
  i = repeat([state.i for state in traj], inner=2)
  r = repeat([state.r for state in traj], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

# For the next function, 
# the argument `flow` is a `DataFrame` of the form computed by `table_trajectories` above.
function plot_trajectories(flow; sty=default_style)
  inf_layer = gf.layer(flow, x=:t, y=:Infectives, color=[sty.colour(I(0.0,1,2))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  rem_layer = gf.layer(flow, x=:t, y=:Removals, color=[sty.colour(R(0.0, 1))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  sus_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[sty.scaffold], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(sus_layer, rem_layer, inf_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"), 
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end
