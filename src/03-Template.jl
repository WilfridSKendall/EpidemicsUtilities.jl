#
#
# Basic image template elements [`03-Template.jl`]
# ================================================
# We need a function 
# `time_axis`^[The function `time_axis` is used in the exported function `scaffolding` defined in this section.]
# to draw the time axis, furnished with tick marks at integer times.
# Note, both here and following, the careful use made of graphics area units (`cx`, `cy`).
function time_axis(duration; sty=defaultstyle)
  labellocs = [(x)cx for x in 0:duration]
  step = 10^floor(Int, log10(duration))
  tic1  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:1.0step:duration]
  tic2  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:0.5step:duration]
  tic3  = [(((x)cx,sty.height), ((x)cx, sty.height+0.5sty.tic)) for x in 0:0.1step:duration]

  (context(), # Returned value of function!
    (context(), text(labellocs, [sty.height + sty.yloc], ["$i" for i in 0:duration], 
      [hcenter], [vcenter]), fontsize(5pt), font("TimesRoman"), ),
    (context(), line([(0cx, sty.height), ((duration)cx, sty.height)]),
      stroke(sty.scaffold), linewidth(0.5mm) ),
    (context(), line(tic1), stroke(sty.scaffold), linewidth(0.2mm)),
    (context(), line(tic2), stroke(sty.scaffold), linewidth(0.1mm)),
    (context(), line(tic3), stroke(sty.scaffold), linewidth(0.1mm)), )
end

# Now we define a function 
# `time_threads`^[The function `time_threads` is used in the exported function `scaffolding` defined in this section.]
# drawing time-lines as threads labelled by circled integers.
#
# ::: {.callout-caution}
# The definition of `circlabels` below needs to be changed if `population > MAXPOP=20`,
# as unicode then runs out of circled integers!
# (Figure out how to use 
# one of the many ideas in 
# <https://tex.stackexchange.com/questions/7032/good-way-to-make-textcircled-numbers>.)
# :::
function time_threads(duration, population; sty=defaultstyle)
  circlabels   = [string(Char(0x00002460+i-1)) for i in 1:population]

  (context(), # Returned value of function!
    (context(), text([sty.xlab], [(k)cy for k in 1:population], circlabels,
      [hleft], [vcenter]), fontsize(10pt), font("TimesRoman"), ),
    (context(), line([[(0cx, (k)cy), ((duration)cx, (k)cy)] for k in 1:population]), 
      stroke(sty.scaffold), linewidth(0.5mm), ), )
end

# These two functions are put together in a third function
# `scaffolding`^[The function `scaffolding` is **exported**.],
# which constructs scaffolding for graphs of epidemics (axes, time lines _etc_).
function scaffolding(duration, population; sty=defaultstyle)
  (context(), sty.region, time_axis(duration, sty=sty), 
              time_threads(duration, population, sty=sty))
end


