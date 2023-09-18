# Node-drawing Functions (`05-Nodes.jl`)
# ======================================
# Here are functions to draw nodes (optionally as realized or not) for 
# vectors of incidents.
# The function `draw_incident`^[The function `draw_incident` is **exported**.]
# draws plain undecorated incidents.
#
# ::: {.callout-warning}
# Seek better code!
# :::
function draw_incident(xl::Vector{T}; realized=false, theme=default_theme) where T<:AbstractIncident
  if length(xl) > 0
    if realized
      xli = [x for x in xl if typeof(x) <: AbstractInfection]
      return (context(),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]), 
            theme.realized, fill(theme.colour(xl)), fillopacity(0.0), stroke(theme.colour(xl)) ),
        (context(),
          circle(map(x->(x.t)cx, xli), map(x -> x.infectee, xli), [theme.smradius]),
            theme.realized, fill(theme.colour(xli)), fillopacity(0.0), stroke(theme.colour(xli))),
      )  
    else
      return (context(),
        (context(),
          text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
               map(x -> string(x), xl), [hcenter], [vcenter]), 
          fontsize(5pt), font("Helvetica")),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [theme.radius]), 
          fill(theme.blank), stroke(theme.colour(xl))), )
    end
  end
end

# Incidents themerated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; realized=false, theme=default_theme) where T<:AbstractIncident
  xli = [x for x in xl if typeof(x) <: AbstractInfection]
  return (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+theme.radius), ((x.t)cx, (x.infectee)cy)], xli)),
    line(map(x -> [((x.t)cx - 0.3theme.bit, (x.infectee)cy-theme.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3theme.bit, (x.infectee)cy-theme.bit)], xli)), 
    stroke(theme.colour(xli)), (realized ? theme.realized : theme.dormant) )
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

# The function `draw_realized_elements`^[The function `draw_realized_elements` is **exported**.]
# draws the realized elements together with connectors.
function draw_realized_elements(initial, realized; theme=default_theme)
  realized_removals   = [inc for inc in realized if (isa(inc, Removal) || isa(inc, CRemoval))]
  enumerated_removals = collect(enumerate(realized_removals))
  return (context(),
    draw_incident(realized, realized=true, theme=theme),
    draw_connect(realized, realized=true, theme=theme),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [theme.smradius]), stroke(theme.colour(CRemoval(0.0, 1))), 
             theme.realized, fill(theme.colour(CRemoval(0.0, 1))), fillopacity(0.5) 
      ),
# (and connect removal lines when they are not of negative length)
      (context(),
        line([[((inc.t)cx, (inc.target)cy - theme.radius), 
                ((inc.t)cx, (k + initial.r)cy + theme.radius)]
                      for (k, inc) in enumerated_removals if inc.target > k + initial.r]), 
        stroke(theme.colour(Removal(0.0,1))), theme.trail, strokedash([1mm, 1mm]) 
      ), 
    ) 
  )
end
