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
