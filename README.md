An attempt at making a lua-driven instrument that
- could read MML
- could read abc
- could be played by aiming the instrument up and down (hi duck game)
- use arbitrary sound (cat piano?!)
music scores could be actual tradable / copiable in-game items that one could add to a songbook

Still WIP:
- only the mml reader works ( using https://github.com/mirrexagon/lua-mml )
- pitch mapping seems to be okay
- notes don't seem to be the right height
- it's slow!!!!!!

- Twinkle twinkle little star comparison: https://www.youtube.com/watch?v=65tWX0BsAwA
- All notes using a vanilla instrument: https://www.youtube.com/watch?v=3QDQ4eotdBY
- All notes using this: https://www.youtube.com/watch?v=JUxa2gB_dF0

I don't wanna put more time into it because the timing issue seems unsolvable (artificially increase the tempo?), i'm too unknowledged to get why notes aren't correct, and I have other projects in mind, but feel free to reuse or whatever (actually I don't know how the licencing of a smaller piece of code in a bigger thing works but check mml.lua's licence)

/spawnitem scriptedbrightpiano

https://framesynthesis.com/experiments/synthesis.js/examples/showcase/
http://starboundcomposer.com/

Art assets belong to chucklefish etc
