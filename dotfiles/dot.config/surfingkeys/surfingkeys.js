const {
  mapkey,
  map,
  iunmap,
  Front,
  Hints,
} = api;

//Hints.characters = "asdfgqwertzxcvb";  // Default
Hints.characters = "jklfdsahguiorewtymnpbvcxz";
// Hints.numericHints = true;

settings.hintAlign = "left";
// settings.omnibarPosition = "bottom";  // Default: "middle"
// settings.focusFirstCandidate = true;
settings.scrollStepSize = 140;  // Default: 70

map("gt", "R");
map("gT", "E");

map("<", "<<");
map(">", ">>");

map("p", "cc");
map("u", "X");

map("H", "S");
map("L", "D");

map("F", "af");

map("<Ctrl-u>", "e");
map("<Ctrl-d>", "d");

mapkey("b", 'Choose a tab with omnibar', () => {
    Front.openOmnibar({type: "Tabs"});
});

iunmap(":");

// https://github.com/brookhong/Surfingkeys/issues/2285#issuecomment-2868207432
iunmap("<Ctrl-a>");
