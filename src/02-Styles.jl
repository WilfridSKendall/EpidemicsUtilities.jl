#
#
# Types and styles [`02-Styles.jl`]
# =================================
# A union of composite `AbstractIncident` sub-types
# -------------------------------------------------
# We will use a union type, `BasicIncident`, based on composite `AbstractIncident` types.
# This is computed within the module.
#
# ::: {.callout-caution}
# Computation of a new type within module counts as altering internal state!
# Try to avoid this?
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


# Reading in a new set of styles
# ------------------------------
# A possible location for the `YAML` file 
# (relative to `EpidemicsUtilities/src`) is
# `../data/default_style.yml`
function load_style(fpath)
  YAML.load_file(fpath)
end
# We use this to load data for the `default style`.
data = load_style("data/default_style.yml")


# #### Sundries ...
# function load_style(fpath)
#   data = YAML.load_file(fpath)
#   colour = Dict{Symbol, RGB}()
#   for item in data["colour_x"]
#     key = Symbol(item[1])
#     #key = item[1]
#     value = parse(Colorant, item[2])
#     colour[key] = value
#   end
#   return colour
# end

# note
# julia> keys=(:a,:b)
# 
# julia> values=(1, "white")
# 
# julia> (; zip(keys, values)...)
# (a = 1, b = "white")



# Colours related to various incidents, using function `colour`
# -------------------------------------------------------------
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# These abbreviations (or an appropriate subset) are often repeated on scripts.
A = AbstractInfection
R = Removal   ; C = CRemoval   
I = Infection ; P = PInfection
IR = InitialRemoved    ; II = InitialInfected    ; IS = InitialSusceptible
CR = ContinuingRemoved ; CI = ContinuingInfected ; CS = ContinuingSusceptible
MIA = MarkerInfectionA ; MRA = MarkerRemovalA
MIB = MarkerInfectionB ; MRB = MarkerRemovalB

# A function `default_colour` associates these to colours, using the type hierarchy.
# A useful list of colours is given in <https://juliagraphics.github.io/Colors.jl/stable/namedcolors/>.
function default_colour(x::R) colorant"tan"       end 
function default_colour(x::C) colorant"purple"    end 
function default_colour(x::I) colorant"orange"    end 
function default_colour(x::P) colorant"darkgreen" end 
function default_colour(x::T) where T<:AbstractInfectionMarker   colorant"orange" end
function default_colour(x::T) where T<:AbstractRemovalMarker     colorant"tan"    end
function default_colour(x::T) where T<:AbstractSusceptibleMarker colorant"blue"   end
function default_colour(x::T) where T<:AbstractIncident          colorant"white"  end

function default_colour(xl::Vector{T}) where T<:AbstractIncident 
  return [default_colour(x) for x in xl]
end

# Default drawing styles forming a structure `default_style`
# --------------------------------------------------------
# The following named tuple is frequently used
# as a default style specification by
# the `FigureUtilities` functions defined below,
# _via_ a keyword argument `sty`.
#
# ::: {.callout-note}
# See if this can be read-in from a data-file instead: investigate `YAML.jl`.
# :::

d_cy = data["length_cy"]
default_style = (
  radius   =  d_cy["radius"]cy,               smradius =  0.9 * 0.2cy,
  bit      = -0.02h,               tic      = -0.2cy,
  xlab     =  0cx-0.4inch,         yloc     = 0.25inch,
  height   =  0.0cy,              
  boundary =  linewidth(1.00mm),   trail    =  linewidth(0.75mm),
  broad    =  linewidth(2.00mm),
  realized =  linewidth(0.75mm),   dormant   =  linewidth(0.25mm),
  blank    =  colorant"white",     scaffold  =  colorant"grey",
  forbid1  =  colorant"steelblue", forbid2   =  colorant"lightsteelblue", 
  default  =  colorant"white",     background = colorant"bisque",
  colour   =  default_colour,
  region   =  (context(), rectangle(), fill(colorant"bisque"), fillopacity(0.3)),
)

