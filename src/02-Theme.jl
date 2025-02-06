# Included script: Themes for plotting (`02-Theme.jl`)
# ====================================================

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
# for given `EpidemicsUtilities` functions `fname` as in
# ```julia
# fname(..., theme=default_theme)
# ```
# Here is a realization of the `default_theme` together with a default colour definition.
function default_colour(x::Removal)            colorant"tan"         end 
function default_colour(x::CRemoval)           colorant"purple"      end 
function default_colour(x::Infection)          colorant"orange"      end 
function default_colour(x::PInfection)         colorant"darkgreen"   end 
function default_colour(x::KilledInfection)    colorant"gray90"      end 
function default_colour(x::NoFlyInfection)     colorant"hotpink2"    end 
function default_colour(x::ExpungedInfection)  colorant"gray50"      end 
function default_colour(x::KilledRemoval)      colorant"burlywood1"  end 
default_theme = (
 radius        =  0.26cy,              smradius      =  0.9 * 0.26cy,
 bit           = -0.02h,               tic           = -0.2cy,
 xlab          =  0cx-0.4inch,         yloc          = 0.25inch,
 figwidth      =  6inch,               figheight     = 3.25inch,
 height        =  0.0cy,              
 boundary      =  1.00mm,              trail         =  0.75mm,
 broad         =  2.00mm,
 activated     =  0.75mm,              dormant       =  0.25mm,
 blank         =  colorant"white",     scaffold      =  colorant"grey",
 NFZ1          =  colorant"steelblue", NFZ2          = colorant"steelblue2",
 NFZ           =  colorant"lightsteelblue", 
 laziestfeasible1 =  colorant"pink",      laziestfeasible2 = "hotpink2",
 laziestfeasible3 =  colorant"deeppink3",
 background    =  colorant"bisque",    legend        =  colorant"black",
 min           =  colorant"red",       max           =  colorant"blue",
 joined        =  colorant"deeppink",  coalesce      =  colorant"black",
 colour        =  default_colour,
 opacity       =  0.3,
)

# Loading a theme
# ---------------
# Here is a useful function for returning all concrete subtypes.
function allconcretesubtypes(T)
    Tl = subtypes(T)
    if isempty(Tl)
        return [T]
    else
        return ∪([allconcretesubtypes(S) for S ∈ Tl]...)
    end
end
const types_portmanteau = Union{allconcretesubtypes(AbstractIncident)...}

# The function `create_theme`^[The function `create_theme` is **exported**.]
# generates a plotting theme using the chosen `theme` information.
function create_theme(data)
  d_cy = Dict((a[1] => a[2]cy)   for a ∈ pairs(data["length_cy"]))                # <1>
  d_h  = Dict((a[1] => a[2]h)    for a ∈ pairs(data["length_h"]))
  d_in = Dict((a[1] => a[2]inch) for a ∈ pairs(data["length_inch"]))
  d_mm = Dict((a[1] => a[2]mm)   for a ∈ pairs(data["thickness_mm"]))

  d_lf = data["length_factor"]                                                    # <2>
  d_op = data["opacity"]

  d_cx = Dict((a[1] => parse(Colorant, a[2])) for a ∈ pairs(data["colour_x"]))    # <3>
  d_c = data["colour"]
  
  function theme_colour(x::T) where {T<:types_portmanteau}                        # <4>
    return parse(Colorant, d_c[string(T)]) end

  function theme_colour(x::T) where {T<:AbstractIncident}
    parse(Colorant, d_cx["default"]) end

  function theme_colour(xl::Vector{T}) where {T<:AbstractIncident}
    return [theme_colour(x) for x ∈ xl] end
    
  function theme_colour(T::DataType)
    if T <: Union{Removal, CRemoval, Infection, PInfection}
      col = parse(Colorant, d_c[string(T)])
    else
      col = parse(Colorant, d_cx["default"])
    end
  return col
  end

  return (                                                                        # <5>
    ϵ        = data["jitter"]["ϵ"],
    figwidth = d_in["figwidth"],   figheight  = d_in["figheight"],
    radius   = d_cy["radius"],     tic        = d_cy["tic"]cy,        
    height   = d_cy["height"]cy, 
    bit      = d_h["bit"],         
    boundary = d_mm["boundary"],   trail      = d_mm["trail"],
    broad=d_mm["broad"], 
    activated = d_mm["activated"], dormant    = d_mm["dormant"],     
    blank    = d_cx["blank"],      scaffold   = d_cx["scaffold"],
    NFZ1     = d_cx["NFZ1"],       NFZ2       = d_cx["NFZ2"],  
    NFZ      = d_cx["NFZ"],  
    laziestfeasible1 = d_cx["laziestfeasible1"],
    laziestfeasible2 = d_cx["laziestfeasible2"],
    laziestfeasible3 = d_cx["laziestfeasible3"],
    default  = d_cx["default"],    background = d_cx["background"],
    legend   = d_cx["legend"],
    min      = d_cx["min"],        max        = d_cx["max"],
    joined   = d_cx["joined"],     coalesce   = d_cx["coalesce"],
    colour   = theme_colour,       opacity    = d_op["background"],
    xlab     = 0cx + d_in["xlab"], yloc       = d_in["yloc"], 
    smradius = d_lf["smradius"] * d_cy["radius"], 
  )
end
# 1. Building length dictionaries;
# 2. Building sundry other data dictionaries; 
# 3. Building a colour dictionary;
# 4. Constructing the `theme_colour` function -- but should this be done offline?!
# 5. The resulting `theme` structure is returned as a `NamedTuple`.
#
#


# Defining axis labels
# --------------------
# There are three variants.
# Note `circlabels2` runs out of characters if population size exceeds `MAXPOP`!

MAXPOP = 20

function timelinelabels_circled(i; n=MAXPOP)          # <1>
  (round(i) > 0 && i ≤ n) ? string(Char(codepoint('①') + round(Int, i) - 1)) : "" end 
function timelinelabels_bracketed(i; n=MAXPOP)        # <2>
  (round(i) > 0 && i ≤ n) ? "[$(round(Int, i))]" : "" end 
function timelinelabel_raw(i; n=MAXPOP)               # <3>
  (0 < i ≤ n) ? string(trunc(Int, i)) : "" end
# 1. Label is positive integer within circle:
# 2. Label is positive integer within square brackets:
# 3. Label is positive number unadorned:
#
#
