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

map("<Ctrl-p>", "E");
map("<Ctrl-n>", "R");

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
