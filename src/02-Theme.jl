# Themes for plotting (`02-Theme.jl`)
# ===================================

# Reading in information to define default plotting `theme`
# --------------------------------------------------------
# A `theme` can be loaded from a suitable `YAML` file
# using `load_theme`.^[The function `load_theme` is **exported**.]
load_theme(fpath) = YAML.load_file(fpath)
# Default `theme` information is defined in the `YAML` file 
# `data/default_theme.yml` (located relative to `EpidemicsUtilities`).
# It can be obtained as follows.
# ```julia
# load_theme(pkgdir(EpidemicsUtilities, "data", "default_theme.yml"))
# ```
# The function `create_theme`^[The function `create_theme` is **exported**.]
# generates a plotting theme using the chosen `theme` information.

function create_theme(data)
  # Building length dictionaries
  d_cy = Dict((a[1] => a[2]cy) for a in pairs(data["length_cy"]))
  d_h = Dict((a[1] => a[2]h) for a in pairs(data["length_h"]))
  d_in = Dict((a[1] => a[2]inch) for a in pairs(data["length_inch"]))
  d_mm = Dict((a[1] => a[2]mm) for a in pairs(data["thickness_mm"]))

   # Building sundry other data dictionaries 
  d_lf = data["length_factor"]
  d_op = data["opacity"]

  # Building colour dictionary
  d_cx = Dict((a[1] => parse(Colorant, a[2])) for a in pairs(data["colour_x"]))

# Building colour function
d_c = data["colour"]

function theme_colour(x::T) where {T <: Union{Removal, CRemoval, Infection, PInfection}} 
    return parse(Colorant, d_c[string(T)]) 
  end 

  function theme_colour(x::T) where {T<:AbstractInfectionMarker}
    parse(Colorant, d_c["AbstractInfectionMarker"])
  end
  function theme_colour(x::T) where {T<:AbstractRemovalMarker}
    parse(Colorant, d_c["AbstractRemovalMarker"])
  end
  function theme_colour(x::T) where {T<:AbstractSusceptibleMarker}
    parse(Colorant, d_c["AbstractSusceptibleMarker"])
  end
  
  function theme_colour(x::T) where {T<:AbstractIncident}
    parse(Colorant, d_cx["default"])
  end
  function theme_colour(xl::Vector{T}) where {T<:AbstractIncident}
    return [theme_colour(x) for x in xl]
  end
  
  # Returning resulting `theme` structure as a `NamedTuple`.
  return (
    radius = d_cy["radius"],
    tic=d_cy["tic"]cy,
    height=d_cy["height"]cy,
  
    smradius=d_lf["smradius"] * d_cy["radius"],
  
    bit=d_h["bit"],

    xlab=0cx + d_in["xlab"], 
    yloc=d_in["yloc"],

    boundary=d_mm["boundary"],
    trail=d_mm["trail"],
    broad=d_mm["broad"],
    realized=d_mm["realized"], 
    dormant=d_mm["dormant"],

    blank=d_cx["blank"], 
    scaffold=d_cx["scaffold"],
    forbid1=d_cx["forbid1"], 
    forbid2=d_cx["forbid2"],
    default=d_cx["default"], 
    background=d_cx["background"],

    colour=theme_colour,
    
    region=(context(), rectangle(), fill(parse(Colorant, d_cx["background"])),
      fillopacity(d_op["background"])),
  )
end



# Default drawing themes forming a structure `default_theme`
# ----------------------------------------------------------------
# We define the `default_theme` using these functions.
default_theme_structure = load_theme(pkgdir(EpidemicsUtilities, "data", "default_theme.yml"))
default_theme = create_theme(default_theme_structure)
# This is
# used as a default in what follows, _via_ a keyword argument
# for a given function `fname`.
# ```julia
# fname(..., theme=default_theme)
# ```

