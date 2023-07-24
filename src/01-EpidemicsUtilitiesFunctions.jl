# Functions defined in `01-EpidemicsUtilitiesFunctions.jl`
# ========================================================
# Constructions and definitions
# -----------------------------
# ### Creation of union of composite `AbstractIncident` types
# We will use a union type, `BasicIncident`, based on composite `AbstractIncident` types.
# This is computed within the module.
#
# ::: {.callout-caution}
# Computation of a new type within module counts as altering internal state!
#
# Try to avoid this.
# :::
function unionize_composites(a::Type)::Type
  coll = subtypes(a)
  xl = Type[x for x in coll]
  if length(xl) == 0
    return a # return a composite type
  else
    xl = Type[unionize_composites(y) for y in xl]
    return reduce((t1, t2) -> Union{t1, t2}, xl) # return a union type
  end
end 

BasicIncident = unionize_composites(AbstractIncident)

# ### Colours related to various incidents, using function `csty`.
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# These abbreviations (or an appropriate subset) are often repeated on scripts.
A = AbstractInfection
R = Removal   ; C = CRemoval   
I = Infection ; P = PInfection
IR = InitialRemoved    ; II = InitialInfected    ; IS = InitialSusceptible
CR = ContinuingRemoved ; CI = ContinuingInfected ; CS = ContinuingSusceptible
MIA = MarkerInfectionA ; MRA = MarkerRemovalA
MIB = MarkerInfectionB ; MRB = MarkerRemovalB

# A function `csty` associates these to colours, using the type hierarchy.
# A useful list of colours is given in <https://juliagraphics.github.io/Colors.jl/stable/namedcolors/>.
#
# ::: {.callout-note}
# Might be better to choose colour based on `T` rather than `Vector{T}`?
# :::
function csty(x::R) colorant"tan"       end 
function csty(x::C) colorant"purple"    end 
function csty(x::I) colorant"orange"    end 
function csty(x::P) colorant"darkgreen" end 
function csty(x::T) where T<:AbstractInfectionMarker   colorant"orange"      end
function csty(x::T) where T<:AbstractRemovalMarker     colorant"tan"         end
function csty(x::T) where T<:AbstractSusceptibleMarker colorant"blue"        end
function csty(x::T) where T<:AbstractIncident          colorant"white"       end

function csty(xl::Vector{T}) where T<:AbstractIncident 
  return [csty(x) for x in xl]
end

# ### Default drawing styles forming a structure `defaultstyle`.
# The following default style structure is frequently used by
# the `FigureUtilities` functions defined below,
# _via_ a keyword argument `sty`.
#
# ::: {.callout-note}
# See if this can be read-in from a data-file instead.
# :::
defaultstyle = (
  radius   =  0.2cy,               smradius =  0.9 * 0.2cy,
  bit      = -0.02h,               tic      = -0.2cy,
  xlab     =  0cx-0.4inch,         yloc     = 0.25inch,
  height   =  0.0cy,              
  boundary =  linewidth(1.00mm),   trail    =  linewidth(0.75mm),
  broad    =  linewidth(2.00mm),
  realized =  linewidth(0.75mm),   dormant  =  linewidth(0.25mm),
  blank    =  colorant"white",     scaffold =  colorant"grey",
  forbid1  =  colorant"steelblue", forbid2  =  colorant"lightsteelblue", 
  region   =  (context(), rectangle(), fill(colorant"bisque"), fillopacity(0.3)),
  colour   =  csty,
)


# ### Graphics utility
# The following short utility function is helpful.
# It displays a figure produced using `Compose` or `Gadfly`,
# and also creates corresponding `PNG` and `PDF` renderings in directory `image`.
function depict(title, image)
  draw(PNG("image/$title.png"), image)
  draw(PDF("image/$title.pdf"),  image)
  image
end

    
# Basic image template elements
# -----------------------------
# We need a function to draw the time axis, with tick marks at integer times.
# Used in exported function `scaffolding`.
# Note, both here and following, the careful use of graphics area units (`cx`, `cy`).
function time_axis(duration; sty=defaultstyle)
  labellocs = [(x)cx for x in 0:duration]
  step = 10^floor(Int, log10(duration))
  tic1  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:1.0step:duration]
  tic2  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:0.5step:duration]
  tic3  = [(((x)cx,sty.height), ((x)cx, sty.height+0.5sty.tic)) for x in 0:0.1step:duration]

  (context(), # Returned value of function!
    (context(), text(labellocs, [sty.height + sty.yloc], ["$i" for i in 0:duration], 
      [hcenter], [vcenter]), fontsize(5pt), font("TimesRoman"), ),
    (context(), line([(0cx, sty.height), ((duration)cx, sty.height)]),
      stroke(sty.scaffold), linewidth(0.5mm) ),
    (context(), line(tic1), stroke(sty.scaffold), linewidth(0.2mm)),
    (context(), line(tic2), stroke(sty.scaffold), linewidth(0.1mm)),
    (context(), line(tic3), stroke(sty.scaffold), linewidth(0.1mm)), )
end

# Now we define a function to draw all time-lines as threads labelled by circled integers.
# Used in exported function `scaffolding`.
#
# ::: {.callout-caution}
# The definition of `circlabels` below needs to be changed if `population > MAXPOP=20`,
# as unicode then runs out of circled integers!
# (Figure out how to use 
# one of the many ideas in 
# <https://tex.stackexchange.com/questions/7032/good-way-to-make-textcircled-numbers>.)
# :::
function time_threads(duration, population; sty=defaultstyle)
  circlabels   = [string(Char(0x00002460+i-1)) for i in 1:population]

  (context(), # Returned value of function!
    (context(), text([sty.xlab], [(k)cy for k in 1:population], circlabels,
      [hleft], [vcenter]), fontsize(10pt), font("TimesRoman"), ),
    (context(), line([[(0cx, (k)cy), ((duration)cx, (k)cy)] for k in 1:population]), 
      stroke(sty.scaffold), linewidth(0.5mm), ), )
end

# These two functions are put together in a third, which constructs scaffolding (axes, time lines _etc_).
# This function is _exported_.
function scaffolding(duration, population; sty=defaultstyle)
  (context(), sty.region, time_axis(duration, sty=sty), 
              time_threads(duration, population, sty=sty))
end

# Drawing functions (`Compose`)
# -----------------------------
# Here are functions to draw nodes (optionally as realized or not) for 
# vectors of incidents of `BasicIncident`.
# This function is _exported_.
#
# ::: {.callout-note}
# Colours (in `fill` and `stroke`) are vectorized!
# :::
function draw_incident(xl::Vector{T}; realized=false, sty=defaultstyle) where T<:BasicIncident
  if length(xl) == 0
    return
  end
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

# ::: {.callout-warning}
# _Experimental_ so not yet used, not yet exported!
# :::
function draw_incident_test(xl::Vector{T}; realized=false, sty=defaultstyle) where T<:BasicIncident
  if length(xl) == 0
    return
  end
  if realized
    (context(),
      (context(),
      circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
        sty.realized, fill(sty.colour(xl)), 
        fillopacity(0.2), stroke(sty.colour(xl)) ),
      if eltype(xl)<:AbstractInfection
        (context(),
        circle(map(x->(x.t)cx, xl), map(x -> x.infectee, xl), [sty.smradius]),
          sty.realized, fill(sty.colour(xl)), fillopacity(0.5), stroke(sty.colour(xl)))
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

# Draw incidents with connections.
# Used in exported function `draw_elements`.
#
# ::: {.callout-note}
# Colours (in `fill` and `stroke`) are vectorized!
# :::
function draw_connect(xl::Vector{T}; realized=false, sty=defaultstyle) where T<:BasicIncident
  if ! (eltype(xl)<:AbstractInfection)
    return
  end
  (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+sty.radius), ((x.t)cx, (x.infectee)cy)], xl)),
    line(map(x -> [((x.t)cx - 0.3sty.bit, (x.infectee)cy-sty.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3sty.bit, (x.infectee)cy-sty.bit)], xl)), 
    stroke(sty.colour(xl)), (realized ? sty.realized : sty.dormant) )
end

# This arranges for incidents not to be drawn unless it is specifically arranged to do so.
function draw_incident(xl::Vector{T}; realized=false, sty=defaultstyle) where T<:AbstractIncident 
end
function draw_connect(xl::Vector{T}; realized=false, sty=defaultstyle) where T<:AbstractIncident 
end 

# The next function draws the various incidents.
# _This function is exported._
function draw_elements(innov; I=I, P=P, R=R, C=C, sty=defaultstyle) 

  (context(),
    #draw_incident(innov.chronology, sty=sty), ## 19/07/23
    draw_incident([inc for inc in innov.infections if isa(inc, I)], sty=sty), ## 19/07/23
    draw_incident([inc for inc in innov.infections if isa(inc, P)], sty=sty), ## 19/07/23
    draw_incident([inc for inc in innov.removals   if isa(inc, R)], sty=sty), ## 19/07/23
    draw_incident([inc for inc in innov.cremovals  if isa(inc, C)], sty=sty), ## 19/07/23
    draw_connect([inc for inc in  innov.infections if isa(inc, I)], sty=sty), ## 19/07/23
    draw_connect([inc for inc in  innov.infections if isa(inc, P)], sty=sty), ## 19/07/23
  )
end

# The next function combines depiction of the incidents with the axes.
# _This function is exported._
function create_nodes_view(duration, innov; I=I, P=P, R=R, C=C, sty=defaultstyle)
  (context(), 
    draw_elements(innov, I=I, P=P, R=R, C=C, sty=sty), 
    scaffolding(duration, innov.population))
end 

# The next function draws the realized elements together with connectors.
# _This function is exported._
function draw_realized_elements(initial, realized; 
            I=I, P=P, R=R, C=C, sty=defaultstyle)
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

# Finally, here is a function which presents incidents, realized incidents,
# connectors and regions on a single figure.
# _This function is exported._
function create_epidemic_view(duration, innov, flow, initial, realized; 
                                  sty=defaultstyle)
  total_trajectory = compute_total_trajectory(duration, innov.population, initial, realized)
  
  (context(),
          draw_realized_elements(initial, realized, sty=sty),
          draw_elements(innov, sty=sty), 
          region_plot(duration, innov.population, total_trajectory),
          scaffolding(duration, innov.population))
end


# Drawing functions (`Gadfly`)
# ----------------------------
# Define functions to construct and plot a dataframe
# of trajectories as knots of piecewise constant functions, having used `evolution`
# to deliver the \(\SIR\) trajectory `traj`
# and a sorted list of realized incidents in `realized`.
# _These functions are exported._
function trajectory_table(duration, initial, traj)
  states = [initial]
  t = [state.t for state in traj] ; push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in traj], inner=2)
  i = repeat([state.i for state in traj], inner=2)
  r = repeat([state.r for state in traj], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

function plot_trajectories(flow; sty=defaultstyle)
  inf_layer = gf.layer(flow, x=:t, y=:Infectives, color=[sty.colour(I(0.0,1,2))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  rem_layer = gf.layer(flow, x=:t, y=:Removals, color=[sty.colour(R(0.0, 1))], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  sus_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[sty.scaffold], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(sus_layer, rem_layer, inf_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"), 
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end

# Drawing regions
# ---------------
# First a function to draw a marker node. 
# Note that marker labels omit time-line superscript as this is redundant!
function draw_marker(xl::Vector{T}; sty=defaultstyle) where T<:AbstractMarker
  if length(xl) > 0
    (context(),
      (context(),
        text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
             map(x -> chop(string(x)), xl), [hcenter], [vcenter]), 
        fontsize(5pt), font("Helvetica")
      ),
      (context(),
        circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.smradius]), 
        fillopacity(0.2), fill(sty.colour(xl)), stroke(sty.colour(xl))
      ), 
      (context(),
        circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.smradius]), 
        fill(sty.blank),
      ),
    )
  end
end

# Compute total trajectory
# _This function is exported._
function compute_total_trajectory(duration, population, initial_state, realized)
  initial_markers = Iterators.flatten([
    [IR(0, k) for k in 1:initial_state.r],
    [II(0, k) for k in (initial_state.r+1):(initial_state.r+initial_state.i)],
    [IS(0, k) for k in (initial_state.r+initial_state.i+1):population]
  ])
  
  infect1 = [x for x in realized if isa(x, I) || isa(x, P)]
  infect2 = [(MIA(x.t, x.infectee-1), MIB(x.t, x.infectee)) for x in infect1]
  remove1 = [x for x in realized if isa(x, C) || isa(x, R)]
  remove2 = [(MRA(x.t, k-1), MRB(x.t, k)) for (k, x) in enumerate(remove1)]
  realized2 = sort(vcat(infect2, remove2), lt=(x,y) -> isearlier(x[1], y[1]))
  realized_trajectory = collect(Iterators.flatten(realized2));

  rend = maximum(x.target for x in realized_trajectory if isa(x, MRB) )
  iend = maximum(x.target for x in realized_trajectory if isa(x, MIB))

  collect(Iterators.flatten(
    [initial_markers, realized_trajectory,
    [CR(duration, k) for k in 1:rend],
    [CI(duration, k) for k in (rend+1):iend],
    [CS(duration, k) for k in (iend+1):population]
  ]))
end

# Representing infected area as collection of rectangles
function infected_areas(population, total_trajectory)
  xx= Float64[] ; yy = Integer[] ; rw = Float64[] ; rl = Integer[] ;
  for k in 1:population
    level = [bb for bb in total_trajectory if bb.target==k]
    starts = [bb for bb in level if (isa(bb, MIB) || isa(bb, II))]
    ends   = [bb for bb in level if (isa(bb, MRB) || isa(bb, CI))]
    if length(starts) > 0 && length(ends) > 0
      disk1 = [bb for bb in level if (isa(bb, MIB) || isa(bb, II))][1]
      disk2 = [bb for bb in level if (isa(bb, MRB) || isa(bb, CI))][1]
      append!(xx, disk1.t)
      append!(yy, k-1)
      append!(rw, disk2.t - disk1.t)
      append!(rl, 1)
    end
  end
  return xx, yy, rw, rl
end

# Representing removed area as collection of rectangles
function removed_areas(population, total_trajectory)
  xx= Float64[] ; yy = Integer[] ; rw = Float64[] ; rl = Integer[] ;
  for k in 1:population
    level = [bb for bb in total_trajectory if bb.target==k]
    starts = [bb for bb in level if (isa(bb, MRB) || isa(bb, IR))]
    ends   = [bb for bb in level if (isa(bb, CR))]
    if length(starts) > 0 && length(ends) > 0
      disk1 = starts[1]
      disk2 = ends[1]
      append!(xx, disk1.t)
      append!(yy, k-1)
      append!(rw, disk2.t - disk1.t)
      append!(rl, 1)
    end
  end
  return xx, yy, rw, rl
end

# Compute epidemic trajectory, adding a final segment 
# by appending highest `MRB` if proposed trajectory doesn't extend to full duration.
# Used in exported function `region_plot`.
function epidemic_trajectory(duration, total_trajectory)
  e_trajectory = [(x.t, x.target) for x in total_trajectory 
  if (isa(x, MIA) || isa(x, MIB)  || 
      isa(x, II) || isa(x, CI))]

  terminus = e_trajectory[end]
  if (terminus[1] < duration)
    end_marker = [x for x in total_trajectory if x.target == terminus[2]][3]
    push!(e_trajectory, (end_marker.t, end_marker.target))
  end 
  
  e_trajectory
end

# Compute removal trajectory, adding a final segment 
# by appending highest `MRB` if proposed trajectory doesn't extend to full duration.
# Used in exported function `region_plot`.
function removal_trajectory(duration, total_trajectory)
  r_trajectory = [(x.t, x.target) for x in total_trajectory 
      if (isa(x, IR) || isa(x, MRA) || isa(x, MRB))]

  terminus = r_trajectory[end]
  if (terminus[1] < duration)
    push!(r_trajectory, (duration, terminus[2]))
  
  r_trajectory
  end
end

# Now a function to plot infected and removed regions together with epidemic
# and removal trajectories.
# _This function is exported._
#
# :::{.callout-note}
# Consider using "total_markers" and 
# ensuring "total_trajectory" actually is a trajectory!
# :::
function region_plot(duration, population, total_trajectory; sty=defaultstyle)
  xx1, yy1, rw1, rl1 = infected_areas(population, total_trajectory)
  xx2, yy2, rw2, rl2 = removed_areas(population, total_trajectory)
 
  (context(),
    draw_marker([x for x in total_trajectory if isa(x, IS)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, II)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, IR)], sty=sty),

    draw_marker([x for x in total_trajectory if isa(x, MIA)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, MIB)], sty=sty),

    draw_marker([x for x in total_trajectory if isa(x, MRA)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, MRB)], sty=sty),
  
    draw_marker([x for x in total_trajectory if isa(x, CS)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, CI)], sty=sty),
    draw_marker([x for x in total_trajectory if isa(x, CR)], sty=sty),

    (context(),
      rectangle(xx1, yy1, rw1, rl1),
      fill(sty.colour(I(0.0, 1,2))), fillopacity(0.3),
    ),

    (context(),
      rectangle(xx2, yy2, rw2, rl2),
      fill(sty.colour(C(0.0, 1))), fillopacity(0.3),
    ),

    (context(),
    line(epidemic_trajectory(duration, total_trajectory)),
      stroke(sty.colour(I(0.0, 1,2))), sty.trail
    ),

    (context(),
      line(removal_trajectory(duration, total_trajectory)),
      stroke(sty.colour(C(0.0, 1))), sty.trail
    ),

    scaffolding(duration, population),
  )
end


