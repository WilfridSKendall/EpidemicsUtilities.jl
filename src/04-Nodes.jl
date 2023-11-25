# Included script: Node-drawing Functions (`04-Nodes.jl`)
# =======================================================
# Here are functions to draw nodes (optionally as activated or not) for 
# vectors of incidents.
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
      xli = [x for x in xl if typeof(x) <: AbstractInfection]
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

# Incidents decorated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is **exported** and is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; 
                      activated=false, theme=default_theme) where {T<:AbstractIncident}
  xli = [x for x in xl if typeof(x) <: AbstractInfection]
  if ! isempty(xli)
    return (context(),
      line(map(x -> [((x.t)cx, (x.target)cy + theme.radius), ((x.t)cx, (x.infectee)cy)], xli)),
      line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy - theme.bit),
          ((x.t)cx, (x.infectee)cy),
          ((x.t)cx + 0.3theme.bit, (x.infectee)cy - theme.bit)], xli)),
      stroke(theme.colour(xli)), linewidth(activated ? theme.activated : theme.dormant))
  end
end

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

# The function `draw_activated_elements`^[The function `draw_activated_elements` is **exported**.]
# draws the activated elements together with connectors.
# Note that the first argument `initial` is required in order to access the initial
# number `initial.r` of removals.
function draw_activated_elements(initial, activated; theme=default_theme)
  removals = [inc for inc in activated if isa(inc, AbstractRemoval)]
  enumerated_removals = collect(enumerate(removals))
  return (context(),
    draw_incident(activated, activated=true, theme=theme),
    draw_connect(activated, activated=true, theme=theme),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) in enumerated_removals],
          [(k + initial.r)cy for (k, inc) in enumerated_removals],
          [theme.smradius]), stroke(theme.colour(CRemoval)),
        linewidth(theme.activated), fill(theme.colour(CRemoval)), fillopacity(0.5)
      ),
      # (and connect removal lines when they are not of negative length)
      (context(),
        line([[((inc.t)cx, (inc.target)cy - theme.radius),
          ((inc.t)cx, (k + initial.r)cy + theme.radius)]
              for (k, inc) in enumerated_removals if inc.target > k + initial.r]),
        stroke(theme.colour(Removal)), linewidth(theme.trail), strokedash([1mm, 1mm])
      ),
    )
  )
end

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

# The following convenience functions return various Gadfly figures for an evolution. 
# Flow calculations occur within the functions! 
# The keyword argument `select` chooses different aspects.
TOP        = 0b000000001 ; BOUNDARIES = 0b000000010 ; REGIONS    = 0b000000100 ;  
INFECTIONS = 0b000001000 ; REMOVALS   = 0b000010000 ; CREMOVALS  = 0b000100000 ;
ACTIVATED  = 0b001000000 ;
ELEMENTS   = INFECTIONS | REMOVALS | CREMOVALS ; BASIC = ACTIVATED | ELEMENTS ;
ALL        = TOP | BOUNDARIES | REGIONS | BASIC

# Draw regions relating to epidemic.
function draw_regions!(template::Plot, duration::Real, ev::Evolution;
                theme::NamedTuple=theme, select=BOUNDARIES | REGIONS | TOP)
    SIR_flow = table_trajectories1(duration, ev.trajectory)
    xy_SIR_flow = table_trajectories2(flow, theme=theme)
    if (select & TOP) > 0            
        push!(template, 
            layer(flow, x=:t, y=:population, Geom.line,
                    style(line_width=theme.trail, default_color=theme.scaffold)))
    end
    if (select & BOUNDARIES) > 0     
        push!(template, 
            layer(SIR_flow, x=:t, y=:removals, Geom.step,
                style(line_width=theme.boundary, default_color=theme.colour(R))),
            layer(SIR_flow, x=:t, y=:epidemic, Geom.step,
                style(line_width=theme.boundary, default_color=theme.colour(I))))
    end
    if (select & REGIONS) > 0        
        push!(template, 
            layer(xy_SIR_flow, x=:t, ymin=:empty, ymax=:removals, Geom.ribbon,
                alpha=[2theme.opacity], style(default_color=theme.colour(R))),
            layer(xy_SIR_flow, x=:t, ymin=:removals, ymax=:epidemic, Geom.ribbon,
                alpha=[theme.opacity], style(default_color=theme.colour(I))))
    end
    return template
end ;

# Draw aspects of a given `Innovation`.
function draw_innovation!(template::Plot, iv::AbstractEnvironment;
                theme::NamedTuple=theme, select=ELEMENTS)
    if (select & ELEMENTS == ELEMENTS)
        push!(template, Guide.annotation(compose(context(), 
            draw_elements(iv.chronology, theme=theme))))
    else
        if (select & INFECTIONS) > 0        
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.infections, theme=theme))))
        end
        if (select & REMOVALS) > 0        
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.removals, theme=theme))))
        end
        if (select & CREMOVALS) > 0        
            push!(template, Guide.annotation(compose(context(), 
                draw_elements(iv.cremovals, theme=theme))))
        end
    end
    return template
end ;

# Draw aspects of a given `AbstractEvolution`.
function draw_evolution!(template::Plot, ev::AbstractEvolution;
                theme::NamedTuple=theme, select=ELEMENTS | ACTIVATED)
    if (select & ELEMENTS) > 0   
        template = draw_innovation!(figure, ev, theme=theme, select=select & ELEMENTS)
    end
    if (select & ACTIVATED) > 0      
        push!(template, Guide.annotation(compose(context(), 
            draw_activated_elements(ev.initial, ev.history, theme=theme))))
    end
    return template
end ;
