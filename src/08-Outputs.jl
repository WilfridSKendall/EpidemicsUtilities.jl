# Graphics outputs (`08-Outputs.jl`)
# ==================================
# The function 
# `create_nodes_view`^[The function `create_nodes_view` is **exported**.]
# combines depiction of the incidents with the axes supplied
# by `scaffolding` as defined in a previous section.
function create_nodes_view(duration, innov; sty=default_style)
  (context(), 
    draw_elements(innov, sty=sty), 
    scaffolding(duration, innov.population))
end 
# The function 
# `create_epidemic_view`^[The function `create_epidemic_view` is **exported**.]
# presents incidents, realized incidents,
# connectors and regions on a single figure.
function create_epidemic_view(duration, innov, flow, initial, realized; sty=default_style)
  total_trajectory = compute_total_trajectory(duration, innov.population, initial, realized)
  
  (context(),
          draw_realized_elements(initial, realized, sty=sty),
          draw_elements(innov, sty=sty), 
          region_plot(duration, innov.population, total_trajectory, sty=sty),
          scaffolding(duration, innov.population, sty=sty))
end
# Finally the following short utility function
# `depict`^[The function `depict` is **exported**.]
# is helpful.
# It displays a figure produced using `Compose` or `Gadfly`,
# and also creates corresponding `PNG` and `PDF` renderings in a sub-directory `image`.
function depict(title, image)
  draw(PNG("image/$title.png"), image)
  draw(PDF("image/$title.pdf"),  image)
  image
end
