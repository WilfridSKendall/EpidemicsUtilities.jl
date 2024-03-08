# Included script: Graphics outputs (`05-Outputs.jl`)
# ===================================================
# The following short utility function
# `depict`^[The function `depict` is **exported**.]
# is helpful.
# It displays a figure produced using `Compose` or `Gadfly`,
# and also creates corresponding `PNG` and `PDF` renderings in a sub-directory `image`
# so long as `title` is not empty (NB the empty string _is_ empty!).
"""
  depict(::String, ::Any)

This displays a figure produced using `Compose` or `Gadfly`,
and also creates corresponding `PNG` and `PDF` renderings in a sub-directory `image`
so long as the first argument is not empty (NB the empty string _is_ empty!).
"""
function depict(title::String, image::Any)
  if ! isempty(title)
    draw(PNG("image/$title.png"), image)
    draw(PDF("image/$title.pdf"), image)
  end
  image
end
#
# The further utility function
# `new_figure`^[The function `new_figure` is **exported**.]
# allows assembly of a figure based on a `deepcopy` of a template (`old_figure`)
# followed by insertion of a variable number of `Gadfly` constructs (which
# could include `Guide.annotation`s of `Compose` constructs!).
#
# Here a `deepcopy` is made to avoid over-writing the template with further objects.
"""
  new_figure(::Any, ::Any...; title="")

This allows assembly of a figure based on a `deepcopy` of a template (`old_figure`)
followed by insertion of a variable number of `Gadfly` constructs (which
could include `Guide.annotation`s of `Compose` constructs!).
"""
function new_figure(template, gadfly_list...; title="")
    figure = deepcopy(template)
    if ! isempty(gadfly_list)
      push!(figure, gadfly_list...)
    end
    if title !== ""
      push!(figure, Guide.title(title))
    end
    return figure
end

