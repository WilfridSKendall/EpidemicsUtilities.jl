# Included script: Tabulation functions using `DataFrames` (`03-DataFrames.jl`)
# =============================================================================
# The function `table_trajectories1`^[The function `table_trajectories1` is **exported**.]
# derives and returns a DataFrame (column headings time `t`, `susceptibles`, `infectives`,
# `removals`, and `empty` and `population`, given duration, initial state and trajectory
# of an S-I-R epidemic.
function table_trajectories1(duration, initial, trajectory)
    t = [state.t for state in trajectory]
    s = [state.s for state in trajectory]
    i = [state.i for state in trajectory]
    r = [state.r for state in trajectory]
    # Slight inefficiency in next step, but allows for time-varying population later.
    n = [state.n for state in trajectory]
    
    push!(t, duration)
    push!(s, s[end])
    push!(i, i[end])
    push!(r, r[end])
    push!(n, n[end])

    df = DataFrame(t=t, susceptibles=s, infectives=i, removals=r, population=n)
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

