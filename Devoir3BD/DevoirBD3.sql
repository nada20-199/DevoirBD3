Procédures Stockées

1)	Ecrire une procédure «ajoutPilote» qui permet la création d’un nouveau pilote.
Action      : Insertion du pilote dans la table pilote
Exception : Code pilote dupliqué
Affichage : Pilote crée avec succès ou erreur exception.

create or replace PROCEDURE AjoutPilote(pilote1 PILOTE.NOPILOT%type , 
                                        pilote2 PILOTE.Nom%type , 
                                        pilote3 Pilote.ville%type ,
                                        pilote4 Pilote.sal%type ,
                                        pilote5 PILOTE.COMM%type ,
                                        pilote6 PILOTE.EMBAUCHE%type
                                        )
    is
    Begin
        insert into pilote values (pilote1,pilote2,pilote3,pilote4,pilote5,pilote6);
    End;

2)	Ecrire une procédure  «supprimePilote» qui permet la suppression d’un pilote à partir de son numéro.
Action      : Suppression du pilote de la table pilote
Exception : Pilote n’existe pas ou pilote affecté à un vol
Affichage : Pilote supprimé avec succès ou erreur exception
 
Create PROCEDURE supprimePilote (pilote1 PILOTE.NOPILOT%type)
	is
    Begin
        delete pilote where nopilot = pilote1;
    End;

3)	Ecrire une procédure stockée nommé «affichePilote_N » permettant d’afficher les noms des n premiers pilote de la table PILOTE. La variable n devra être le paramètre d’entrée.
Gérer le cas ou n est plus grand que le nombre de n_uplets de la table PILOTE.
Indication	
Curseur%ROWCOUNT	: nombre de lignes traités par l’ordre SQL, évolue à chaque ligne distribuée
Curseur%NOTFOUND	: vrai si exécution incorrecte de l’ordre SQL

 Create or replace PROCEDURE affichePilote_N  (pilote1 number)
is
    np number := 0;
    var_np number := 0;
    var_exeption exception;
    cursor cp is select nom from pilote order by nopilote;
    v_pilote pilote.nom%type
    
    Begin
        select count(*) into var_np from pilote;
        if np <= var_np 
            open cp;
            loop
                fetch cp into var_nom
                exit when c%rowcount > np
                dBMS_output.put_line(var_nom || '\n');
                i := i+1;
            end loop ;
            close cp;
        else
            raise var_exeption;
        end if;
    exception
        when var_exeption then 
            dBMS_output.put_line('Le number de linge est insffisant');
        end;
        
        
Fonctions Stockées

1)	Ecrire une fonction « nombreMoyenHeureVol » qui permet de calculer le nombre moyen d’heures de vol des avions appartenant à une famille dont le code est transmis en paramètres.
Gérer toutes les exceptions possibles

 Create or replace function nombreMoyenHeureVol (typeavion avion.type%type) 
 return number is 
 nbHeurevol number; 
 Begin 
    select Avg(nbHeurevol) into nbHeurevol from avion where type = typeavion; 
	return nbHeurevol ; 
 end;
 
 Paquetages
 
 1)	On désire mettre en place un package (GEST_PILOTE) logiciel permettant de gérer la table PILOTE. L’objectif est de disposer de procédures permettant de :
	Afficher le contenu de la table au format 	Numéro : Nom    Prénom    Ville    Salaire ;
Pour le stockage des données (déclaration des variables réceptrices), utiliser :
	la collection RECORD 
	la déclaration de type ROWTYPE
	Une procédure qui génère un message d’erreur si la commission est supérieure au salaire pour un pilote donné.
	Une fonction qui retourne le nombre de pilote commençant par « Ah » (utiliser un curseur pour l’ordre select).
	Une procédure qui permet de supprimer un pilote de numéro connu.
	Une fonction qui calcule le nombre moyen d’heures de vol des avions d’une famille donnée.
	Une procédure permettant de modifier le nom, le prénom, la ville et le salaire d’un pilote.



 create or replace package GEST_PILOTE as 
 PROCEDURE AFFICHAGE; 
 function FIND_NAME (a pilote.nom%type) return number ; 
 PROCEDURE MODIFYPILOTE (p1 PILOTE.NOPILOT%type , p2 PILOTE.Nom%type , p3 Pilote.ville%type ,p4 Pilote.sal%type ,p5 PILOTE.COMM%type ,p6 PILOTE.EMBAUCHE%type); 
 procedure ACCES_PILOTE(nopil pilote.nopilot%type );
 PROCEDURE SUPPRIME_PILOTE(p1 PILOTE.NOPILOT%type);
 function HEURE_MOYEN_PILOTE (ptype avion.type%type) return number; 
 End GEST_PILOTE;
 
  create or replace package body GEST_PILOTE as 
  PROCEDURE  AFFICHAGE IS
  BEGIN 
  FOR L IN (SELECT * FROM PILOTE) 
  LOOP 
  DBMS_OUTPUT.PUT_LINE(l.nom || ' ' ||L.ville ||' '||l.sal ||' '|| L.comm ||' '||l.embauche); 
  End LOOP;
  End AFFICHAGE; 
  
   function FIND_NAME (a pilote.nom%type) return number
   is
   cursor c1(b pilote.nom%type) is
   select nopilot from pilote where nom like b || '%';
   v_pilote pilote.nopilot%type ; 
   begin 
   open c1(a); 
   fetch c1 into v_pilote ;
   return v_pilote;
   close c1; 
   end FIND_NAME;
   
   PROCEDURE MODIFYPILOTE (p1 PILOTE.NOPILOT%type , 
   p2 PILOTE.Nom%type ,
   p3 Pilote.ville%type , 
   p4 Pilote.sal%type , 
   p5 PILOTE.COMM%type , 
   p6 PILOTE.EMBAUCHE%type) 
   is 
     v_Pilote PILOTE.NOPILOT%type; 
     Begin
     select count(*) into v_Pilote from pilote where nopilot = p1 ; 
     if v_Pilote is null then 
     ajout_pilote(p1,p2,p3,p4,p5,p6); 
     else
     update pilote set nom = p2 , ville = p3 , sal = p4 , comm = p5 , embauche = p6 where nopilot = p1; 
     end if; 
   End MODIFYPILOTE;
   
    procedure ACCES_PILOTE(nopil pilote.nopilot%type ) 
    is 
    v_data pilote%rowtype; 
    v_exception exception ; 
    BEGIN
    select * into v_data from pilote where nopilot = nopil; 
       if v_data.nopilot is null then 
         raise v_exception ; 
	   end if; 
         insert into ERREUR values (v_data.nom ||'-OK') ; 
	   if(v_data.sal < v_data.comm ) then 
         insert into ERREUR values (' ----- ' || v_data.nom || ', comm > sal') ; 175 end if; 
		 EXCEPTION 
		 when v_exception then insert into ERREUR values ('PILOTE INCONU') ; 
    END ACCES_PILOTE; 
    
     PROCEDURE SUPPRIME_PILOTE  (p1 PILOTE.NOPILOT%type) 
     is 
     v_Pilote PILOTE.NOPILOT%type;
      Begin 
      select pilote into v_Pilote from affectation where pilote = p1 ;
      if v_Pilote is null then
      delete pilote where nopilot = p1 and nopilot not in (select pilote from affectation); 
      else 
      dBMS_output.put_line('Le pilote est occupé'); 
     end if; 
     End SUPPRIME_PILOTE;
     
      function HEURE_MOYEN_PILOTE (ptype avion.type%type)return number 
      is 
      nbHvol number;
      Begin
      select Avg(nbHvol) into nbHvol from avion where type = ptype; 
      return nbHvol ; 
      end HEURE_MOYEN_PILOTE; 
 end GEST_PILOTE;
 
 2)	Définir les spécifications d’un paquetage nommé pkgCollectionPilote contenant :
	Un type collection de pilotes TABLE nommé « tab_Pilotes » ainsi qu’une variable « les_Pilotes » de ce type. 
	Une procédure de nom « garnirTabo » permettant de remplir la collection par les salaires des pilotes.
	Une fonction de nom « maximum» prenant en paramètres d’entrée les salaires de deux piloteset renvoyant le salaire le plus haut.
	Une fonction de nom « salMax » prenant en paramètre d’entrée un « tab_Pilotes » et renvoyant le plus grand nombre contenu dans ce tableau. Faire appel à la fonction  «maximum» pour effectuer le traitement.
    Ajouter à la fonction « salMax » un traitement d’exception déclenchant une erreur fatale lorsque la table passée en paramètre est vide.
	Une procédure de nom «TriTableau» permettant de trier par ordre croissant le contenu d’un «tab_Pilotes » passé en paramètre. On pourra programmer un simple tri par permutation.

 Create package pkgCollectionPilote is
 type TABreal is table of real ;
 tab tabreal ; 
 function maximum (x real ,y real) return real ; 
 function salMax(t tabreal) RETURN real;
 procedure TriTableau (t tabreal); 
 end pkgCollectionPilote; 
 
 3)	Définir le corps du paquetage nommé pkgCollectionPilote.

 Create or Replace package body pkgCollectionPilote is 
 function maximum (x real ,y real) return real is 
 begin 
 if x > y then 
 return x; 
 else 
 return y; 
 end if;
 end maximum; 
 
  function salMax(t tabreal) RETURN real is 
  i number := 1;
  elem real ;
  exce exception; 
  begin 
  if t.count is null then raise exce; 
  else 
  elem := t(1); 
  for i in 2 .. t.count 
  loop 
  elem := mon_max(elem,t(i)); 
  end loop; 
  return elem; 
  end if; 
  exception
  when exce then 
  DbMS_output.put_line('ERROR'); 
  return Null; 
  end salMax; 
  
   procedure TriTableau(t tabreal) is 
   c number; 
   d number; 
   temp real; 
   begin 
   for c in 1 .. t.count-1 
   loop
   for d in 1 .. t.Count-1-c 
   loop
   if t(d) > t(d+1) then
   temp := t(d); 
   t(d) := t(d+1); 
   t(d+1) := temp;
   end if; 
   end loop; 
   end loop;
   end TriTableau; 
   end pkgCollectionPilotes;