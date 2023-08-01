#
#
# [`05-Nodes.jl`] Node-drawing Functions
# ======================================
# Here are functions to draw nodes (optionally as realized or not) for 
# vectors of incidents of `BasicIncident`.
# The function `draw_incident`^[The function `draw_incident` is **exported**.]
# draws plain undecorated incidents.
function draw_incident(xl::Vector{T}; realized=false, sty=default_style) where T<:BasicIncident
  if length(xl) > 0
    if realized
      (context(),
        (context(),
        circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
        sty.realized, fill(sty.colour(xl)), fillopacity(0.0), stroke(sty.colour(xl)) ),
        if eltype(xl)<:AbstractInfection
          (context(),
          circle(map(x->(x.t)cx, xl), map(x -> x.infectee, xl), [sty.smradius]),
            sty.realized, fill(sty.colour(xl)), fillopacity(0.0), stroke(sty.colour(xl)))
        end, )  
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
#
# ::: {.callout-note}
# Colours (in `fill` and `stroke`) are vectorized! However we can't yet make full
# use of this, as we want to isolate `AbstractInfection` sub-types and draw them a little differently.
# :::

# Incidents decorated with connections are drawn using
# `draw_connect`^[The function `draw_connect` is used 
# in the exported function `draw_elements` defined in this section.].
function draw_connect(xl::Vector{T}; realized=false, sty=default_style) where T<:BasicIncident
  if (eltype(xl)<:AbstractInfection)
    (context(), 
      line(map(x -> [((x.t)cx, (x.target)cy+sty.radius), ((x.t)cx, (x.infectee)cy)], xl)),
      line(map(x -> [((x.t)cx - 0.3sty.bit, (x.infectee)cy-sty.bit), 
                     ((x.t)cx,          (x.infectee)cy), 
                     ((x.t)cx + 0.3sty.bit, (x.infectee)cy-sty.bit)], xl)), 
      stroke(sty.colour(xl)), (realized ? sty.realized : sty.dormant) )
  end
end
#
# ::: {.callout-note}
# Colours (in `fill` and `stroke`) are vectorized!
# :::

# The following definitions ensure that general incidents are not drawn at all.
function draw_incident(xl::Vector{T}; realized=false, sty=default_style) where T<:AbstractIncident 
end
function draw_connect(xl::Vector{T}; realized=false, sty=default_style) where T<:AbstractIncident 
end 

# The next function 
# `draw_elements`^[The function `draw_elements` is **exported**.]
# draws the various incidents.^[Replacing the `draw_incident` lines by a single 
# `draw_incident(innov.chronology, sty=sty)`
# does not work well.]
function draw_elements(innov; I=I, P=P, R=R, C=C, sty=default_style) 
  (context(),
    draw_incident([inc for inc in innov.infections if isa(inc, I)], sty=sty),
    draw_incident([inc for inc in innov.infections if isa(inc, P)], sty=sty),
    draw_incident([inc for inc in innov.removals   if isa(inc, R)], sty=sty),
    draw_incident([inc for inc in innov.cremovals  if isa(inc, C)], sty=sty),
    draw_connect([inc for inc in  innov.infections if isa(inc, I)], sty=sty),
    draw_connect([inc for inc in  innov.infections if isa(inc, P)], sty=sty),
  )
end

# The next function 
# `create_nodes_view`^[The function `create_nodes_view` is **exported**.]
# combines depiction of the incidents with the axes supplied
# by `scaffolding` as defined in a previous section.
function create_nodes_view(duration, innov; I=I, P=P, R=R, C=C, sty=default_style)
  (context(), 
    draw_elements(innov, I=I, P=P, R=R, C=C, sty=sty), 
    scaffolding(duration, innov.population))
end 

# The next function `draw_realized_elements`^[The function `draw_realized_elements` is **exported**.]
# draws the realized elements together with connectors.
function draw_realized_elements(initial, realized; 
            I=I, P=P, R=R, C=C, sty=default_style)
  realized_removals   = [inc for inc in realized if (isa(inc, R) || isa(inc, C))]
  enumerated_removals = collect(enumerate(realized_removals))
  (context(),
    draw_incident([inc for inc in realized if isa(inc, I)], realized=true, sty=sty),
    draw_incident([inc for inc in realized if isa(inc, P)], realized=true, sty=sty),
    draw_incident([inc for inc in realized if isa(inc, C)], realized=true, sty=sty),
    draw_connect( [inc for inc in realized if isa(inc, I)], realized=true, sty=sty),
    draw_connect( [inc for inc in realized if isa(inc, P)], realized=true, sty=sty),
    (context(), # Could this be cleaned up?
      (context(),          # Connecting removal nodes
        circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [sty.smradius]), stroke(sty.colour(C(0.0, 1))), 
             sty.realized, fill(sty.colour(C(0.0, 1))), fillopacity(0.5) 
      ),
      (context(),          # Connecting removal lines
        line([[((inc.t)cx, (inc.target)cy - sty.radius), 
                ((inc.t)cx, (k + initial.r)cy + sty.radius)]
                      for (k, inc) in enumerated_removals]), 
        stroke(sty.colour(R(0.0,1))), sty.trail, strokedash([0.5mm, 0.5mm]) 
      ), 
    ) 
  )
end
