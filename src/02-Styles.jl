# Styles for plotting (`02-Styles.jl`)
# ====================================
  
# Reading in information to define default plotting style
# -------------------------------------------------------
# A plotting style can be loaded from a suitable `YAML` file
# using `load_style`.^[The function `load_style` is **exported**.]
load_style(fpath) = YAML.load_file(fpath)
# Default style information is defined in the `YAML` file 
# `data/default_style.yml` (located relative to `EpidemicsUtilities`).
# It can be obtained as follows.
# ```julia
# load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
# ```
# The function `create_style`^[The function `create_style` is **exported**.]
# generates a plotting style using the chosen style information.

function create_style(data)
  d_cy = data["length_cy"]      ;   d_h  = data["length_h"]
  d_lf = data["length_factor"]  ;   d_in = data["length_inch"]
  d_mm = data["thickness_mm"]   ;   d_cx = data["colour_x"]
  d_op = data["opacity"]        ;   d_c  = data["colour"]
  
  style_colour(x::Removal)    = parse(Colorant, d_c["Removal"])
  style_colour(x::CRemoval)   = parse(Colorant, d_c["CRemoval"])
  style_colour(x::Infection)  = parse(Colorant, d_c["Infection"])
  style_colour(x::PInfection) = parse(Colorant, d_c["PInfection"])
  function style_colour(xl::Vector{T}) where T<:AbstractIncident 
    return [style_colour(x) for x in xl]
  end
  function style_colour(x::T) where T<:AbstractInfectionMarker   
    parse(Colorant, d_c["AbstractInfectionMarker"]) 
  end
  function style_colour(x::T) where T<:AbstractRemovalMarker     
    parse(Colorant, d_c["AbstractRemovalMarker"])    
  end
  function style_colour(x::T) where T<:AbstractSusceptibleMarker 
    parse(Colorant, d_c["AbstractSusceptibleMarker"])   
  end
  function style_colour(x::T) where T<:AbstractIncident          
    parse(Colorant, d_cx["default"])  
  end

# The resulting style structure is returned as a `NamedTuple`.
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
    colour   =  style_colour,
    region   =  (context(), rectangle(), fill(parse(Colorant, d_cx["background"])),
                 fillopacity(d_op["background"])),
  )
end



# Default drawing styles forming a structure `default_style`
# ----------------------------------------------------------
# We define the style `default_style` using these functions.
default_style_structure = load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
default_style           = create_style(default_style_structure)
# This is
# used as a default in what follows, _via_ a keyword argument
# for a given function `fname`.
# ```julia
# fname(..., sty=default_style)
# ```

