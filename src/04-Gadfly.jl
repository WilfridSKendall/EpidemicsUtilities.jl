# Plotting functions using the plot package `Gadfly` (`04-Gadfly.jl`)
# ===================================================================
# `Gadfly`-based functions, respectively `table_trajectories`
# and `plot_trajectories`^[The functions `table_trajectories` and `plot_trajectories` are **exported**.],
# construct and plot a dataframe
# of trajectories as knots of piecewise constant functions, having used
# `EpidemicsCFTP.evolution`
# to deliver the \(\SIR\) trajectory `trajectory`
# and a sorted list of activated incidents in `activated`.
function table_trajectories(duration, initial, trajectory)
  states = [initial]
  t = [state.t for state in trajectory]
  push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in trajectory], inner=2)
  i = repeat([state.i for state in trajectory], inner=2)
  r = repeat([state.r for state in trajectory], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

# For the next function `plot_trajectories`, 
# the argument `flow` is a `DataFrame` of the form computed by `table_trajectories` above.
# Note that `plot_trajectories` uses the `julia` plotting package `Gadfly`.
function plot_trajectories(flow; theme=default_theme)
  gf = Gadfly
  infection_layer = gf.layer(flow, x=:t, y=:Infectives, color=[theme.colour(Infection(0.0, 1, 2))],
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  removal_layer = gf.layer(flow, x=:t, y=:Removals, color=[theme.colour(Removal(0.0, 1))],
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  susceptible_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[theme.scaffold],
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(susceptible_layer, removal_layer, infection_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"),
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end

# The function `table_trajectories1`^[The function `table_trajectories1` is **exported**.]
# derives and returns a DataFrame (column headings time `t`, `susceptibles`, `infectives`,
# `removals`, and `empty` and `population`, given duration, initial state and trajectory
# of an S-I-R epidemic.
function table_trajectories1(duration, population, initial, trajectory)
    t = [state.t for state in trajectory]
    s = [state.s for state in trajectory]
    i = [state.i for state in trajectory]
    r = [state.r for state in trajectory]
    
    push!(t, duration)
    push!(s, s[end])
    push!(i, i[end])
    push!(r, r[end])

    df = DataFrame(t=t, susceptibles=s, infectives=i, removals=r)
    df[:, :population] .= population
    df[:, :empty] .= 0
    df[:, :epidemic] = df.removals + df.infectives
   
    return df
end
    

# The function `table_trajectories2`^[The function `table_trajectories2` is **exported**.]
# derives and returns an augmented `DataFrame` (column headings time `t`, `susceptibles`, 
# `infectives`, `removals`, and `empty` and `population`, given a `DataFrame` produced 
# by `table_trajectories1`. The augmented `DataFrame` allows us to compute and plot the 
# regions determined by the epidemic trajectory using `Gadfly` `ribbon` plotting.
function table_trajectories2(df; theme=default_theme)
    df_lag = deepcopy(df)
    df_lag.t = circshift(df.t, (-1)) .- theme.ϵ
    df_lag.t[end] = df_lag.t[end-1]
    return sort!(append!(df, df_lag))
end ;

