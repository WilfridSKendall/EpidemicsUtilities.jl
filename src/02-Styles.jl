#
#
# Types and styles [`02-Styles.jl`]
# =================================
# A union of composite `AbstractIncident` sub-types
# -------------------------------------------------
# We will use a union type, `BasicIncident`^[The tyoe `BasicIncident` is not exported, and may be redundant.], 
# based on composite `AbstractIncident` types.
# This is computed within the module.
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

# ::: {.callout-caution}
# Computation of a new type within module counts as altering internal state!
# Try to avoid this?
# :::



# Useful abbreviations for incidents and markers
# ----------------------------------------------
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# The following abbreviations (or an appropriate subset) are a helpful space-saving measure!
A = AbstractInfection
R = Removal   ; C = CRemoval   
I = Infection ; P = PInfection
IR = InitialRemoved    ; II = InitialInfected    ; IS = InitialSusceptible
CR = ContinuingRemoved ; CI = ContinuingInfected ; CS = ContinuingSusceptible
MIA = MarkerInfectionA ; MRA = MarkerRemovalA
MIB = MarkerInfectionB ; MRB = MarkerRemovalB
  
# Reading in information to define default plotting style
# -------------------------------------------------------
# Load information for a plotting style 
# using `load_style`^[The function `load_style` is **exported**.]
function load_style(fpath) YAML.load_file(fpath) end
# Default_style information can be loaded using
# ```
# load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
# ```

# The function `create_style`^[The function `create_style` is **exported**.]
# generates a plotting style using the loaded information.

function create_style(data)
  d_cy = data["length_cy"]
  d_h  = data["length_h"]
  d_lf = data["length_factor"]
  d_in = data["length_inch"]
  d_mm = data["thickness_mm"]
  d_cx = data["colour_x"]
  d_op = data["opacity"]
  d_c  = data["colour"]
  
  function other_colour(xl::Vector{T}) where T<:AbstractIncident 
    return [other_colour(x) for x in xl]
  end
  
  function other_colour(x::R) parse(Colorant, d_c["Removal"])       end 
  function other_colour(x::C) parse(Colorant, d_c["CRemoval"])      end 
  function other_colour(x::I) parse(Colorant, d_c["Infection"])     end 
  function other_colour(x::P) parse(Colorant, d_c["PInfection"])    end 
  function other_colour(x::T) where T<:AbstractInfectionMarker   parse(Colorant, d_c["AbstractInfectionMarker"]) 
    end
  function other_colour(x::T) where T<:AbstractRemovalMarker     parse(Colorant, d_c["AbstractRemovalMarker"])    
    end
  function other_colour(x::T) where T<:AbstractSusceptibleMarker parse(Colorant, d_c["AbstractSusceptibleMarker"])   
    end
  function other_colour(x::T) where T<:AbstractIncident          parse(Colorant, d_cx["default"])  
    end
    
  returned_style = (
    radius   =  d_cy["radius"]cy,                 smradius =  d_lf["smradius"] * d_cy["radius"]cy,
    bit      =  d_h["bit"]h,                      tic      =  d_cy["tic"]cy,
    xlab     =  0cx+ d_in["xlab"]inch,            yloc     =  d_in["yloc"]inch,
    height   =  d_cy["height"]cy,              
    boundary =  linewidth(d_mm["boundary"]mm),    trail    =  linewidth(d_mm["trail"]mm),
    broad    =  linewidth(d_mm["broad"]mm),
    realized =  linewidth(d_mm["realized"]mm),    dormant   =  linewidth(d_mm["dormant"]mm),
    blank    =  parse(Colorant, d_cx["blank"]),   scaffold  =  parse(Colorant, d_cx["scaffold"]),
    forbid1  =  parse(Colorant, d_cx["forbid1"]), forbid2   =  parse(Colorant, d_cx["forbid2"]), 
    default  =  parse(Colorant, d_cx["default"]), background = parse(Colorant, d_cx["background"]),
    colour   =  other_colour,
    region   =  (context(), rectangle(), fill(parse(Colorant, d_cx["background"])), fillopacity(d_op["background"])),
  )
end



# Default drawing styles forming a structure `default_style`
# ----------------------------------------------------------
# The following named tuple is frequently used
# as a default style specification by
# the `FigureUtilities` functions defined below,
# _via_ a keyword argument `sty`.

# A function `default_colour` uses the type hierarchy to choose colours.
# The initial definition allows things to be vectorized.
function default_colour(xl::Vector{T}) where T<:AbstractIncident 
  return [default_colour(x) for x in xl]
end

default_style = (
  radius   =  0.2cy,               smradius =  0.9 * 0.2cy,
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

# Here are some definitions for the default style.
# A useful list of colours is given in <https://juliagraphics.github.io/Colors.jl/stable/namedcolors/>.
function default_style.colour(x::R) colorant"tan"       end 
function default_style.colour(x::C) colorant"purple"    end 
function default_style.colour(x::I) colorant"orange"    end 
function default_style.colour(x::P) colorant"darkgreen" end 
function default_style.colour(x::T) where T<:AbstractInfectionMarker   colorant"orange" end
function default_style.colour(x::T) where T<:AbstractRemovalMarker     colorant"tan"    end
function default_style.colour(x::T) where T<:AbstractSusceptibleMarker colorant"blue"   end
function default_style.colour(x::T) where T<:AbstractIncident          colorant"white"  end

