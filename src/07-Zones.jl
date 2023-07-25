#
#
# Drawing Zones [`07-Zones.jl`]
# =============================

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

# A function to plot infected and removed zones (together with epidemic
# and removal trajectories using material from `06-Trajectories,jl`,
# and using `scaffolding` from `03-Templates,jl`).
#
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
