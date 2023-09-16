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
function draw_incident(xl::Vector{T}; realized=false, deco=default_deco) where T<:AbstractIncident
  if length(xl) > 0
    if realized
      xli = [x for x in xl if typeof(x) <: AbstractInfection]
      return (context(),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [deco.radius]), 
            deco.realized, fill(deco.colour(xl)), fillopacity(0.0), stroke(deco.colour(xl)) ),
        (context(),
          circle(map(x->(x.t)cx, xli), map(x -> x.infectee, xli), [deco.smradius]),
            deco.realized, fill(deco.colour(xli)), fillopacity(0.0), stroke(deco.colour(xli))),
      )  
    else
      return (context(),
        (context(),
          text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
               map(x -> string(x), xl), [hcenter], [vcenter]), 
          fontsize(5pt), font("Helvetica")),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [deco.radius]), 
          fill(deco.blank), stroke(deco.colour(xl))), )
    end
  end
end

# Incidents decorated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; realized=false, deco=default_deco) where T<:AbstractIncident
  xli = [x for x in xl if typeof(x) <: AbstractInfection]
  return (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+deco.radius), ((x.t)cx, (x.infectee)cy)], xli)),
    line(map(x -> [((x.t)cx - 0.3deco.bit, (x.infectee)cy-deco.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3deco.bit, (x.infectee)cy-deco.bit)], xli)), 
    stroke(deco.colour(xli)), (realized ? deco.realized : deco.dormant) )
end

# The next function 
# `draw_elements`^[The function `draw_elements` is **exported**.]
# draws the various incidents.^[Replacing the `draw_incident` lines by a single 
# `draw_incident(innov.chronology, deco=deco)`
# works, but there is an issue with order of over-writing.]
function draw_elements(innov; deco=default_deco) 
  (context(),
    draw_incident(innov.chronology, deco=deco),
    draw_connect(innov.chronology, deco=deco),
  )
end

# The function `draw_realized_elements`^[The function `draw_realized_elements` is **exported**.]
# draws the realized elements together with connectors.
function draw_realized_elements(initial, realized; deco=default_deco)
  realized_removals   = [inc for inc in realized if (isa(inc, Removal) || isa(inc, CRemoval))]
  enumerated_removals = collect(enumerate(realized_removals))
  return (context(),
    draw_incident(realized, realized=true, deco=deco),
    draw_connect(realized, realized=true, deco=deco),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [deco.smradius]), stroke(deco.colour(CRemoval(0.0, 1))), 
             deco.realized, fill(deco.colour(CRemoval(0.0, 1))), fillopacity(0.5) 
      ),
# (and connect removal lines when they are not of negative length)
      (context(),
        line([[((inc.t)cx, (inc.target)cy - deco.radius), 
                ((inc.t)cx, (k + initial.r)cy + deco.radius)]
                      for (k, inc) in enumerated_removals if inc.target > k + initial.r]), 
        stroke(deco.colour(Removal(0.0,1))), deco.trail, strokedash([1mm, 1mm]) 
      ), 
    ) 
  )
end
