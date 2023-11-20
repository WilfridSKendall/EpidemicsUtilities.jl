# Included script: Graphics outputs (`05-Outputs.jl`)
# ===================================================
# The following short utility function
# `depict`^[The function `depict` is **exported**.]
# is helpful.
# It displays a figure produced using `Compose` or `Gadfly`,
# and also creates corresponding `PNG` and `PDF` renderings in a sub-directory `image`.
function depict(title, image)
  draw(PNG("image/$title.png"), image)
  draw(PDF("image/$title.pdf"), image)
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
function new_figure(old_figure, gadfly_list...; title="")
    figure = deepcopy(old_figure)
    push!(figure, gadfly_list...)
    if title !== ""
      push!(figure, Guide.title(title))
    return figure
end

