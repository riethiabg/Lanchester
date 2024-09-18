breed[force-units force-unit]

force-units-own[
  force-range
  accuracy
]

globals [
  separated-forces?
  accuracy-deviation
  free-move
  battle-move
]

to setup-globals
  set separated-forces? false
  set accuracy-deviation 0
  set free-move 0
  set battle-move 0
end

to startup
  set initial-blue-forces 2000
  set initial-red-forces 2050
  set blue-accuracy 1
  set red-accuracy 1
  set blue-range max-range + 1
  set red-range max-range + 1
  set blue-area-fire? false
  set red-area-fire? false
  setup
end

to setup
  clear-all
  setup-globals
  setup-forces
  reset-ticks
end

to go
  if battle-finished? [ stop ]
  go-forces
  tick
end

to-report max-range
  report ceiling sqrt ( max-pxcor * max-pxcor + max-pycor * max-pycor )
end

to setup-forces
  spwan-blue-forces
  spawn-red-forces
end

to setup-accuracy [accuracy-mean accuracy-standard-deviation]
  ifelse accuracy-standard-deviation > 0 [
    set accuracy random-normal accuracy-mean accuracy-standard-deviation
  ] [
    set accuracy accuracy-mean
  ]
  set accuracy min list 1 accuracy
  set accuracy max list 0 accuracy
end

to spwan-blue-forces
  create-force-units initial-blue-forces [
    set color blue
    ifelse separated-forces? [
      set xcor random-xcor
      set ycor (max-pycor / 2) + random-float (max-pycor / 2)
      if random 2 = 1 [ set ycor (- ycor) ]
    ] [
      setxy random-xcor random-ycor
    ]
    setup-accuracy blue-accuracy accuracy-deviation
    set force-range blue-range
  ]
end

to spawn-red-forces
  create-force-units initial-red-forces [
    set color red
    ifelse separated-forces? [
      set xcor random-xcor
      set ycor (random-ycor / 2)
    ] [
      setxy random-xcor random-ycor
    ]
    setup-accuracy red-accuracy accuracy-deviation
    set force-range red-range
  ]
end

to go-forces
  ask force-units [ force-unit-attack ]
end

to-report hostile-force-units
  report force-units with [color != [color] of myself]
end

to-report force-unit-select-target
  let target nobody
  let area-fire? ((color = blue and blue-area-fire?)
    or (color = red and red-area-fire?))
  ifelse area-fire? [
    let target-patch one-of patches
    if force-range < max-range [
      set target-patch one-of patches in-radius force-range
    ]
    ask target-patch [
      if any? force-units-here [ set target one-of force-units-here ]
    ]
  ] [
    let targets hostile-force-units
    if force-range < max-range [ set targets targets in-radius force-range ]
    set target min-one-of targets [distance myself]
  ]
  report target
end

to force-unit-attack
  let target force-unit-select-target
  ifelse target != nobody [
    face target
    if random-float 1 < (accuracy ^ (distance target)) [ ask target [ die ] ]
    force-unit-move battle-move
  ] [
    force-unit-move free-move
  ]
end

to force-unit-move [ steps ]
  if steps > 0 [
    if any? hostile-force-units [
      let target min-one-of hostile-force-units [distance myself]
      face target
    ]
    forward steps
  ]
end

to-report battle-finished?
  report not any? turtles with [color = red] or not any? turtles with [color = blue]
end

to scenario-one
  set initial-blue-forces 2000
  set initial-red-forces 2050
  set blue-accuracy 0.95
  set red-accuracy 0.9
  set blue-range max-range + 1
  set red-range max-range + 1
  setup
end

to scenario-two
  set initial-blue-forces 1800
  set blue-accuracy 0.62
  set blue-range 5
  set initial-red-forces 2000
  set red-accuracy 0.6
  set red-range max-range + 1
  clear-all
  set separated-forces? true
  set accuracy-deviation 0.1
  set free-move 1
  set battle-move 0.25
  setup-forces
  reset-ticks
end
@#$#@#$#@
GRAPHICS-WINDOW
205
10
621
427
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
5
10
68
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
71
10
134
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
137
10
200
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
3
273
203
423
Forces Remaining
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"blue" 1.0 0 -13345367 true "" "plot count turtles with [color = blue]"
"red" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"

SLIDER
7
50
179
83
initial-blue-forces
initial-blue-forces
0
5000
2000.0
50
1
NIL
HORIZONTAL

SLIDER
7
85
179
118
initial-red-forces
initial-red-forces
0
5000
2050.0
50
1
NIL
HORIZONTAL

SLIDER
7
120
179
153
blue-accuracy
blue-accuracy
0
1
0.99
0.01
1
NIL
HORIZONTAL

SLIDER
8
155
180
188
red-accuracy
red-accuracy
0
1
1.0
0.01
1
NIL
HORIZONTAL

BUTTON
325
431
428
464
NIL
scenario-one
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
194
180
227
blue-range
blue-range
0
max-range + 1
37.0
0.1
1
NIL
HORIZONTAL

SLIDER
9
232
181
265
red-range
red-range
0
max-range + 1
37.0
0.1
1
NIL
HORIZONTAL

BUTTON
248
431
320
464
NIL
startup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
431
431
534
464
NIL
scenario-two
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
122
430
239
463
blue-area-fire?
blue-area-fire?
1
1
-1000

SWITCH
4
430
119
463
red-area-fire?
red-area-fire?
1
1
-1000

@#$#@#$#@
# Lanchester’s Square Law

An agent-based model to replicate basic Lanchester’s Square Law.

## What Is It

_This section gives a general understanding of what the model is trying to show or explain._

Lanchester (1916) presented a now classic deterministic model of outcomes of ranged combat based on the fighting effectiveness and the troop strengths (i.e., number of soldiers) of two opposing forces. The system of differential equations that came to be known as the Lanchester Square Law for targeted fire is given by:

> _b'(t)= -c r(t) ,  b(0)=b<sub>0</sub> ,_
> _r'(t)= -k b(t) ,  r(0)=r<sub>0</sub> ,_

where _c_ and _k_ are the fighting effectiveness coefficients of the red and blue forces, respectively, and _b_ and _r_ are the troop strengths of the blue and red forces, respectively.

The Lanchester Linear Law describes untargeted area fire:

> _b'(t)= -C b(t) r(t) ,  b(0)=b<sub>0</sub> ,_
> _r'(t)= -K r(t) b(t) ,  r(0)=r<sub>0</sub> ,_

## How It Works

_This section explains what rules the agents use to create the overall behavior of the model._

In the basic model, the agents are placed randomly, targeting occurs without regard for range, and all agents are homogeneous.

To setup, all variables and agents are cleared, and then the square space is filled with blue agent and red agents. To go, in random order, each agent kills exactly one enemy, if an enemy remains to kill.

### Scenario 1: Accuracy as basic heterogeneity

Suppose a force's weaponry will kill an enemy with probability of given accuracy, at a range of 1 unit, with that probability decreasing exponentially with range. Each force unit will choose the closest target.

**This modification alters the outcome of the battle**: the blue forces can overcome the numerically larger red forces with their technological superiority.

### Scenario 2: Further deviation from the Lanchester model

The red force is attacked from two sides by a blue force with only 90% their troop strength. Blue force weapons have mean accuracy of 0.62 at 1 unit distance, whereas red force weapons have mean accuracy of 0.60 at the same range, with individuals’ accuracy varying according to a normal distribution with a standard deviation of 0.1. Blue forces are short on ammunition, so they have orders to only fire from a maximum range of 5 units. The red forces, meanwhile, can fire at any range. If a soldier fires, they can move only 25% the distance that they could move otherwise.

**This more complex model yields a slight advantage to the blue forces**: over 100 replicates, 68 result in a blue victory. This result is statistically significant (_p<0.001_).


## How To Use It

_This section explains how to use the model, including a description of each of the items in the interface tab._

Running many iterations of this simulation, the mean number of agents remaining once one side has been killed is equal to that predicted by Lanchester’s Square Law.

The **setup** button starts a new setup based on the interface and global variables.
The **go** button starts the simulation.
The **step** button executes a single tick (step) only.
The **startup** button prepares a default scenario. 

Press one of the buttons **scenario-one** or **scenario-two** to set up the corresponding scenario.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## Credits and References

Christopher W. Weimer, J. O. Miller, Raymond R. Hill. Agent-Based Modeling: An Introduction and Primer. Proceedings of the 2016 Winter Simulation Conference, T. M. K. Roeder, P. I. Frazier, R. Szechtman, E. Zhou, T. Huschka, and S. E. Chick, eds.
http://simulation.su/uploads/files/default/2016-weimer-miller-hill.pdf
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
