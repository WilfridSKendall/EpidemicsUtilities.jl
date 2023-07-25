#
#
# A simple graphics utility [`08-Utility.jl`]
# ===========================================
# The following short utility function is helpful.
# It displays a figure produced using `Compose` or `Gadfly`,
# and also creates corresponding `PNG` and `PDF` renderings in a sub-directory `image`.
function depict(title, image)
  draw(PNG("image/$title.png"), image)
  draw(PDF("image/$title.pdf"),  image)
  image
end
