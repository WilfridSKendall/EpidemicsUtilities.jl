import EpidemicsUtilities: date, version
println("EpidemicsUtilities version $version, compiled on $date")

using EpidemicsCFTP
using EpidemicsUtilities
using Test
using Compose, Colors

include("test_theme.jl")
