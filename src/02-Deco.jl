# Deco[rations] for plotting (`02-Deco.jl`)
# =========================================
  
# Reading in information to define default plotting `deco`
# --------------------------------------------------------
# A `deco` can be loaded from a suitable `YAML` file
# using `load_deco`.^[The function `load_deco` is **exported**.]
load_deco(fpath) = YAML.load_file(fpath)
# Default deco[ration] information is defined in the `YAML` file 
# `data/default_deco.yml` (located relative to `EpidemicsUtilities`).
# It can be obtained as follows.
# ```julia
# load_deco(pkgdir(EpidemicsUtilities, "data", "default_deco.yml"))
# ```
# The function `create_deco`^[The function `create_deco` is **exported**.]
# generates a plotting deco using the chosen deco[ration] information.

function create_deco(data)
  d_cy = data["length_cy"]      ;   d_h  = data["length_h"]
  d_lf = data["length_factor"]  ;   d_in = data["length_inch"]
  d_mm = data["thickness_mm"]   ;   d_cx = data["colour_x"]
  d_op = data["opacity"]        ;   d_c  = data["colour"]
  
  deco_colour(x::Removal)    = parse(Colorant, d_c["Removal"])
  deco_colour(x::CRemoval)   = parse(Colorant, d_c["CRemoval"])
  deco_colour(x::Infection)  = parse(Colorant, d_c["Infection"])
  deco_colour(x::PInfection) = parse(Colorant, d_c["PInfection"])
  function deco_colour(xl::Vector{T}) where T<:AbstractIncident 
    return [deco_colour(x) for x in xl]
  end
  function deco_colour(x::T) where T<:AbstractInfectionMarker   
    parse(Colorant, d_c["AbstractInfectionMarker"]) 
  end
  function deco_colour(x::T) where T<:AbstractRemovalMarker     
    parse(Colorant, d_c["AbstractRemovalMarker"])    
  end
  function deco_colour(x::T) where T<:AbstractSusceptibleMarker 
    parse(Colorant, d_c["AbstractSusceptibleMarker"])   
  end
  function deco_colour(x::T) where T<:AbstractIncident          
    parse(Colorant, d_cx["default"])  
  end

# The resulting `deco` structure is returned as a `NamedTuple`.
  returned_deco = (
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
    colour   =  deco_colour,
    region   =  (context(), rectangle(), fill(parse(Colorant, d_cx["background"])),
                 fillopacity(d_op["background"])),
  )
end



# Default drawing deco[rations] forming a structure `default_deco`
# ----------------------------------------------------------------
# We define the `default_deco` using these functions.
default_deco_structure = load_deco(pkgdir(EpidemicsUtilities, "data", "default_deco.yml"))
default_deco           = create_deco(default_deco_structure)
# This is
# used as a default in what follows, _via_ a keyword argument
# for a given function `fname`.
# ```julia
# fname(..., deco=default_deco)
# ```

