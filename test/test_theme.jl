default_theme = EpidemicsUtilities.default_theme

# Useful abbreviations for incidents and markers
# ----------------------------------------------
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# The following abbreviations (or an appropriate subset) are a helpful space-saving measure!
A = AbstractInfection
R = Removal;
C = CRemoval;
I = Infection;
P = PInfection;
IR = InitialRemoved;
II = InitialInfected;
IS = InitialSusceptible;
CR = ContinuingRemoved;
CI = ContinuingInfected;
CS = ContinuingSusceptible;
MIA = MarkerInfectionA;
MRA = MarkerRemovalA;
MIB = MarkerInfectionB;
MRB = MarkerRemovalB;

data = load_theme(pkgdir(EpidemicsUtilities, "data", "default_theme.yml"))
theme = create_theme(data)


@testset "Check theme (including colours)" begin

  for tag in ["radius", "smradius",
    "bit", "tic",
    "xlab", "yloc",
    "height",
  ]
    @test default_theme[Symbol(tag)] == theme[Symbol(tag)]
  end

  for tag in ["boundary", "trail",
    "broad",
    "realized", "dormant"
  ]
    @test string(default_theme[Symbol(tag)]) == string(theme[Symbol(tag)])
  end
  for tag in [Removal(0.0, 1), CRemoval(0.0, 1),
    Infection(0.0, 1, 2), PInfection(0.0, 1, 2),
    InitialInfected(0.0, 1),
    InitialRemoved(0.0, 1),
    InitialSusceptible(0.0, 1),
  ]
    @test default_theme.colour(tag) == theme.colour(tag)
  end

end
