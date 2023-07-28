default_style = EpidemicsUtilities.default_style

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
  



# This function creates an alternative style from the dataset.

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
  
data = load_style(pkgdir(EpidemicsUtilities, "data", "default_style.yml"))
style = create_style(data)


@testset "Check style (including colours)" begin

for tag in ["radius",  "smradius",
            "bit",     "tic",
            "xlab",    "yloc",
            "height",
            ]
  #cue = tag * ":" * (" "^(19-length(tag)))
  #println(cue, default_style[Symbol(tag)] == style[Symbol(tag)])
  @test default_style[Symbol(tag)] == style[Symbol(tag)]
end

for tag in ["boundary", "trail",
            "broad",
            "realized", "dormant",
            "region",
            ]
  #cue = tag * ":" * (" "^(19-length(tag)))
  #println(cue, string(default_style[Symbol(tag)]) == string(style[Symbol(tag)]))
  @test string(default_style[Symbol(tag)]) == string(style[Symbol(tag)])
end
for tag in [Removal(0.0,1),     CRemoval(0.0,1),
            Infection(0.0,1,2), PInfection(0.0,1,2),
            InitialInfected(0.0,1),
            InitialRemoved(0.0,1),
            InitialSusceptible(0.0,1),
            ]
  #cue = string(tag) * ":" * (" "^(19-length(string(tag))))
  #println(cue, default_style.colour(tag) == style.colour(tag))
  @test default_style.colour(tag) == style.colour(tag)
end

end
