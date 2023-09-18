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
  d_cy = data["length_cy"]      ;   d_h  = data["length_h"]
  d_lf = data["length_factor"]  ;   d_in = data["length_inch"]
  d_mm = data["thickness_mm"]   ;   d_cx = data["colour_x"]
  d_op = data["opacity"]        ;   d_c  = data["colour"]
  
  theme_colour(x::Removal)    = parse(Colorant, d_c["Removal"])
  theme_colour(x::CRemoval)   = parse(Colorant, d_c["CRemoval"])
  theme_colour(x::Infection)  = parse(Colorant, d_c["Infection"])
  theme_colour(x::PInfection) = parse(Colorant, d_c["PInfection"])
  function theme_colour(xl::Vector{T}) where T<:AbstractIncident 
    return [theme_colour(x) for x in xl]
  end
  function theme_colour(x::T) where T<:AbstractInfectionMarker   
    parse(Colorant, d_c["AbstractInfectionMarker"]) 
  end
  function theme_colour(x::T) where T<:AbstractRemovalMarker     
    parse(Colorant, d_c["AbstractRemovalMarker"])    
  end
  function theme_colour(x::T) where T<:AbstractSusceptibleMarker 
    parse(Colorant, d_c["AbstractSusceptibleMarker"])   
  end
  function theme_colour(x::T) where T<:AbstractIncident          
    parse(Colorant, d_cx["default"])  
  end

# The resulting `theme` structure is returned as a `NamedTuple`.
  returned_theme = (
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
    colour   =  theme_colour,
    region   =  (context(), rectangle(), fill(parse(Colorant, d_cx["background"])),
                 fillopacity(d_op["background"])),
  )
end



# Default drawing themes forming a structure `default_theme`
# ----------------------------------------------------------------
# We define the `default_theme` using these functions.
default_theme_structure = load_theme(pkgdir(EpidemicsUtilities, "data", "default_theme.yml"))
default_theme           = create_theme(default_theme_structure)
# This is
# used as a default in what follows, _via_ a keyword argument
# for a given function `fname`.
# ```julia
# fname(..., theme=default_theme)
# ```

