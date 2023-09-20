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


# Default drawing themes forming a structure `default_theme`
# ----------------------------------------------------------------
# The following `default_theme` can be loaded as follows
# (this is used in `test/test_theme.jl`).
# ```julia
# default_theme_structure = load_theme(pkgdir(EpidemicsUtilities, "data", "default_theme.yml"))
# default_theme = create_theme(default_theme_structure)
# ```
# This is
# used as a default in what follows, _via_ a keyword argument
# for given `EpidemicsUtilities` functions `fname`.
# ```julia
# fname(..., theme=default_theme)
# ```
# Here is a realization of the `default_theme` together with a default colour definition.
function default_colour(x::Removal) colorant"tan"       end 
function default_colour(x::CRemoval) colorant"purple"    end 
function default_colour(x::Infection) colorant"orange"    end 
function default_colour(x::PInfection) colorant"darkgreen" end 
function default_colour(x::T) where T<:AbstractInfectionMarker   colorant"orange" end
function default_colour(x::T) where T<:AbstractRemovalMarker     colorant"tan"    end
function default_colour(x::T) where T<:AbstractSusceptibleMarker colorant"blue"   end
function default_colour(x::T) where T<:AbstractIncident          colorant"white"  end
default_theme = (
 radius     =  0.2cy,               smradius  =  0.9 * 0.2cy,
 bit        = -0.02h,               tic       = -0.2cy,
 xlab       =  0cx-0.4inch,         yloc      = 0.25inch,
 figwidth   =  6inch,               figheight = 3.25inch,
 height     =  0.0cy,              
 boundary   =  1.00mm,              trail     =  0.75mm,
 broad      =  2.00mm,
 realized   =  0.75mm,              dormant   =  0.25mm,
 blank      =  colorant"white",     scaffold  =  colorant"grey",
 forbid1    =  colorant"steelblue", forbid2   =  colorant"lightsteelblue", 
 background =  colorant"bisque",    legend    =  colorant"black",
 colour     =  default_colour,
 opacity    =  0.3,
)

# Loading a theme
# ---------------
# The function `create_theme`^[The function `create_theme` is **exported**.]
# generates a plotting theme using the chosen `theme` information.

function create_theme(data)
  ## Building length dictionaries
  d_cy = Dict((a[1] => a[2]cy) for a in pairs(data["length_cy"]))
  d_h  = Dict((a[1] => a[2]h) for a in pairs(data["length_h"]))
  d_in = Dict((a[1] => a[2]inch) for a in pairs(data["length_inch"]))
  d_mm = Dict((a[1] => a[2]mm) for a in pairs(data["thickness_mm"]))

  ## Building sundry other data dictionaries 
  d_lf = data["length_factor"]
  d_op = data["opacity"]

  ## Building colour dictionary
  d_cx = Dict((a[1] => parse(Colorant, a[2])) for a in pairs(data["colour_x"]))

  ## Building colour dictionary
  d_c = data["colour"]

  function theme_colour(x::T) where {T<:Union{Removal, CRemoval, Infection, PInfection}}
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
    
  function theme_colour(T::DataType)
    if T <: Union{Removal, CRemoval, Infection, PInfection}
      col = parse(Colorant, d_c[string(T)])
    else
      col = parse(Colorant, d_cx["default"])
    end
  return col
  end

  ## Returning resulting `theme` structure as a `NamedTuple`.
  return (
    ϵ        = data["jitter"]["ϵ"],
    figwidth = d_in["figwidth"],   figheight=d_in["figheight"],
    radius   = d_cy["radius"],     tic=d_cy["tic"]cy,        
    height   = d_cy["height"]cy, 
    bit      = d_h["bit"],         
    boundary = d_mm["boundary"],   trail=d_mm["trail"],
    broad=d_mm["broad"],
    realized = d_mm["realized"],   dormant=d_mm["dormant"],     
    blank    = d_cx["blank"],      scaffold=d_cx["scaffold"],
    forbid1  = d_cx["forbid1"],    forbid2=d_cx["forbid2"],  
    default  = d_cx["default"],    background=d_cx["background"],
    legend   = d_cx["legend"],
    colour   = theme_colour,       opacity  = d_op["background"],
    xlab     = 0cx + d_in["xlab"], yloc=d_in["yloc"], 
    smradius = d_lf["smradius"] * d_cy["radius"], 
  )
end


