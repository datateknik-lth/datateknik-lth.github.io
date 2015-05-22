Datateknik-LTH Static site
==========================

I Denna branchen befinner sig koden för att generera en kalasnajs statisk sida.

Styling är ganska direkt dragen från github-pages
[Architect tema](https://github.com/jasonlong/architect-theme), fritt fram att
leka med den.

Kurser inkluderas som en submodul, som helst ska uppdateras när en ny version
av sidan genereras så att alla gottigheter kommer med.

## Build & Deploy

För att bygga sidan används [middleman](https://middlemanapp.com/), som är
byggt på ruby, så vill man leka med denna sidan får man ladda ner det och
middleman. Den byggda sidan läggs i build/ som är ett eget git repo som trackar
gh-pages branchen.

För att då bygga en ny version av sidan:

```
git submodule init //Görs första gången, initiera submodulen.
git submodule update --remote --merge //Uppdatera submodulen från master
middleman deploy
```

får man fel under deploy processen kan man dela upp `middleman deploy` i flera
steg.

```
middleman build
cd build
git checkout master // Om man inte redan befinner sig i den branchen.
git push origin // Eller upstream eller vad man nu valt
```

Eftersom detta är en organisationssida så ligger den genererade sidan i master
branchen. Allt jobb med att ändra teman osv ligger i branchen `site`.
