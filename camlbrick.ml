(**
Ce module Camlbrick représente le noyau fonctionnel du jeu de casse-brique nommé <b>camlbrick</b>
(un jeu de mot entre le jeu casse-brique et le mot ocaml).

Le noyau fonctionnel consiste à réaliser l'ensemble des structures et autres fonctions capables
d'être utilisées par une interface graphique. Par conséquent, dans ce module il n'y a aucun aspect visuel ! Vous pouvez utiliser le mode console.

Le principe du jeu de casse-brique consiste à faire disparaître toutes les briques d'un niveau
en utilisant les rebonds d'une balle depuis une raquette contrôlée par l'utilisateur.

@author Antoine GOY
@author Olivier LEMAIRE
@author Nicolas ITEY
@author Kamardine MIRGHANE MOHAMED

@version 1
*)

(** Compteur utilisé en interne pour afficher le numéro de la frame du jeu vidéo. 
Vous pouvez utiliser cette variable en lecture, mais nous ne devez pas modifier
sa valeur! *)
let frames = ref 0;;

(**
  type énuméré représentant les couleurs gérables par notre moteur de jeu. Vous ne pouvez pas modifier ce type!
  @deprecated Ne pas modifier ce type! 
*)
type t_camlbrick_color = WHITE | BLACK | GRAY | LIGHTGRAY | DARKGRAY | BLUE | RED | GREEN | YELLOW | CYAN | MAGENTA | ORANGE | LIME | PURPLE;;

(**
  Cette structure regroupe tous les attributs globaux,
  pour paramétrer notre jeu vidéo.
  <b>Attention:</b> Il doit y avoir des cohérences entre les différents paramètres:
  <ul>
  <li> la hauteur totale de la fenêtre est égale à la somme des hauteurs de la zone de briques du monde et
  de la hauteur de la zone libre.</li>
  <li>la hauteur de la zone des briques du monde est un multiple de la hauteur d'une seule brique. </li>
  <li>la largeur du monde est un multiple de la largeur d'une seule brique. </li>
  <li>initialement la largeur de la raquette doit correspondre à la taille moyenne.</li>
  <li>la hauteur initiale de la raquette doit être raisonnable et ne pas toucher un bord de la fenêtre.</li>
  <li>La variable time_speed doit être strictement positive. Et représente l'écoulement du temps.</li>
  </ul>
*)
type t_camlbrick_param = {
  world_width : int; (** largeur de la zone de dessin des briques *)
  world_bricks_height : int; (** hauteur de la zone de dessin des briques *)
  world_empty_height : int; (** hauteur de la zone vide pour que la balle puisse évoluer un petit peu *)

  brick_width : int; (** largeur d'une brique *)
  brick_height : int; (** hauteur d'une brique *)

  paddle_init_width : int; (** largeur initiale de la raquette *)
  paddle_init_height : int; (** hauteur initiale de la raquette *)

  time_speed : int ref; (** indique l'écoulement du temps en millisecondes (c'est une durée approximative) *)
};;

(** Enumeration des différents types de briques. 
  Vous ne devez pas modifier ce type.    
*)
type t_brick_kind = BK_empty | BK_simple | BK_double | BK_block | BK_bonus;;

(**
  Cette fonction renvoie le type de brique pour représenter les briques de vide.
  C'est à dire, l'information qui encode l'absence de brique à un emplacement sur la grille du monde.
  @return Renvoie le type correspondant à la notion de vide.
  @deprecated  Cette fonction est utilisé en interne.    
*)
let make_empty_brick() : t_brick_kind = 
  BK_empty
;;

(** 
    Enumeration des différentes tailles des balles. 
    La taille  normale d'une balle est [BS_MEDIUM]. 
  
    Vous pouvez ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_ball_size = BS_SMALL | BS_MEDIUM | BS_BIG;;

(** 
Enumeration des différentes taille de la raquette. Par défaut, une raquette doit avoir la taille
[PS_SMALL]. 

  Vous pouvez ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_paddle_size = PS_SMALL | PS_MEDIUM | PS_BIG;;



(** 
  Enumération des différents états du jeu. Nous avons les trois états de base:
    <ul>
    <li>[GAMEOVER]: qui indique si une partie est finie typiquement lors du lancement du jeu</li>
    <li>[PLAYING]: qui indique qu'une partie est en cours d'exécution</li>
    <li>[PAUSING]: indique qu'une partie en cours d'exécution est actuellement en pause</li>
    </ul>
    
    Dans le cadre des extensions, vous pouvez modifier ce type pour adopter d'autres états du jeu selon votre besoin.
*)
type t_gamestate = GAMEOVER | PLAYING | PAUSING;;


(** Vecteur avec position x et y*)
type t_vec2 = {x:int ; y:int};;


(**
  Cette fonction permet de créer un vecteur 2D à partir de deux entiers.
  Les entiers représentent la composante en X et en Y du vecteur.

  Vous devez modifier cette fonction.

  @author Nicolas Itey 
  @author Olivier Lemaire
  @param x première composante du vecteur
  @param y seconde composante du vecteur
  @return Renvoie le vecteur dont les composantes sont (x,y).
*)
let make_vec2(x,y : int * int) : t_vec2 = {x=x;y=y} ;;

(**
  Cette fonction renvoie un vecteur qui est la somme des deux vecteurs donnés en arguments.
  @author Nicolas Itey 
  @author Olivier Lemaire
  @param a premier vecteur
  @param b second vecteur
  @return Renvoie un vecteur égale à la somme des vecteurs.
*)
let vec2_add(a,b : t_vec2 * t_vec2) : t_vec2 = {x = a.x + b.x ; y = a.y + b.y} ;;

(**
  Cette fonction renvoie un vecteur égale à la somme d'un vecteur
  donné en argument et un autre vecteur construit à partir de (x,y).
  
  @author Nicolas Itey 
  @author Olivier Lemaire
  @param a premier vecteur
  @param x composante en x du second vecteur
  @param y composante en y du second vecteur
  @return Renvoie un vecteur qui est la résultante du vecteur 
*)
let vec2_add_scalar(a,x,y : t_vec2 * int * int) : t_vec2 =
  {x = a.x + x ; y = a.y + y}
;;

(**
  Cette fonction calcul un vecteur où 
  ses composantes sont la résultante de la multiplication  des composantes de deux vecteurs en entrée.
  Ainsi,
    {[
    c_x = a_x * b_x
    c_y = a_y * b_y
    ]}
  @author Nicolas Itey 
  @author Olivier Lemaire
  @param a premier vecteur
  @param b second vecteur
  @return Renvoie un vecteur qui résulte de la multiplication des composantes. 
*)
let vec2_mult(a,b : t_vec2 * t_vec2) : t_vec2 = {x= a.x * b.x ; y= a.y*b.y} ;;

(**
  Cette fonction calcul la multiplication des composantes du vecteur a et du vecteur construit à partir de (x,y).
  @author Nicolas Itey 
  @author Olivier Lemaire
  @param a premier vecteur
  @param x abscisse du second vecteur
  @param y ordonnée du second vecteur
  @return Renvoie un vecteur 
    
*)
let vec2_mult_scalar(a,x,y : t_vec2 * int * int) : t_vec2 = {x=a.x*x ; y=a.y*y} ;;

(** Type réprésentant les différents bonus disponibles *)
type t_bonus = BONUS_ghost | BONUS_snd_chance | BONUS_NULL | BONUS_croix

(** Type qui représente une balle *)
type t_ball = {ball_position : t_vec2 ref ; (** position modifiable en (x,y) de la balle *)
                ball_velocity : t_vec2 ref ; (** vitesse modifiable de la balle en vecteur *)
                ball_color : t_camlbrick_color; (** couleur de la balle*)
                ball_size : int ref;(** rayon de la balle *)
                bonus : t_bonus ref};;(**bonus utilise*)

(** Type qui représente un paddle *)
type t_paddle = {
                  paddle_height : int; (** hauteur du paddle*)
                  paddle_width:int ref; (** largeur du paddle modifiable*)
                  paddle_position:t_vec2 ref;(** position du paddle *)
                  color : t_camlbrick_color; (** couleur du paddle *)
                }
;;

(** Type qui représente le jeu  *)
type t_camlbrick = {
  brick_grid : t_brick_kind array array ; (** matrice affichant la grille de brick*)
  paddle : t_paddle ;(** déclaration du paddle dans le jeu*)
  ball : t_ball list ref ;(** déclaration de toutes les balles dans jeu*)
  game_speed : int ref; (** vitesse du jeu *)
  gameState: t_gamestate ref; (** état du jeu *)
  brick_number : int ref; (** nombre de brick à détruire*)
  param : t_camlbrick_param; (** paramètres du jeu*)
  }
;;

(**
  Cette fonction construit le paramétrage du jeu, avec des informations personnalisable avec les contraintes du sujet.
  Il n'y a aucune vérification et vous devez vous assurer que les valeurs données en argument soient cohérentes.
  
  @return Renvoie un paramétrage de jeu par défaut      
*)
let make_camlbrick_param() : t_camlbrick_param = {
    world_width = 800;
    world_bricks_height = 600;
    world_empty_height = 200;

    brick_width = 40;
    brick_height = 20;

    paddle_init_width = 100;
    paddle_init_height = 20;

    time_speed = ref 20;
}
;;


(**
  Cette fonction est appelée par l'interface graphique lorsqu'on clique sur le bouton
  de la zone de menu et que ce bouton affiche "Start".

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @author Antoine Goy
  @param game la partie en cours.
*)
let start_onclick(game : t_camlbrick) : unit=
  game.gameState := PLAYING
;;

(**
  Cette fonction est appelée par l'interface graphique lorsqu'on clique sur le bouton
  de la zone de menu et que ce bouton affiche "Stop".

  
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @author Antoine Goy
  @param game la partie en cours.
*)
let stop_onclick(game : t_camlbrick) : unit =
  game.gameState := PAUSING
;;


(**
  Cette fonction extrait le paramétrage d'un jeu à partir du jeu donné en argument.
  @author Nicolas Itey
  @param game jeu en cours d'exécution.
  @return Renvoie le paramétrage actuel.
  *)
let param_get(game : t_camlbrick) : t_camlbrick_param =
  make_camlbrick_param()
;;

(**
  Cette fonction crée une raquette par défaut au milieu de l'écran et de taille normal.
  @author Kamardine
  @return crée le paddle
  @deprecated Cette fonction est là juste pour le debug ou pour débuter certains traitements de test.
*)
let make_paddle() : t_paddle =
  let l_param : t_camlbrick_param = make_camlbrick_param () in
  {
    paddle_height = (l_param.paddle_init_height);
    paddle_width = ref ((l_param.paddle_init_width));
    paddle_position = ref(make_vec2(10,10));
    color = RED
  }
;;

(**
    Fonction qui permet de creer une balle
    @author Kamardine
    @param x
    @param y 
    @param size taille de la balle
    @return une balle
  *)
let make_ball(x,y, size : int * int * int) : t_ball =
  {
    ball_position = ref(make_vec2(x,y));
    ball_velocity = ref {x=0; y=1 };
    ball_color = GRAY;
    ball_size = ref size;
    bonus = ref BONUS_NULL
  }
    
;;

(**
  Fonction utilitaire qui permet de traduire l'état du jeu sous la forme d'une chaîne de caractère.
  Cette fonction est appelée à chaque frame, et est affichée directement dans l'interface graphique.
    
  @author Antoine Goy
  @param game représente le jeu en cours d'exécution.
  @return Renvoie la chaîne de caractère représentant l'état du jeu.
*)
let string_of_gamestate(game : t_camlbrick) : string =
  if game.gameState =  ref PLAYING then
    (" Jeu en cours")
  else if game.gameState = ref PAUSING then
    ("Jeu en pause")
  else if game.gameState = ref GAMEOVER then
    ("Jeu terminé")
  else 
    failwith("erreur string_of_gamestate")
;;

(** renvoie le type de brique de la grille de brique du jeux 
    @author Olivier Lemaire
    @param game le jeux
    @param i la position y de la brique
    @param j la position x de la brique
    @return renvoie le type de brique en position i j
*)
let brick_get(game, i, j : t_camlbrick * int * int)  : t_brick_kind =
  (game.brick_grid).(i).(j)
;;



(**renvoie en quoi ce transforme une brique une fois touché
    @author Olivier Lemaire
    @param game le jeux
    @param i la position en y de la brique touché
    @param j la position en x de la brique touché
    @return la brique après qu'elle a été touché
    *)
let brick_hit(game, i, j : t_camlbrick * int * int)  : t_brick_kind = 
  if (game.brick_grid).(i).(j)=BK_simple then
    BK_empty
  else if (game.brick_grid).(i).(j)=BK_double then
    BK_simple
  else if (game.brick_grid).(i).(j)=BK_bonus then
    BK_empty
  else if (game.brick_grid).(i).(j)=BK_empty then
    BK_empty
  else BK_block
;;

(**renvoie la couleur d'une brique
  @author Olivier lemaire
  @param game le jeu
  @param i la position en y de la brique
  @param j la position en x de la brique
  @return renvoie la couleur de la brique 
*)
let brick_color(game,i,j : t_camlbrick * int * int) : t_camlbrick_color = 
  if (game.brick_grid).(i).(j)=BK_empty then
    BLACK
  else if (game.brick_grid).(i).(j)=BK_simple then
    BLUE
  else if (game.brick_grid).(i).(j)=BK_double then
    RED
  else if (game.brick_grid).(i).(j)=BK_block then
    GRAY
  else 
    GREEN
;;

(**
    Fonction qui donne la position en x du paddle
    @author Nicolas
    @author Antoine
    @param game le jeu
    @return position en x
    *)
let paddle_x(game : t_camlbrick) : int = 
  !(game.paddle.paddle_position).x
;;

(**
    Fonction qui donne la largeur du paddle
    @author Nicolas 
    @author Antoine
    @param game le jeu
    @return largeur du paddle
    *)
let paddle_size_pixel(game : t_camlbrick) : int = 
  !(game.paddle.paddle_width)
;;

(**
    Fonction qui decale le paddle vers la gauche
    @author Antoine
    @param game le jeu
    *)
let paddle_move_left(game : t_camlbrick) : unit = 
  let move_left : t_vec2 = make_vec2(-3* !(game.game_speed),0) in 
  if paddle_x(game) <= -350 then
     ()
  else
      game.paddle.paddle_position := vec2_add(!(game.paddle.paddle_position), move_left);
;;

(**
  Fonction qui decale le paddle vers la droite
  @author Antoine
  @param game le jeu
*)
let paddle_move_right(game : t_camlbrick) : unit = 
  let move_right : t_vec2 = make_vec2(3* !(game.game_speed),0) in 
  if paddle_x(game) >= 355 then
    ()
  else 
    game.paddle.paddle_position := vec2_add(!(game.paddle.paddle_position), move_right);
  
;;


(**
    Fonction qui indique si la partie en cours contient au moins une balle
    @author Antoine
    @param game le jeu
    @return vrai si on a une balle dans le jeu , faux sinon
*)
let has_ball(game : t_camlbrick) : bool =
  if !(game.ball)= [] then false
  else true
;;

(**
  Fonction qui donne le nombre de balles
  @author Kamardine
  @param game le jeu
  @return nombre de balles dans le jeu
*)
let balls_count(game : t_camlbrick) : int =
  List.length(!(game.ball))
;;
  

(**
    Fonction qui recupere toutes les balles d'une partie
    @author Kamardine
    @param game le jeu
    @return liste de balle
    *)
let balls_get(game : t_camlbrick) : t_ball list = 
  !(game.ball)
;;
  

(**
    Fonction qui recupere la ieme balle d'une partie
    @author Kamardine
    @param game le jeu
    @param i position i
    @return une balle à la position i
    *)
let ball_get(game, i : t_camlbrick * int) : t_ball =
  List.nth (balls_get(game)) i
;;
  
(**
    Fonction qui renvoie l'abscisse au centre d'une balle
    @author Kamardine
    @param game le jeu
    @param ball la balle
    @return abscisse x au centre d'une balle
*)
let ball_x(game, ball : t_camlbrick * t_ball) : int =
  !((ball_get(game,0)).ball_position).x + !(ball.ball_size)
;;

(**
    Fonction qui renvoie l'ordonnée au centre d'une balle
    @author Kamardine
    @param game le jeu
    @param ball la balle
    @return ordonnée y au centre d'une balle
*)
let ball_y(game, ball : t_camlbrick * t_ball) : int =
  !((ball_get(game,0)).ball_position).y + !(ball.ball_size)
;;

(**
    Fonction qui renvoie le diametre du cercle representant la balle en fonction de sa taille
    @author Kamardine
    @param game le jeu
    @param ball la balle
    @return diametre de la balle
*)
let ball_size_pixel(game, ball : t_camlbrick * t_ball) : int =
  !(ball.ball_size) *2
;;

(**
    Fonction qui donne la couleur d'une balle
    @author Kamardine
    @param game le jeu
    @param ball la balle
    @return couleur de la balle
*)
let ball_color(game, ball : t_camlbrick * t_ball) : t_camlbrick_color =
  ball.ball_color
;;

(**
  Fonction qui détecte si un point (x,y) se trouve à l'intérieur d'un cercle
  @author Antoine
  @author Kamardine
  @param cy Abscisse du centre du cercle
  @param cy Ordonnée du centre du cercle
  @param rad rayon du cercle
  @param x Abscisse du point a verifier
  @param y Ordonée du point a verifier
  @return true
*)
let is_inside_circle(cx,cy,rad, x, y : int * int * int * int * int) : bool =
  (((x-cx)*(x-cx)) + ((y-cy)*(y-cy))) < (rad * rad)
;;


(**
  Fonction qui détecte si un point (x,y) se trouve à l'intérieur d'un rectangle formé  avec comme origine l'angle supérieur gauche de l'ecran 
  @author Kamardine
  @param x1 Abscisse du coin inferieur gauche du rectangle
  @param y1 Ordonnée du coin inferieur gauche du rectangle
  @param x2 Abscisse du coin superieur droit du rectangle
  @param y2 Ordonée du coin superieur droit du rectangle
  @param x Abscisse du point a verifier
  @param y Ordonée du point a verifier
  @return true    
*)
let is_inside_quad(x1,y1,x2,y2, x,y : int * int * int * int * int * int) : bool =  
  (x >= x1 && x<= x2) && (y <= y2 && y >= y1)
;;



(**
     Fonction qui retire une balle dépassant la bordure inférieur
    
    @author Olivier
    @param game le jeu
    @param balls liste de balle disponible dans le jeu
    @return Une liste de ball avec la balle dans les limites du jeu
    *)
let ball_remove_out_of_border(game,balls  : t_camlbrick * t_ball list  ) : t_ball list = 
  
  let fin_list : t_ball list ref = ref [] in
  for i=0 to balls_count(game)-1 do
    let ball : t_ball = ball_get(game,i) in
      if !(ball.ball_position).y<=800 then
        fin_list := ball :: !(fin_list)
      else if !(ball.bonus) = BONUS_snd_chance then (
        fin_list := ball :: !(fin_list);
        ball.ball_velocity := vec2_mult_scalar(!(ball.ball_velocity),0,-1);
        ball.bonus := BONUS_NULL )
      else ();         
  done;
  !(fin_list)

;;
(** Fonction qui change la direction de la balle quand elle tape le paddle 
    @author Olivier Lemaire
    @author Antoine Goy
    @param game le jeu 
    @param ball la balle
    @param paddle le paddle 
    *)
let ball_hit_paddle(game,ball,paddle : t_camlbrick * t_ball * t_paddle) : unit =


  if (!(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)) < (paddle_x(game) + paddle_size_pixel(game)/8) &&
      !(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)> (paddle_x(game)- paddle_size_pixel(game)/8) && 
      (!(ball.ball_position).y >= 755) then (
        ball.ball_velocity := make_vec2(0,-1* !(game.game_speed))
      )
      
      
      
  else 
    if (!(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)) < (paddle_x(game) + paddle_size_pixel(game)/4) &&
        !(ball.ball_position).  x-(400- !(ball.ball_size)) + !(ball.ball_size) > (paddle_x(game)) && 
        (!(ball.ball_position).y >= 755) then (
          ball.ball_velocity :=   make_vec2(1* !(game.game_speed)/2,-1* !(game.game_speed)/2)
         
          
        )
  
    else 
      if (!(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)) < (paddle_x(game) + paddle_size_pixel(game)/2) &&
          !(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size) > (paddle_x(game)) && 
          (!(ball.ball_position).y >= 755) then (
              ball.ball_velocity :=   make_vec2(2* !(game.game_speed)/3,-1* !(game.game_speed)/3)
              
              
           )
      else 
        if (!(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)) > (paddle_x(game) - paddle_size_pixel(game)/4) &&
        !(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)< (paddle_x(game)) && 
        (!(ball.ball_position).y >= 755) then (
                ball.ball_velocity :=   make_vec2(-1* !(game.game_speed)/2,-1* !(game.game_speed)/2)
                
                
              )
        else 
            if (!(ball.ball_position).x-(400- !(ball.ball_size)) + !(ball.ball_size)) > (paddle_x(game) - paddle_size_pixel(game)/2) &&
                !(ball.ball_position).x-(400- !(ball.ball_size))+ !(ball.ball_size) < (paddle_x(game)) && 
                (!(ball.ball_position).y >= 755) then
                  ball.ball_velocity :=   make_vec2(-2* !(game.game_speed)/3,-1* !(game.game_speed)/3)
                
              
                
        
;;


(**casse les brique de la ligne et colonne de la brique bonus touchée
    @author Nicolas Itey 
    @author Olivier Lemaire
    @author Kamardine Mirghane Mohamed
    @author Antoine Goy
    @param game le jeu
    @param ball la balle 
    @param bonus_brick_x coordonnée en abscice de la brique touchée 
    @param bonus_brick_y coordonnée en ordonnée de la brique touchée *)
let ball_croix ( game , ball , bonus_brick_x ,bonus_brick_y : t_camlbrick * t_ball* int * int) : unit =
  for i= 0 to game.param.world_width/game.param.brick_width -1 do
    if game.brick_grid.(i).(bonus_brick_y) <> BK_empty && game.brick_grid.(i).(bonus_brick_y) <> BK_block then 
      game.brick_number := !(game.brick_number) -1 ; 
    game.brick_grid.(i).(bonus_brick_y) <- BK_empty; 
    
  done ;
    for j=0 to game.param.world_bricks_height/game.param.brick_height -1 do
      if game.brick_grid.(bonus_brick_x).(j) <> BK_empty && game.brick_grid.(bonus_brick_x).(j) <> BK_block then 
        game.brick_number := !(game.brick_number) -1 ; 
      game.brick_grid.(bonus_brick_x).(j) <- BK_empty; 
      
    done;
    ;;


(**Attribue un bonus si une brique bonus est touchée
    @author Nicolas Itey 
    @author Olivier Lemaire
    @author Kamardine Mirghane Mohamed
    @author Antoine Goy
    @param game le jeu
    @param ball la balle 
    @param i coordonnée en abscice de la brique touchée 
    @param j coordonnée en ordonnée de la brique touchée *)
let ball_hit_bonus(game,ball,i,j : t_camlbrick * t_ball * int * int ) : unit =

  if brick_get(game,i,j) = BK_bonus then 
  
   
    let rand_num : int = Random.int(100) in
    if rand_num <= 50 then
      ball.bonus := BONUS_snd_chance
    else if rand_num <= 80 then
      ball.bonus := BONUS_ghost
    else if rand_num <= 100 then
     ball_croix(game,ball,i,j)
    else ();
else ()
;;



(** Détecte une collision entre la balle et le côté d'une brique 
    @author Olivier Lemaire
    @author Antoine Goy
    @param game le jeu
    @param ball la ball 
    @param i index de la colonne dans la matrice
    @param j index de la ligne dans la matrice
    @return true si la balle touche le côté d'une brique
    *)
let ball_hit_side_brick(game,ball, i,j : t_camlbrick * t_ball * int * int) : bool =
  if i<20 && j<30 then
    (if brick_get(game,i,j)=BK_simple || brick_get(game,i,j)=BK_bonus && 
        (is_inside_quad(i*40,j*20,(i+1)*40,(j+1)*20,!(ball.ball_position).x, !(ball.ball_position).y)); then
        ( game.brick_number := !(game.brick_number)-1); (* permet de conter le nombre de brique restante à détruire *)
        ball_hit_bonus(game,ball,i,j);
      
        not(brick_get(game,i,j)=BK_empty ) && (is_inside_quad(i*40,j*20,(i+1)*40,(j+1)*20,!(ball.ball_position).x, !(ball.ball_position).y));
    )
  else
    false
;;

(**
  Fonction qui reset la balle au millieu de l'ecran
  @author Kamardine
  @param game le jeu
  @return remet la balle à l'écran
   *)
   let reset_ball_onclick(game : t_camlbrick) : unit =
   (
     game.ball := [];
     game.ball:= (make_ball(395,650,5)::(!(game.ball)));
     game.gameState := PLAYING;
     )
   ;;

(** Fonction qui modifie la trajectoire de la balle quand elle touche un mur 
    @author Olivier Lemaire 
    @author Antoine Goy
    @param game le jeu 
    @param ball la balle 
    *)
let ball_hit_wall(game,ball : t_camlbrick * t_ball) : unit = 
  if (!(ball.ball_position).x <= 0  && !(ball.ball_velocity).x<0) || !(ball.ball_position).x >= 800 && !(ball.ball_velocity).x>0 then 
    ball.ball_velocity := vec2_mult_scalar(!(ball.ball_velocity), -1,1)
  else if !(ball.ball_position).y <= 0 && !(ball.ball_velocity).y<0 then
    ball.ball_velocity := vec2_mult_scalar(!(ball.ball_velocity), 1,-1)
   
  else();
;;


(** Fonction qui gère toutes les collisions du jeu
    @author Olivier Lemaire
    @author Antoine Goy
    @param game le jeu
    @param balls la liste des balles disponible dans le jeu*)
let game_test_hit_balls(game, balls : t_camlbrick * t_ball list) : unit =
  for i=0 to balls_count(game)-1 do
    let ball : t_ball = ball_get(game, i) in
      ball.ball_position:= vec2_add(!(ball.ball_position),!(ball.ball_velocity));
      ball_hit_paddle(game,ball,game.paddle);
    
      game.ball:= ball_remove_out_of_border(game,!(game.ball));
      ball_hit_wall(game,ball);
      if !(ball.ball_position).y > 750 && !(ball.bonus) <> BONUS_snd_chance  then
        ball.bonus := BONUS_NULL;
      
    let x : int = !(ball.ball_position).x/40 and y:int = !(ball.ball_position).y/20 in


      if ball_hit_side_brick(game,ball,(x),(y)) then(
      
        game.brick_grid.(x).(y)<-brick_hit(game,x,y);
          if !(ball.bonus) <> BONUS_ghost then (
            if (!(ball.ball_position).x - !(ball.ball_velocity).x < x*40|| !(ball.ball_position).x + !(ball.ball_velocity).x > x*40+40) && 
            (!(ball.ball_position).y - !(ball.ball_velocity).y > y*20 && !(ball.ball_position).y + !(ball.ball_velocity).y < y*20+20)then
              (
            
                  ball.ball_position := (
                    if !(ball.ball_velocity).x>0 then
                      vec2_add_scalar(!(ball.ball_position),-5,0)
                    else 
                      vec2_add_scalar(!(ball.ball_position),5,0)
                  ); 

                  ball.ball_velocity := vec2_mult_scalar( !(ball.ball_velocity) ,-1 , 1);

                )
        
            else 
              (
                ball.ball_position := (
                  if !(ball.ball_velocity).y>0 then
                    vec2_add_scalar(!(ball.ball_position),0,-5)
                  else 
                    vec2_add_scalar(!(ball.ball_position),0,5)
                  ); 
                ball.ball_velocity := vec2_mult_scalar( !(ball.ball_velocity) , 1 , -1)
                )
            )
        )
      else();
  done;
;;



(**
  Cette fonction est appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'elle se déplace. 
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @param game la partie en cours.
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris     
*)
let canvas_mouse_move(game,x,y : t_camlbrick * int * int) : unit = 
  ()
;;

(**
  Cette fonction est appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est enfoncé. 
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @param game la partie en cours.
  @param button numero du bouton de la souris enfoncé.
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris     
*)
let canvas_mouse_click_press(game,button,x,y : t_camlbrick * int * int * int) : unit =
  ()
;;


(**
  Cette fonction est appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est relaché. 
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @param game la partie en cours.
  @param button numero du bouton de la souris relaché.
  @param x l'abscisse de la position du relachement
  @param y l'ordonnée de la position du relachement   
*)
let canvas_mouse_click_release(game,button,x,y : t_camlbrick * int * int * int) : unit =
  ()
;;



(**
  Cette fonction est appelée par l'interface graphique lorsqu'une touche du clavier est appuyée.
  Les arguments sont le jeu en cours, la touche enfoncé sous la forme d'une chaine et sous forme d'un code
  spécifique à labltk.
  
  Le code fourni initialement permet juste d'afficher les touches appuyées au clavier afin de pouvoir
  les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @author Olivier Lemaire
  @param game la partie en cours.
  @param keyString nom de la touche appuyée.
  @param keyCode code entier de la touche appuyée.   
*)
let canvas_keypressed(game, keyString, keyCode : t_camlbrick * string * int) : unit =
  if(keyString="Left") then
    paddle_move_left(game)
  else if (keyString="Right") then
    paddle_move_right(game)
;;

(**
  Cette fonction est appelée par l'interface graphique lorsqu'une touche du clavier est relachée.
  Les arguments sont le jeu en cours, la touche relachée sous la forme d'une chaine et sous forme d'un code
  spécifique à labltk.
  
  Le code fourni initialement permet juste d'afficher les touches appuyées au clavier afin de pouvoir
  les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura
  un impact sur les performances si vous dosez mal les temps de calcul.
  @param game la partie en cours.
  @param keyString nom de la touche relachée.
  @param keyCode code entier de la touche relachée.   
*)
let canvas_keyreleased(game, keyString, keyCode : t_camlbrick * string * int) =
()
;;

(**
  Fonction qui reset la balle au millieu de l'ecran
  @author Kamardine
  @param game le jeu
  @return remet la balle à l'écran
   *)
let reset_ball_onclick(game : t_camlbrick) : unit =
(
  game.ball := [];
  game.ball:= (make_ball(395,650,5)::(!(game.ball)));
  game.gameState := PLAYING;
  )
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre l'information
  l'information à afficher dans la zone Custom1 de la zone du menu.
  @author Olivier Lemaire 
  @param game le jeu
  @return Nombre de briques restantes 
*)
let custom1_text(game : t_camlbrick) : string =
  "number of bricks left : "^ string_of_int(!(game.brick_number))
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre l'information
  l'information à afficher dans la zone Custom2 de la zone du menu.
  @author Kamardine
  @param game le jeu
  @return Permet d'indiquer d'ajouter une balle
*)
let custom2_text(game : t_camlbrick) : string =
if balls_count(game)>0 then
  (
  if !((ball_get(game,0)).bonus) = BONUS_ghost then
    "Bonus : Ghost"
  else if !((ball_get(game,0)).bonus) = BONUS_snd_chance then 
    "Bonus : Seconde chance"
  else "no bonus"
  )
else ""
;;



(**
  Cette fonction crée une nouvelle structure qui initialise le monde avec aucune brique visible.
  Une raquette par défaut et une balle par défaut dans la zone libre.
  @author Olivier Lemaire
  @return Renvoie un jeu correctement initialisé
*)
let make_camlbrick() : t_camlbrick = 
  let param : t_camlbrick_param =make_camlbrick_param() in
  let res : t_camlbrick ={brick_grid=Array.make_matrix (param.world_width/param.brick_width ) (param.world_bricks_height/param.brick_height) BK_simple ;
                          paddle = make_paddle() ; 
                          ball =ref [make_ball(400-5,650,5)]; 
                          gameState = ref PLAYING ; 
                          game_speed= ref 7 ;
                          brick_number = ref 0;
                          param = param
                          }  in 
  for j=0 to  res.param.world_bricks_height/param.brick_height-1 do (* change le type de brique de la matrice "brick_grid" *)
    for i=0 to  res.param.world_width/param.brick_width-1 do
      let rand : int = Random.int(100) in
      let kind : t_brick_kind = (if rand<60 then
                                  BK_simple
                                else if rand<75 then 
                                      BK_double
                                else if rand<85 then
                                  BK_block
                                else if rand<95 then
                                  BK_bonus
                                else BK_empty) in
      res.brick_grid.(i).(j)<- kind;
      if not(kind=BK_empty || kind=BK_block) then
        res.brick_number := !(res.brick_number)+1 (* compte le nombre de brique à détruire initialement *)
    done ;
  done;
  res
;;



(**
  Cette fonction est appelée par l'interface graphique pour connaitre la valeur
  du slider Speed dans la zone du menu.

  Vous pouvez donc renvoyer une valeur selon votre désir afin d'offrir la possibilité
  d'interagir avec le joueur.
  @author Olivier Lemaire 
  @param game le jeu 
  @return vitesse du jeu
*)
let speed_get(game : t_camlbrick) : int = 
  !(game.game_speed)
;;


(**
  Cette fonction est appelée par l'interface graphique pour indiquer que le 
  slide Speed dans la zone de menu a été modifiée. 
  
  Ainsi, vous pourrez réagir selon le joueur.

  @author Oliver Lemaire 
  @param game le jeu 
  @param xspeed la vitesse du jeu 
*)
let speed_change(game,xspeed : t_camlbrick * int) : unit=

  for i=0 to List.length(!(game.ball))-1 do
    let ball : t_ball = ball_get(game,i) in
      if xspeed/ !(game.game_speed)>=1 then
        ball.ball_velocity:=vec2_mult_scalar(!(ball.ball_velocity),xspeed/ !(game.game_speed),xspeed/ !(game.game_speed))
  done;
  game.game_speed := xspeed;
  
;;


(**
    Fonction qui appelle toutes les fonction nécessaire au déroulement d'une partie à chaques frames
    @author Olivier Lemaire
    @author Antoine Goy 
    @param  game le jeu*)
let animate_action(game : t_camlbrick) : unit =  
  if !(game.gameState)=PLAYING then
    game_test_hit_balls(game,!(game.ball))
  else ();
  if game.brick_number = ref 0 || game.ball = ref [] then 
    game.gameState := GAMEOVER 
  else();
  
;;


