# EpidemicsUtilities

Utilities for drawing Epidemics.

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

## TODO list

- [ ] `24-02-2024` Check what functions are used, where they are used, and amend list in the section on principal functions.
- [ ] `24-02-2024` Determine possibilities for deprecation (use `@warn`) and set them up for possible removal.
- [ ] `24-02-2024` Clean up `02-Theme.jl`, so that loaded themes need only to specify variations from a `default-theme.yml`. 
