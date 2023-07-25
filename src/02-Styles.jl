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

# Colours related to various incidents, using function `csty`
# -----------------------------------------------------------
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# These abbreviations (or an appropriate subset) are often repeated on scripts.
A = AbstractInfection
R = Removal   ; C = CRemoval   
I = Infection ; P = PInfection
IR = InitialRemoved    ; II = InitialInfected    ; IS = InitialSusceptible
CR = ContinuingRemoved ; CI = ContinuingInfected ; CS = ContinuingSusceptible
MIA = MarkerInfectionA ; MRA = MarkerRemovalA
MIB = MarkerInfectionB ; MRB = MarkerRemovalB

# A function `csty` associates these to colours, using the type hierarchy.
# A useful list of colours is given in <https://juliagraphics.github.io/Colors.jl/stable/namedcolors/>.
function csty(x::R) colorant"tan"       end 
function csty(x::C) colorant"purple"    end 
function csty(x::I) colorant"orange"    end 
function csty(x::P) colorant"darkgreen" end 
function csty(x::T) where T<:AbstractInfectionMarker   colorant"orange"      end
function csty(x::T) where T<:AbstractRemovalMarker     colorant"tan"         end
function csty(x::T) where T<:AbstractSusceptibleMarker colorant"blue"        end
function csty(x::T) where T<:AbstractIncident          colorant"white"       end

function csty(xl::Vector{T}) where T<:AbstractIncident 
  return [csty(x) for x in xl]
end

# Default drawing styles forming a structure `defaultstyle`
# --------------------------------------------------------
# The following default style structure is frequently used by
# the `FigureUtilities` functions defined below,
# _via_ a keyword argument `sty`.
#
# ::: {.callout-note}
# See if this can be read-in from a data-file instead: investigate `YAML.jl`.
# :::
defaultstyle = (
  radius   =  0.2cy,               smradius =  0.9 * 0.2cy,
  bit      = -0.02h,               tic      = -0.2cy,
  xlab     =  0cx-0.4inch,         yloc     = 0.25inch,
  height   =  0.0cy,              
  boundary =  linewidth(1.00mm),   trail    =  linewidth(0.75mm),
  broad    =  linewidth(2.00mm),
  realized =  linewidth(0.75mm),   dormant  =  linewidth(0.25mm),
  blank    =  colorant"white",     scaffold =  colorant"grey",
  forbid1  =  colorant"steelblue", forbid2  =  colorant"lightsteelblue", 
  region   =  (context(), rectangle(), fill(colorant"bisque"), fillopacity(0.3)),
  colour   =  csty,
)

