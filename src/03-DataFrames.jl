# Included script: Tabulation with `DataFrames` (`03-DataFrames.jl`)
# ==================================================================
# The function `table_trajectories1`^[The function `table_trajectories1` is **exported**.]
# derives and returns a DataFrame (columns time `t`, `susceptibles`, `infectives`,
# `removals`, and `empty` and `population`, given $\SIR$ epidemic duration and trajectory.
function table_trajectories1(duration, trajectory)
    t = [state.t for state ∈ trajectory]
    s = [state.s for state ∈ trajectory]
    i = [state.i for state ∈ trajectory]
    r = [state.r for state ∈ trajectory]
    n = [state.n for state ∈ trajectory]            # <1>
    
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
# 1. Slight inefficiency in next step (as opposed to using something like
# `n .= state.n`), but allows for time-varying population later.

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
    return sort!(append!(df1, df2), [:t, :epidemic, :removals]) # <1>
end ;
# 1. Sort `:epidemic` within `:removals` within `:t`!

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
    nfz_df[2:end, :low_NFZ] = [max(beginning, x) for x ∈ nfz_df[2:end, :low_NFZ]] # <1>
    return nfz_df
end
# 1. Surely the next bit can be done better?!
#

# The function `prepare_screen` constructs a basic figure with labelled axes.
# guidelines, and basic trajectory of removals.
function prepare_screen(initial, evmin0;
                        ytic_gap=10,
                        major_label_font="CMU Serif", minor_label_font="CMU Serif", # <1>
                        theme=default_theme)
    uflow = table_trajectories1(evmin0.duration, evmin0.trajectory) 
    axes_plot = plot(uflow, 
        yintercept=0:ytic_gap:evmin0.size,
        Geom.hline(style=:dash, size=0.1mm, color=theme.scaffold),
        Coord.cartesian(xmin=0-0.1, xmax=evmin0.duration, ymin=0, ymax=evmin0.size + 0.25),
        Guide.yticks(ticks=0:ytic_gap:evmin0.size),
        Guide.xlabel("Process time", orientation=:horizontal),
        style(default_color=theme.background),
        Theme(
            panel_fill=theme.blank,
            background_color=theme.background,
            default_color=theme.default,
            major_label_font=major_label_font, minor_label_font=minor_label_font,
            minor_label_color=theme.legend, major_label_color=theme.legend,
            major_label_font_size=6pt,     minor_label_font_size=4pt,                # <2>
            plot_padding = [4pt, 2pt, 4pt, 4pt],
            grid_line_width=0mm,
    )) 

    push!(axes_plot, layer(uflow, x=:t, y=:empty, Geom.line,
        style(line_width=theme.trail, default_color=theme.scaffold))) 

    lines_plot = new_figure(axes_plot,
        Scale.y_continuous(labels=(initial.n ≤ MAXPOP ?
            i -> timelinelabels_circled(i; n=initial.n) :
            i -> timelinelabels_bracketed(i; n=initial.n))),
        Guide.ylabel("Time lines")) ;

    return lines_plot
end
# 1. Push the font decisions to chosen `theme`?
# 2. Determine `font_size`, `plot_padding`, `grid_line_width` in chosen `theme`?

# The function `table_trajectories4` computes and returns
# a dataframe of the collection of jumps.
# See [Github documentation of `Impute.jl`](https://invenia.github.io/Impute.jl/latest/api/imputation/#Impute.locf)
function table_trajectories4(evmin, evmax, duration)
# Dataframe holding `evmin` infection points (not including start) as (roughly) `(:t, :xmin == i+r)`
    start_min  = evmin.initial.i + evmin.initial.r
    infect_min = [z for z in evmin.history if z isa AbstractInfection]
    df_min  = DataFrame(t = [z.t for z in infect_min ], xmin = start_min .+ (1:length(infect_min)))
    
# Dataframe holding `evmax` infection points (not including start) as (roughly) `(:t, :xmax == i+r)`
    start_max  = evmax.initial.i + evmax.initial.r
    infect_max = [z for z in evmax.history if z isa AbstractInfection]
    df_max  = DataFrame(t = [z.t for z in infect_max ], xmax = start_max .+ (1:length(infect_max)))
    
# Dataframe holding common vertical jumps from `(:t, :x0)` to `(:t, :x1)`
    ysegment = filter(row -> row.xmin==row.xmax, innerjoin(df_min, df_max, on = :t))
    select!(ysegment, :t => :t0, :xmin => (x -> x .- 1) => :x0, :t => :t1, :xmin => :x1)
    
# Now collect together `df_min` and `df_max` indexed per `t`, 
# and vertically fill to deal with missing values.
    xsegment = sort(outerjoin(df_min, df_max, on = :t), :t)
    pushfirst!(xsegment, (0, start_min, start_max)) 
    Impute.locf!(xsegment)
    
# Re-cast into form of possible _starts_ of horizontal jumps, 
# adding the time from the row below and dropping the row(s) with missing values.
    xsegment = dropmissing(select(xsegment, :t => :t0, :xmin => :x0, 
                                            :t => ShiftedArrays.lead => :t1, :xmax => :x1))
# Keep only those instances where `x0 == x1`.
    filter!(row -> row.x0 == row.x1, xsegment)
    
# Return the vertical concatenation of these as the collection of jumps.
    return vcat(xsegment, ysegment)
end
