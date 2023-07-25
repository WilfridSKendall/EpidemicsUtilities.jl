#
#
# Drawing Trajectories [`06-Trajectories.jl`]
# ===========================================
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


    
