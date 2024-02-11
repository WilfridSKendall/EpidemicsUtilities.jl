default_theme = EpidemicsUtilities.default_theme

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
    "activated", "dormant"
  ]
    @test string(default_theme[Symbol(tag)]) == string(theme[Symbol(tag)])
  end
  for tag in [Removal(0.0, 1), CRemoval(0.0, 1),
    Infection(0.0, 1, 2), PInfection(0.0, 1, 2),
  ]
    @test default_theme.colour(tag) == theme.colour(tag)
  end

end
