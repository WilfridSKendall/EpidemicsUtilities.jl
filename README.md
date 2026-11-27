# EpidemicsUtilities.jl

Utilities for drawing Epidemics.

Requirements
------------

The package is implemented using `Julia` 1.13.3 (as of `23-11-2026`)

Currently installed as developer package.

## Caveats
This is one of the first `julia` packages I have written.

1. Its documentation system is unorthodox; 
  it combines all source files into a single `Quarto` file
  and then processes that.
  In a future version I will replace by the conventional
  `Documenter` process driven by docstrings.

2. Graphics uses the `Compose` package.
  I hope eventually to re-write `EpidemicsUtilities.jl` based on a graphics
  package which is more actively maintained. 

1. Further to the previous point, `Gadfly` and more specifically `Compose` require the package `JSON` to be at version `v1.13.4` or earlier. Presently this is dealt with by pinning `JSON` to version `v0.21.4` in the `docs` environment.



----------

## Principal functions

- `draw_evolution!`
- `table_trajectories1`
- `draw_innovation!`
- `EpidemicsCFTP.is_correct_LFE` 
- `EpidemicsCFTP.is_correct_NFZ` 
- `EpidemicsCFTP.resulting_cremovals` from `test.qmd`
- `EpidemicsCFTP.inactive_removals`  from `test.qmd`
- `EpidemicsCFTP.last_feasible_evolution` from `test.qmd`

## Options

Options are selected from the following, typically by specialised imports. (These are defined in `04-Nodes.jl`).

```julia
const TOP        = 0b00000000001 ;
const BOUNDARIES = 0b00000000010 ; const REGIONS    = 0b00000000100 ;
const INFECTIONS = 0b00000001000 ; const REMOVALS   = 0b00000010000 ;
const CREMOVALS  = 0b00000100000 ;
const ACTIVATED  = 0b00001000000 ;
const LFET       = 0b00010000000 ;
const LFER       = 0b00100000000 ; const LFEN       = 0b01000000000 ;
const NFZ        = 0b10000000000 ;
const ELEMENTS   = INFECTIONS  | REMOVALS | CREMOVALS ;
const BASIC      = ACTIVATED | ELEMENTS ;
const ALL        = TOP  | BOUNDARIES | REGIONS | BASIC ;
const MOST       = BOUNDARIES | REGIONS | BASIC ;
const LFE        = LFET | LFER | LFEN ;
```
