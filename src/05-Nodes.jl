#
#
# [`05-Nodes.jl`] Node-drawing Functions
# ======================================
# Here are functions to draw nodes (optionally as realized or not) for 
# vectors of incidents of `BasicIncident`.
# The function `draw_incident`^[The function `draw_incident` is **exported**.]
# draws plain undecorated incidents.

# Here we seek better code.
function draw_incident(xl::Vector{T}; realized=false, sty=default_style) where T<:AbstractIncident
  if length(xl) > 0
    if realized
      xli = [x for x in xl if typeof(x) <: AbstractInfection]
      (context(),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
            sty.realized, fill(sty.colour(xl)), fillopacity(0.0), stroke(sty.colour(xl)) ),
        (context(),
          circle(map(x->(x.t)cx, xli), map(x -> x.infectee, xli), [sty.smradius]),
            sty.realized, fill(sty.colour(xli)), fillopacity(0.0), stroke(sty.colour(xli))),
      )  
    else
      (context(),
        (context(),
          text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
               map(x -> string(x), xl), [hcenter], [vcenter]), 
          fontsize(5pt), font("Helvetica")),
        (context(),
          circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
          fill(sty.blank), stroke(sty.colour(xl))), )
    end
  end
end

# Incidents decorated with connections are drawn using
# `draw_connect`.^[The function `draw_connect` is used 
# in the exported function `draw_elements` defined in this section.]
function draw_connect(xl::Vector{T}; realized=false, sty=default_style) where T<:AbstractIncident
  xli = [x for x in xl if typeof(x) <: AbstractInfection]
  (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+sty.radius), ((x.t)cx, (x.infectee)cy)], xli)),
    line(map(x -> [((x.t)cx - 0.3sty.bit, (x.infectee)cy-sty.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3sty.bit, (x.infectee)cy-sty.bit)], xli)), 
    stroke(sty.colour(xli)), (realized ? sty.realized : sty.dormant) )
end

# The next function 
# `draw_elements`^[The function `draw_elements` is **exported**.]
# draws the various incidents.^[Replacing the `draw_incident` lines by a single 
# `draw_incident(innov.chronology, sty=sty)`
# works, but there is an issue with order of over-writing.]
function draw_elements(innov; sty=default_style) 
  (context(),
    draw_incident(innov.chronology, sty=sty),
    draw_connect(innov.chronology, sty=sty),
  )
end

# The next function `draw_realized_elements`^[The function `draw_realized_elements` is **exported**.]
# draws the realized elements together with connectors.
function draw_realized_elements(initial, realized; sty=default_style)
  realized_removals   = [inc for inc in realized if (isa(inc, Removal) || isa(inc, CRemoval))]
  enumerated_removals = collect(enumerate(realized_removals))
  (context(),
    draw_incident(realized, realized=true, sty=sty),
    draw_connect(realized, realized=true, sty=sty),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [sty.smradius]), stroke(sty.colour(CRemoval(0.0, 1))), 
             sty.realized, fill(sty.colour(CRemoval(0.0, 1))), fillopacity(0.5) 
      ),
      # Connecting removal lines if not of negative length
      (context(),
        line([[((inc.t)cx, (inc.target)cy - sty.radius), 
                ((inc.t)cx, (k + initial.r)cy + sty.radius)]
                      for (k, inc) in enumerated_removals if inc.target > k + initial.r]), 
        stroke(sty.colour(Removal(0.0,1))), sty.trail, strokedash([1mm, 1mm]) 
      ), 
    ) 
  )
end
