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
                      activated=false, theme=default_theme) where {T<:AbstractIncident}
  if length(xl) > 0
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
        (context(),
          text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl),
            map(x -> sprint(show, MIME("text/plain"), x), xl), [hcenter], [vcenter]),
          fontsize(5pt), font("Helvetica")),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]),
          fill(theme.blank), stroke(theme.colour(xl))),)
    end
  end
end

# Incidents decorated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is **exported** and is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; activated=false, theme=default_theme) where {T<:AbstractIncident}
  xli = [x for x in xl if typeof(x) <: AbstractInfection]
  return (context(),
    line(map(x -> [((x.t)cx, (x.target)cy + theme.radius), ((x.t)cx, (x.infectee)cy)], xli)),
    line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy - theme.bit),
        ((x.t)cx, (x.infectee)cy),
        ((x.t)cx + 0.3theme.bit, (x.infectee)cy - theme.bit)], xli)),
    stroke(theme.colour(xli)), linewidth(activated ? theme.activated : theme.dormant))
end

# The next function 
# `draw_elements`^[The function `draw_elements` is **exported**.]
# draws the various incidents.^[Replacing the `draw_incident` lines by a single 
# `draw_incident(innov.chronology, theme=theme)`
# works, but there is an issue with order of over-writing.]
function draw_elements(innov; theme=default_theme)
  (context(),
    draw_incident(innov.chronology, theme=theme),
    draw_connect(innov.chronology, theme=theme),
  )
end

# The function `draw_activated_elements`^[The function `draw_activated_elements` is **exported**.]
# draws the activated elements together with connectors.
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
     stroke(col), linewidth(lw)),
    )
end
