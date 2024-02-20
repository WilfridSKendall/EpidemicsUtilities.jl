# Included script: Tabulation functions using `DataFrames` (`03-DataFrames.jl`)
# =============================================================================
# The function `table_trajectories1`^[The function `table_trajectories1` is **exported**.]
# derives and returns a DataFrame (column headings time `t`, `susceptibles`, `infectives`,
# `removals`, and `empty` and `population`, given duration and trajectory
# of an S-I-R epidemic.
function table_trajectories1(duration, trajectory)
    t = [state.t for state ∈ trajectory]
    s = [state.s for state ∈ trajectory]
    i = [state.i for state ∈ trajectory]
    r = [state.r for state ∈ trajectory]
    # Slight inefficiency in next step (as opposed to something like
    # `n .= state.n`), but allows for time-varying population later.
    n = [state.n for state ∈ trajectory]
    
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
# derives and returns a lag-augmented `DataFrame` (column headings time `t`, `susceptibles`, 
# `infectives`, `removals`, and `empty` and `population`), given a `DataFrame` produced 
# by `table_trajectories1`. The augmented `DataFrame` allows us to compute and plot the 
# regions determined by the epidemic trajectory using `Gadfly` `ribbon` plotting.
function table_trajectories2(df; theme=default_theme, forward=true)
    df1, df2 = deepcopy(df), deepcopy(df)
    if forward
        df2.t = circshift(df2.t, (-1)) .- theme.ϵ
        df2.t[end] = df2.t[end-1]
    else
        df2.t = circshift(df2.t, (+1)) .+ theme.ϵ
        df2.t[1] = df2.t[2]
    end
    return sort!(append!(df1, df2))
end ;


# The function `table_trajectories3`
# derives and returns a `DataFrame` (column headings time `time_line`, `NFZ1`, 
# `NFZ2`, `NFZ`, and `high_line` and `low_NFZ`), 
# This allows us to compute and plot the regions
# determined by the computed attributes `NFZ1`,`NFZ2`, `NFZ`.
function table_trajectories3(cev::CEvolution)
    beginning = 0.0
    population = cev.initial.n
    nfz_df = DataFrame(
        time_line=1:population, 
        NFZ1= cev.NFZ1, NFZ2= cev.NFZ2, NFZ= cev.NFZ)
    nfz_df[:, :start] .= beginning
    nfz_df[:, :high_line] = nfz_df[:, :time_line]
    nfz_df[1:(end-1), :high_line] = (nfz_df[1:(end-1), :time_line] .+1)
    nfz_df[:, :low_NFZ] .= beginning
    nfz_df[2:end, :low_NFZ] = (nfz_df[1:(end-1), :NFZ])
    # Surely the next bit can be done better?!
    nfz_df[2:end, :low_NFZ] = [max(beginning, x) for x in nfz_df[2:end, :low_NFZ]]
    return nfz_df
end
