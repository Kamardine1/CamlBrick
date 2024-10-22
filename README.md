Le camlbrick est un projet de programmation réalisé en 1ere année de Licence informatique, qui consistait à creer un jeu de casses-briques.
Camlbrick est un jeu de mot entre casse-briques et ocaml.

Information sur le jeu :
========================

Les touches de deplacements sont les fleches directionnelles : droite et gauche.

Les differentes bonus sont :
    Second chance : Permet de pas mourrir si le bonus est activé, bien sur le bonus n'est plus valable une fois mort sauf si vous le re-obtenez à nouveau.
    Croix : Supprime la ligne et la colonne de la brique bonus touché.
    Ghost : Traverse les briques et les detruit en meme temps , le bonus s'annule quand la balle touche le paddle.

Les briques vertes correspondent au bonus, grises aux indestructibles, rouges au doubles ( necessitent de se faire toucher 2 fois) et bleues aux simples.

Pour lancer le jeu, il faudra ouvrir le repertoire dans un Visual Studio Code, aller dans le terminal et taper : ```ocamlrun camlbrick.exe```

Bien-sur, ocaml devra être installer sur votre machine.
