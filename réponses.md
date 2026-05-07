Ce fichier rassemble les réponses aux questions nécessitant une analyse rédigée, en complément du code source

### Étape 5 : Dessiner un point par ville 

En gros, c'est un problème d'échelle ! Les coordonnées x et y tirées du fichier sont de tout petits nombres à virgule (par exemple -0.12 ou 0.83). Sauf que l'écran, lui, fonctionne avec des pixels entiers (de 0 à 800).

Le souci, c'est qu'en mettant (int) devant les variables dans la boucle draw(), Processing ne s'embête pas à arrondir : il coupe brutalement tout ce qu'il y a après la virgule. Du coup, presque tous ces nombres minuscules se transforment en 0.

Résultats : les 36 551 villes se retrouvent avec les coordonnées exactes (0, 0) et s'empilent toutes les unes sur les autres dans le tout premier pixel, en haut à gauche de la fenêtre. C'est pour ça qu'il n'y a qu'un seul petit point noir visible à l'écran.