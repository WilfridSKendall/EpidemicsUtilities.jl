#
#
# [`02-Styles.jl`] Styles for plotting
# ====================================
  
# Reading in information to define default plotting style
# -------------------------------------------------------
# A plotting style can be loaded from a suitable `YAML` file
# using `load_style`.^[The function `load_style` is **exported**.]
load_style(fpath) = YAML.load_file(fpath)
# Default_style information can then be  using (for example) as follows.
# ```{julia}
# load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
# ```
# Note that the default style is determined by a `YAML` file located 
# (as in the above example) at `data/default_style.yml` relative to the 
# package `EpidemicsUtilities`.
#
# The function `create_style`^[The function `create_style` is **exported**.]
# generates a plotting style using the loaded information.

function create_style(data)
  d_cy = data["length_cy"]      ;   d_h  = data["length_h"]
  d_lf = data["length_factor"]  ;   d_in = data["length_inch"]
  d_mm = data["thickness_mm"]   ;   d_cx = data["colour_x"]
  d_op = data["opacity"]        ;   d_c  = data["colour"]
  
  function other_colour(xl::Vector{T}) where T<:AbstractIncident 
    return [other_colour(x) for x in xl]
  end
  
  other_colour(x::Removal)    = parse(Colorant, d_c["Removal"])
  other_colour(x::CRemoval)   = parse(Colorant, d_c["CRemoval"])
  other_colour(x::Infection)  = parse(Colorant, d_c["Infection"])
  other_colour(x::PInfection) = parse(Colorant, d_c["PInfection"])

  function other_colour(x::T) where T<:AbstractInfectionMarker   
    parse(Colorant, d_c["AbstractInfectionMarker"]) 
  end
  function other_colour(x::T) where T<:AbstractRemovalMarker     
    parse(Colorant, d_c["AbstractRemovalMarker"])    
  end
  function other_colour(x::T) where T<:AbstractSusceptibleMarker 
    parse(Colorant, d_c["AbstractSusceptibleMarker"])   
  end
  
  function other_colour(x::T) where T<:AbstractIncident          
    parse(Colorant, d_cx["default"])  
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
    region   =  (context(), rectangle(), fill(parse(Colorant, d_cx["background"])),
                 fillopacity(d_op["background"])),
  )
end



# Default drawing styles forming a structure `default_style`
# ----------------------------------------------------------
# We define the style `default_style` using these functions, which is
# referred to as a default style in the following by keyword arguments
# of the following form.
# ```{julia}
# fname(..., sty=default_style)
# ```
default_style_name = load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
default_style      = create_style(default_style_name)

