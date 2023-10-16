# Basic image template elements (`03-Template.jl`)
# ================================================
# ::: {.callout-tip}
# As noted above, consider using `Gadfly` for axes and coordinates.
# :::
# Simulation plots are based on a function 
# `time_axis`^[The function `time_axis` is used in the exported function `scaffolding` defined in this section.]
# which draws the process time axis, furnished with tick marks at integer times.
# Note, both here and following, the careful use made of graphics area units (`cx`, `cy`).
function time_axis(duration; theme=default_theme) # DEPRECATED
  labellocs = [(x)cx for x in 0:duration]
  step = 10^floor(Int, log10(duration))
  tic1 = [(((x)cx, theme.height), ((x)cx, theme.height + theme.tic)) for x in 0:1.0step:duration]
  tic2 = [(((x)cx, theme.height), ((x)cx, theme.height + theme.tic)) for x in 0:0.5step:duration]
  tic3 = [(((x)cx, theme.height), ((x)cx, theme.height + 0.5theme.tic)) for x in 0:0.1step:duration]

  return (context(),
    (context(), text(labellocs, [theme.height + theme.yloc], ["$i" for i in 0:duration],
        [hcenter], [vcenter]), fontsize(5pt), font("TimesRoman"),),
    (context(), line([(0cx, theme.height), ((duration)cx, theme.height)]),
      stroke(theme.scaffold), linewidth(0.5mm)),
    (context(), line(tic1), stroke(theme.scaffold), linewidth(0.2mm)),
    (context(), line(tic2), stroke(theme.scaffold), linewidth(0.1mm)),
    (context(), line(tic3), stroke(theme.scaffold), linewidth(0.1mm)),)
end

# A function 
# `time_threads`^[The function `time_threads` is used in the exported function `scaffolding` defined in this section.]
# draws time-lines as threads labelled by circled integers.
function time_threads(duration, population; theme=default_theme) # DEPRECATED
  circlabels = [string(Char(0x00002460 + i - 1)) for i in 1:population]

  (context(), # Returned value of function!
    (context(), text([theme.xlab], [(k)cy for k in 1:population], circlabels,
        [hleft], [vcenter]), fontsize(10pt), font("TimesRoman"),),
    (context(), line([[(0cx, (k)cy), ((duration)cx, (k)cy)] for k in 1:population]),
      stroke(theme.scaffold), linewidth(0.5mm),),)
end
#
# ::: {.callout-caution}
# Here the definition of `circlabels` below needs to be changed if `population > MAXPOP=20`,
# as unicode then runs out of circled integers!
# (Figure out how to use 
# one of the many ideas in 
# <https://tex.stackexchange.com/questions/7032/good-way-to-make-textcircled-numbers>.)
# :::


# These two functions are put together in a third function
# `scaffolding`^[The function `scaffolding` is **exported**.],
# which constructs the fundamental scaffolding for graphs of epidemics (axes, time lines _etc_).
function scaffolding(duration, population; theme=default_theme) # DEPRECATED
  region = (context(), rectangle(), fill(theme.background), fillopacity(theme.opacity))
  return (context(), region, time_axis(duration, theme=theme),
    time_threads(duration, population, theme=theme))
end


