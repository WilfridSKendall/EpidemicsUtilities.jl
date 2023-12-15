import EpidemicsUtilities: date, version
println("EpidemicsUtilities version $version, compiled on $date")

using EpidemicsCFTP
using EpidemicsUtilities
using Test
using Compose, Colors

include("01-test_theme.jl")
