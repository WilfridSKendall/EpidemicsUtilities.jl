# Included script: Node-drawing Functions (`04-Nodes.jl`)
# =======================================================
# Here are functions to draw nodes (optionally as activated or not) for 
# vectors of incidents.

# Drawing incidents
# -----------------
# ### `draw_incident` {.unnumbered}
# The function `draw_incident`^[The function `draw_incident` is **exported**.]
# draws plain undecorated incidents.
#
# ::: {.callout-warning}
# Seek better code!
# :::
function draw_incident(xl::Vector{T}; 
                       inscribe=true, activated=false, theme=default_theme) where {T<:AbstractIncident}
  if ! isempty(xl)
    if activated
      xli = [x for x ∈ xl if typeof(x) <: AbstractInfection]
      return (context(),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]),
          linewidth(theme.activated), fill(theme.colour(xl)), fillopacity(0.0), stroke(theme.colour(xl))),
        (context(),
          circle(map(x -> (x.t)cx, xli), map(x -> x.infectee, xli), [theme.smradius]),
          linewidth(theme.activated), fill(theme.colour(xli)), fillopacity(0.0), stroke(theme.colour(xli))),
      )
    else
      return (context(),
        if inscribe
        (context(),
          text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl),
            map(x -> sprint(show, MIME("text/plain"), x), xl), [hcenter], [vcenter]),
          fontsize(5pt), font("Helvetica"))
        end,
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]),
          fill(theme.blank), stroke(theme.colour(xl))),)
    end
  end
end

# ### `draw_connect` {.unnumbered}
# Incidents decorated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is **exported** and is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; 
                      activated=false, theme=default_theme) where {T<:AbstractIncident}
  xli = [x for x ∈ xl if typeof(x) <: AbstractInfection]
  if ! isempty(xli)
    return (context(),
      line(map(x -> [((x.t)cx, (x.target)cy + theme.radius), ((x.t)cx, (x.infectee)cy)], xli)),
      line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy - theme.bit),
          ((x.t)cx, (x.infectee)cy),
          ((x.t)cx + 0.3theme.bit, (x.infectee)cy - theme.bit)], xli)),
      stroke(theme.colour(xli)), linewidth(activated ? theme.activated : theme.dormant))
  end
end

# ### `draw_elements` {.unnumbered}
# The next function 
# `draw_elements`^[The function `draw_elements` is **exported**.]
# draws the various incidents.^[Replacing the `draw_incident` lines by a single 
# `draw_incident(innov.chronology, theme=theme)`
# works, but there is an issue with order of over-writing.]
function draw_elements(inclist::Vector{T}; 
                       activated=false, inscribe=true, theme=default_theme) where {T<:AbstractIncident}
  (context(),
    draw_incident(inclist, activated=activated, inscribe=inscribe, theme=theme),
    draw_connect(inclist, activated=activated, theme=theme),
  )
end

function draw_elements(innov::Innovation; inscribe=true, theme=default_theme)
  draw_elements(innov.chronology, inscribe=inscribe, theme=theme)
end

# ### `draw_activated_elements` {.unnumbered}
# The function `draw_activated_elements`^[The function `draw_activated_elements` is **exported**.]
# draws the activated elements together with connectors.
# Note that the first argument `initial` is required in order to access the initial
# number `initial.r` of removals.
function draw_activated_elements(initial, activated; theme=default_theme)
  removals = [inc for inc ∈ activated if inc isa AbstractRemoval]
  enumerated_removals = collect(enumerate(removals))
  return (context(),
    draw_incident(activated, activated=true, theme=theme),
    draw_connect(activated, activated=true, theme=theme),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) ∈ enumerated_removals],
          [(k + initial.r)cy for (k, inc) ∈ enumerated_removals],
          [theme.smradius]), stroke(theme.colour(CRemoval)),
        linewidth(theme.activated), fill(theme.colour(CRemoval)), fillopacity(0.5)
      ),
      # (and connect removal lines when they are not of negative length)
      (context(),
        line([[((inc.t)cx, (inc.target)cy - theme.radius),
          ((inc.t)cx, (k + initial.r)cy + theme.radius)]
              for (k, inc) ∈ enumerated_removals if inc.target > k + initial.r]),
        stroke(theme.colour(Removal)), linewidth(theme.trail), strokedash([1mm, 1mm])
      ),
    )
  )
end

# ### `draw_feasible_incident` {.unnumbered}
# The function `draw_feasible_incident`^[The function `draw_feasible_incident` is **exported**.]
# draws feasible incidents with connectors (which must be of type `Infection`) 
# at a specified level of feasibility (`1`, `2`, or `3`).
# A **temporary** variant of this works with `feasible` being a general argument
# (treated as a list of `Compose` directives, typically specifying `stroke` colour and `linewidth`.
function draw_feasible_incident(xl::Vector{T}, feasible::Integer; 
                                inscribe=true, theme=default_theme) where T<:AbstractInfection
  lw = [theme.dormant, theme.activated, theme.boundary][feasible]
  col = [theme.lastfeasible1, theme.lastfeasible2, theme.lastfeasible3][feasible]
  return (context(),
    if inscribe
      (context(),
        text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl),
          map(x -> sprint(show, MIME("text/plain"), x), xl), [hcenter], [vcenter]),
        fontsize(5pt), font("Helvetica"))
    end,
    (context(),
      circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]),
      fill(theme.blank), stroke(col), linewidth(lw), fillopacity(theme.opacity)),
    (context(),
     line(map(x -> [((x.t)cx, (x.target)cy + theme.radius), ((x.t)cx, (x.infectee)cy)], xl)),
     line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy - theme.bit),
        ((x.t)cx, (x.infectee)cy),
        ((x.t)cx + 0.3theme.bit, (x.infectee)cy - theme.bit)], xl)),
     stroke(col), linewidth(lw)),
    )
end
# Here is the general variant: the argument `feasible` is expected to be of the form
# `(stroke(col), linewidth(lw))`).
# This is fragile and should eventually be replaced by use of `theme`.
function draw_feasible_incident(xl::Vector{T}, feasible; 
                                inscribe=true, theme=default_theme) where T<:AbstractInfection
  return (context(),
    if inscribe
      (context(),
        text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl),
          map(x -> sprint(show, MIME("text/plain"), x), xl), [hcenter], [vcenter]),
        fontsize(5pt), font("Helvetica"))
    end,
    (context(),
      circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]),
      fill(theme.blank), fillopacity(theme.opacity), feasible...),
    (context(),
     line(map(x -> [((x.t)cx, (x.target)cy + theme.radius), ((x.t)cx, (x.infectee)cy)], xl)),
     line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy - theme.bit),
        ((x.t)cx, (x.infectee)cy),
        ((x.t)cx + 0.3theme.bit, (x.infectee)cy - theme.bit)], xl)),
     feasible...),
    )
end

# Convenience functions
# ---------------------
# The following convenience functions return various Gadfly figures for an evolution. 
# Flow calculations occur within the functions! 
# The keyword argument `select` chooses different aspects, coded by `const`.
const TOP        = 0b00000000001 ;
const BOUNDARIES = 0b00000000010 ; const REGIONS    = 0b00000000100 ;
const INFECTIONS = 0b00000001000 ; const REMOVALS   = 0b00000010000 ;
const CREMOVALS  = 0b00000100000 ;
const ACTIVATED  = 0b00001000000 ;
const LFET       = 0b00010000000 ;
const LFER       = 0b00100000000 ; const LFEN       = 0b01000000000 ;
const NFZ        = 0b10000000000 ;
const ELEMENTS   = INFECTIONS  | REMOVALS | CREMOVALS ;
const BASIC      = ACTIVATED | ELEMENTS ;
const ALL        = TOP  | BOUNDARIES | REGIONS | BASIC ;
const MOST       = BOUNDARIES | REGIONS | BASIC ;
const LFE        = LFET | LFER | LFEN ;

# ### `AbstractEvolution` regions {.unnumbered}
# The function `draw_regions!`^[The function `draw_regions!` is **exported**.]
# draws regions relating to a given `AbstractEvolution`.
# Note the keyword option `specified` allows us to specify a colour for the infection
# trajectory, if `BOUNDARIES` is specified.
function draw_regions!(template::Plot, duration::Real, ev::AbstractEvolution;
                theme::NamedTuple=theme, select=BOUNDARIES | REGIONS | TOP, 
                specified_color=nothing)
    SIR_flow = table_trajectories1(duration, ev.trajectory)               # <1>
    xy_SIR_flow = table_trajectories2(SIR_flow, theme=theme)
    
    if (select & TOP) > 0                                                 # <2>
        push!(template, 
            layer(SIR_flow, x=:t, y=:population, Geom.line,
              style(line_width=theme.trail, default_color=theme.scaffold)),
            )
    end
    
    if (select & BOUNDARIES) > 0                                          # <3> 
        push!(template, 
            layer(SIR_flow, x=:t, y=:removals, Geom.step, 
                  style(line_width=theme.boundary, default_color=theme.colour(Removal))),
            if isnothing(specified_color)
                layer(SIR_flow, x=:t, y=:epidemic, Geom.step, 
                    style(line_width=theme.boundary, default_color=theme.colour(Infection)))
            else
                layer(SIR_flow, x=:t, y=:epidemic, Geom.step, alpha=[0.01],
                    style(line_width=theme.boundary, default_color=specified_color))
            end,
            )
    end
    
    if (select & REGIONS) > 0                                             # <4>         
        push!(template, 
            layer(xy_SIR_flow, x=:t, ymin=:empty, ymax=:removals, Geom.ribbon,
                alpha=[2theme.opacity], style(default_color=theme.colour(Removal))),
            layer(xy_SIR_flow, x=:t, ymin=:removals, ymax=:epidemic, Geom.ribbon,
                alpha=[theme.opacity], style(default_color=theme.colour(Infection))))
    end
    
    return template
end ;
# 1. Construct relevant `DataFrame`s using `table_trajectories1` and `table_trajectories2`
# 2. Draw a thick horizontal line to delineate population for `ev`;
# 3. Draw removal and infection trajectories for `ev` as region boundaries;
# 4. Draw removal and infection regions for `ev`.
#
#

# ### `AbstractEnvironment` aspects {.unnumbered}
# The function `draw_innovation!` ^[The function `draw_innovation!` is **exported**.]
# draws aspects of a given `Innovation` or other `AbstractEnvironment`.
function draw_innovation!(template::Plot, iv::AbstractEnvironment;
                theme::NamedTuple=theme, select=ELEMENTS)
    if (select & ELEMENTS == ELEMENTS)
        push!(template, Guide.annotation(compose(context(), 
            draw_elements(iv.chronology, theme=theme))))          # <1>
    else
        if (select & INFECTIONS) > 0                              # <2>        
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.infections, theme=theme))))
        end
        
        if (select & REMOVALS) > 0                                # <3>         
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.removals, theme=theme))))
        end
        
        if (select & CREMOVALS) > 0                               # <4>         
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.cremovals, theme=theme))))
        end
    end
    return template
end ;
# 1. Draw _all_ elements in the `chronology` field of `iv`;
# 2. Only draw elements in the `infections` field of `iv`;
# 3. Only draw elements in the `removals` field of `iv`;
# 4. Only draw elements in the `cremovals` field of `iv`.
#
#

# ### `AbstractEvolution` aspects {.unnumbered}
# The function `draw_evolution!`^[The function `draw_evolution!` is **exported**.]
# draws `select`ed aspects of a given `AbstractEvolution`.
function draw_evolution!(template::Plot, ev::AbstractEvolution, duration::Real;
                theme::NamedTuple=theme, select=ELEMENTS | ACTIVATED, 
                specified_color=nothing)
    draw_regions!(template, duration, ev, theme=theme, 
                  select=select, specified_color=specified_color)       # <1>

    if ((select & NFZ) > 0) && (! isempty(ev.NFZ))                      # <2>
      nfz_df = table_trajectories3(ev)
      if ((select & REGIONS) > 0)
        push!(template,
          layer(nfz_df, x=:start, y=:time_line, xend=:NFZ1, yend=:time_line, Geom.segment,
            style(line_width=theme.broad, default_color=theme.NFZ1)),
          layer(nfz_df, x=:NFZ1, y=:time_line, xend=:NFZ2, yend=:time_line, Geom.segment,
            style(line_width=theme.broad, default_color=theme.NFZ2)),
          )
      end
      push!(template,
        layer(nfz_df, x=:low_NFZ, y=:time_line, xend=:NFZ, yend=:time_line, Geom.segment,
          style(line_width=theme.trail, default_color=theme.NFZ1)),
        layer(nfz_df, x=:NFZ, y=:time_line, xend=:NFZ, yend=:high_line, Geom.segment,
          style(line_width=theme.trail, default_color=theme.NFZ1)),
        )
      if ((select & REGIONS) > 0)
        push!(template,
          layer(nfz_df, xmin=:start, ymin=:time_line, xmax=:NFZ, ymax=:high_line, Geom.rect,
            style(line_width=theme.trail, default_color=theme.NFZ)),
          )
      end
    end
    
    if ((select & (LFER | LFET)) > 0) && (! isempty(ev.LFE))            # <3>
        initial = ev.trajectory[1]
        LFE_trajectory = evolution(initial, ev.LFE, conditioned=true)[1]
        LFE_flow = table_trajectories1(duration, LFE_trajectory)
        
        if ((select & LFER) > 0)  
            xy_LFE_flow = table_trajectories2(LFE_flow, theme=theme)
            push!(template, 
              layer(xy_LFE_flow, x=:t, ymin=:removals, ymax=:epidemic, Geom.ribbon,
                style(default_color=theme.lastfeasible2)),
              )
        end
        if ((select & LFET) > 0) 
            push!(template, 
              layer(LFE_flow, x=:t, y=:epidemic, Geom.step(direction=:hv), 
                style(line_width=theme.broad, default_color=theme.lastfeasible3)),
              )
        end
    end
    
    if (select & ELEMENTS) > 0                                          # <4>   
        draw_innovation!(template, ev, theme=theme, select=select & ELEMENTS)
    end
    
    if (select & ACTIVATED) > 0                                         # <5>         
        push!(template, Guide.annotation(compose(context(), 
            draw_activated_elements(ev.initial, ev.history, theme=theme))))
    end

    if ((select & LFEN) > 0) && (! isempty(ev.LFE))                     # <6>     
        push!(template, Guide.annotation(compose(context(), 
            draw_feasible_incident(Infection[z for z ∈ ev.LFE if z isa Infection], 2, theme=theme))))
    end

    return template
end ;
# 1. Drawing epidemic and removal trajectories and regions is delegated to `draw_regions!` above.
# Note the keyword option `specified` allows us to specify a colour for (eventually) the
#  epidemic trajectory, if `BOUNDARIES` is specified.
# 2. Draw aspects of the `NFZ`.
# 3. Draw aspects of the `LFE`.
# Note that activated infections of the LFE history are drawn at the _end_ of the function.
# 4. Draw aspects of `Innovation`: various kinds of `AbstractIncident`s.
# 5. Draw activated `AbstractIncident`s.
# 6. As promised above, at the end of the function, draw activated `Infection`s from the `LFE`,
#
#
