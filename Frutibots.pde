//Autor: Becerril Fuentes Kimberly
//Autor: Hahn Martín-Lunas Susana

import java.util.*;
//Variables globales
Cell[][] board;                
Fruit[] fruits;
Robot b1;  //Juega el usuario       
Robot b2;  //Juega la computadora

int tam;                       //Tamaño del tablero
int tamcel;                    //Tamaño de la celda
int altura;                    //Altura de la pantalla de jeugo    
int timeLimit= 10000;          //Tiempo limite para tomar una desicion 10seg
int time;
int turn;                      //0 si no es turno de ninguno 1 si es turno de b1 2 si es turno de b2
boolean decisionMade=false;    //Avisa si ya se tomo una desicion

void setup(){
   frameRate(30); //velocidad
   setBoard();        //Inicializamos el tablero con las casillas
   setRandomFruits(); //Asignamos las frutas en el tablero  
   setRandomRobots(); //Asignamos los robots en el tablero
   setContador();
   time=millis();
   turn=1;
   fillTrees(); 
}


void draw(){
   int timeLeft=millis()-(time + timeLimit);
   switch (turn){
     case 0:
          if(b1.position.equals(b2.position) && b1.nextMove=='P' && b2.nextMove=='P'){//Cuando ambos quieren agarrar la fruta a la vez
             if(b1.position.fruit!=null){
               cellsFruits.remove(b1.position);
               fruits[b1.position.fruit.id].total--;          
               b1.position.fruit=null;
               setContador();
             }
             
          }         
          b1.makeMove();
          b2.makeMove();
          b1.drawRobot();
          changeScore();
          switch(endGame()){
            case 0:
              turn=1;
              time = millis();//also update the stored time
              decisionMade=false;
            break;
            case 1:
              showMessage("Gano Verde");
              noLoop();
            break;
            case 2:
              showMessage("Gano Azul");
              noLoop();
            break;
            case 3:
              showMessage("Empate");
              noLoop();
            break;
         }

     break;
     case 1:     
        if(decisionMade){
          turn=2;
          showMessage("");
        }
        
        if(timeLeft>0){
          showMessage("Gano Azul");
          noLoop();
        }else if(timeLeft%1000<=20) {
          showCountDown("  " + ((timeLeft/1000)-(1))*(-1) );

        }

     break;
     case 2:
         //Se tomara la desicion en el arbol de desiciones
         Collections.sort(cellsFruits);
         positionArray=0;
         DecisionTreeNode n= treesForCell.get(cellsFruits.get(positionArray++).toKey());
         b2.nextMove= n.makeDecision();
         turn=0;
     break;
   }
   
}
/**
*Verifica si el usuario selecciono una opcion para moverse
*/
void keyPressed(){
  if(turn==1){
    switch(keyCode){
      case UP:
      if(b1.position.y!=0){
        b1.nextMove='U';
        decisionMade=true;      
      }else
        showMessage("Movimiento Inválido");        
      break;
      case DOWN:
      if(b1.position.y!=tam-1){
        b1.nextMove='D';
        decisionMade=true;
      }else
        showMessage("Movimiento Inválido");
      break;
      case RIGHT:
      if(b1.position.x!=tam-1){
        b1.nextMove='R';
        decisionMade=true;
      }else
        showMessage("Movimiento Inválido");
      break;
      case LEFT:
      if(b1.position.x!=0){
        b1.nextMove='L';
        decisionMade=true;
      }else
        showMessage("Movimiento Inválido");
      break;
      case ENTER:
      b1.nextMove='P';
      decisionMade=true;
      break;
      default:
        showMessage("Movimiento Inválido");
      break;
    }
  }
}
/**
*Verifica si el juego ya termino, puede ser por que algun robot ya gano en un max de categorias o por que ya
*no hay mas frutas
*
*/
int endGame(){
  int wanB1=0;
  int wanB2=0;
  int totalFruit;
  int finishedCategory=0;
  for(int i=0; i<fruits.length; i++){
    totalFruit=fruits[i].total;
    if(totalFruit/2<b1.numberFrutsPiked[i]){
      wanB1++;
      finishedCategory++;
    }else if(totalFruit/2<b2.numberFrutsPiked[i]){
      wanB2++;
      finishedCategory++;
    }else if(b2.numberFrutsPiked[i]+b1.numberFrutsPiked[i]==totalFruit){
      finishedCategory++;
    }
  }
  if(finishedCategory==fruits.length ){//Empate
    if(wanB1>wanB2){
      return 1;    
    }else if(wanB1<wanB2){
      return 2;
    }else{
      return 3;
    }
  }

  return 0;
  
}
/**
 *Inicializa el tablero
 */
void setBoard(){
 
  tam=10;                    // Tamaño del tablero                      
  board= new Cell[tam][tam];     //Le asignamos tamaño al tablero
 
  //Medidas del tablero
  altura=tam;   
  int anchura=tam;  
  tamcel=60; //tamaño de la celda
  size((altura * tamcel), (anchura * tamcel)+150); //Tamaño de la pantalla
  
  //Pintamos el tablero con las casillas
   int r=0; //Auxiliares para ir manejando los tamaños
   for(int i=0; i<10; i++){
    for(int j=0; j<10; j++){
      board[i][j]= new Cell(j,i); //inicializa las posiciones de las casillas
      board[i][j].drawCell(); //dibuja las casillas
    }
   }//End pintar casillas
  
   
}//End setBoard


/**
 * Asigna frutas en el tablero
 */
void setRandomFruits(){
  
  //Asignamos aleatoreamente el numero de cada fruta
   int numManzanas= int(random(3,6));     
   int numPeras= int(random(2,5));
   int numPlatanos = int(random(2,5));
   int numUvas = int(random(2,5));
   int numFrutas = numManzanas + numPeras + numPlatanos + numUvas; //Numero total de frutas

  
  fruits = new Fruit[4];           //Le asignamos tamaño al arreglo de frutas
  fruits[0]=new Fruit("Manzana", numManzanas,0);
  fruits[1]=new Fruit("Pera", numPeras,1);
  fruits[2]=new Fruit("Platano", numPlatanos,2);
  fruits[3]=new Fruit("Uva", numUvas,3);


  //Ponemos las frutas sobre el tablero en casillsa aleatorias
  //Se agrega la bandera para evitar que ponga frutas donde ya había
  int x=0, y=0; boolean flag=true;
  cellsFruits= new ArrayList<Cell>();
  for(int numOfFruit=0; numOfFruit<4;numOfFruit++){
   for(int i=0; i<fruits[numOfFruit].total; i++){
    while(flag){
     x=int(random(0,9));
     y=int(random(0,9));
     if(board[x][y].setFruit(fruits[numOfFruit])){
       flag=false;
       cellsFruits.add(board[x][y]);
     }
     }
    flag=true;
   }
  }

}//End setRandomFruits
  

/**
 *Pone a ambos robot en una posicion aleatoria del tablero 
 */
void setRandomRobots(){
    
    b1 = new Robot("b1");
    b2 = new Robot("b2");
    int x,y;
    x= int(random(0,9));
    y= int(random(0,9));
      b1.setCelda(board[x][y]);
      b2.setCelda(board[x][y]);
}

/**
*Imprime mensajes
*/
void showMessage(String message){
  fill(237,228,185);
  int y=altura*tamcel;
  rect(350,y,200,40);//Quita los anteriores
  fill(0);
  textSize(20);
  text(message,350,y+15);
}

/**
*Muesta la cuenta regresiva del tiempo que le queda al jugador.
*/
void showCountDown(String message){
  fill(237,228,185);
  int y=altura*tamcel;
  rect(380,y+50,200,80);//Quita los anteriores
  fill(0);
  textSize(60);
  text(message,380,y+100);
  //text ()
}

/**
*Borra los puntages anteriores y pone los nuevos
*/
void changeScore(){
    stroke(237,228,185);
    fill(237,228,185);
    int x=-100;
    int y=altura*tamcel;
    rect(x+250,y+30,200,110);//Quita los anteriores

    fill(0);
    textSize(20);
 
    text(b1.numberFrutsPiked[0],x+250,y+50);
    text(b2.numberFrutsPiked[0],x+350,y+50);
   
    text(b1.numberFrutsPiked[1],x+250,y+78);
    text(b2.numberFrutsPiked[1],x+350,y+78);
    
    text(b1.numberFrutsPiked[2],x+250,y+108);
    text(b2.numberFrutsPiked[2],x+350,y+108);
    
    text(b1.numberFrutsPiked[3],x+250,y+136);
    text(b2.numberFrutsPiked[3],x+350,y+136);
}

/**
*Inicializa en menu de puntages
*/
void setContador(){
    stroke(000000);
    fill(237,228,185);
    rect(0,(altura * tamcel)-4,(altura * tamcel)-5,150);
    PImage manzana=loadImage("Imagenes/manzanaPeque.png");
    PImage platano=loadImage("Imagenes/platanoPeque.png");
    PImage pera=loadImage("Imagenes/peraPeque.png");
    PImage uva=loadImage("Imagenes/uvaPeque.png");
    PImage rm=loadImage("Imagenes/robotVerde_Peque.png");
    PImage ra=loadImage("Imagenes/robotAzul_Peque.png");
    int x=-100;
    int y=altura*tamcel;
    String nm= "("+fruits[0].total+")";
    String npe= "("+fruits[1].total + ")";
    String np= "("+fruits[2].total+")";
    String nu= "(" +fruits[3].total+")";
    fill(0);
    textSize(20);
    image(rm,x+240,y);
    image(ra,x+340,y);
    image(manzana,x+125,y+30);
    text(nm,x+125+45,y+50);
    
    image(platano,x+125,y+88);
    text(np,x+125+45,y+108);
    
    image(pera,x+125,y+60);
    text(npe,x+125+45,y+78);
    
    image(uva,x+125,y+118);
    text(nu,x+125+45,y+136);
    changeScore();
    
}


///////////////////////////////////////////////////FRUIT///////////////////////////////////////////////////
class Fruit{
  public PImage img;//Imagen para la fruta PUEDE NO SER NECESARIA
  public String name; //Nombre para la fruta
  public int total; //El total de esa fruta NO CAMBIA es el inicial
  public int id;//Indica el indice del arreglo de frutas recogidas para el robot.
 
  public Fruit(String name,int total, int id){
    this.name=name;
    this.total=total;
    this.id=id;
    
     if(name=="Pera"){
     img=loadImage("Imagenes/pera.png");
     }
     if(name=="Manzana"){
     img=loadImage("Imagenes/manzana.png");
     }
     if(name=="Platano"){
     img=loadImage("Imagenes/platano.png");
     }
     if(name=="Uva"){
     img=loadImage("Imagenes/uva.png");
     }
     
     
  }
  /**
   * Dibuja la fruta en las coordenadas x,y
   */
   public void drawFruit(int x, int y){
     image(img,x,y);
   }
  
  
}
///////////////////////////////////////////////////CELL///////////////////////////////////////////////////

class Cell implements Comparable<Cell>{
  public int x; //Coordenada x en el tablero
  public int y; //Coordenada y en el tablero
  public Fruit fruit; //La fruta que hay en la casilla si no hay es null
  public Robot robot; //Robot en la casilla
 
 /**
 *Crea una celda sin ninguna fruta
 */
  public Cell(int x, int y){
    this.x=x;
    this.y=y;
    fruit=null;
  }
  
 /**
  * Asignamos la fruta, regresa falso si esta casilla ya tenia fruta
  */
  public boolean setFruit(Fruit f){
    if(this.fruit==null){
    this.fruit=f;
      f.drawFruit(x*(tamcel),y*(tamcel));
    return true;
    }
    return false;
  }
  

  /*
  *Compara dos casillas en cuanto a la distancia entre ellas y el robot b2, contando la distancia como el numero de 
  *movimientos para llegar de la posicion de b2 a cada una . Sirve para ordenar las casillas con frutas dependiendo de que
  *tan cercanas estan a b2
  */
 
    public int compareTo(Cell c){
      int distance1=this.distanceTo(b2.position);
      int distance2=c.distanceTo(b2.position);
      return distance1-distance2;
    }
    /**
    *Obtiene la distancia (numero de casillas que hayque recorrer) entre dos celdas.
    */
    public int distanceTo(Cell c){
      int distance=0;
      distance+= (c.x>x)?c.x-x:x-c.x;
      distance+= (c.y>y)?c.y-y:y-c.y;
      return distance;
    }
    
    /**
    *Crea una cadena que se usara como llave para accesar al arbol de desicion de una casilla en 
    *la tabla hash.
    */
    public String toKey(){
      return x+","+y;
    }
    
    /**
    *Dibuja la celda en la pantalla
    */
    public void drawCell(){
    stroke(000000);
    fill(192,126,126);
    textSize(10);
    rect(x*tamcel-5,y*tamcel-5,tamcel,tamcel);
        fill(0);
    if(this.fruit!=null){
          fruit.drawFruit(x*(tamcel),y*(tamcel));
    }
    }
    

  
}
///////////////////////////////////////////////////ROBOT///////////////////////////////////////////////////

class Robot {
  public PImage image;
  public int[] numberFrutsPiked;//El numero de frutas que ha recogido de cada tipo.
  public Cell position;//La celda en la que se encuentra
  public char nextMove;//El siguiente movimiento que va a hacer, una vez que se toma la desicion se almacena aqui.
  

  /**
   *Crea un robot y a partir del nombre selcciona la imagen correspondiente
   */
  public Robot(String name){
    if(name=="b2"){
    image=loadImage("Imagenes/robotAzul.png");
    }else{
     image=loadImage("Imagenes/robotVerde.png");
    }
    nextMove='P';
    numberFrutsPiked=new int[4];
  }

   /**
   *Catualiza la posicion del robot, vuelve a pintar la celda en la que estaba, y la nueva
   */
   public void setCelda(Cell celda){
     if(position==null){
       position=celda;
       drawRobot();
     }else{
       position.drawCell();
       position=celda;
       drawRobot();
     }
   }
   /**
   *Realiza el movimiento que esta guardado como nextMove dentro de sus atributos
   */
   public void makeMove(){
     switch(nextMove){
         case 'U':
           setCelda(board[position.y-1][position.x]);
         break;
         case 'D':
           setCelda(board[position.y+1][position.x]);
         break;
         case 'R':
           setCelda(board[position.y][position.x+1]);
         break;
         case 'L':
           setCelda(board[position.y][position.x-1]);
         break;
         case 'P':
           if(position.fruit!=null){
             numberFrutsPiked[position.fruit.id]++;
             cellsFruits.remove(position);
             position.fruit=null;
           }
           setCelda(board[position.y][position.x]);
         break;
        
     }
   }
   
   
   
  /**
   * Dibuja el robot en las coordenadas x,y
   */
   public void drawRobot(){
     image(image,position.x*tamcel,position.y*tamcel-2);
   }
   
  
}//End robot



///////////////////////////////////////////////////DECISIONTREE///////////////////////////////////////////////////

/*
*Los arboles de decision que dicen si combiene que el robot en turno vaya a la casilla.
*la llave es la cadena que representa a la celda.
*
*/
HashMap<String,DecisionTreeNode> treesForCell; //Tabla hash en donde guardamos para cada celda con una fruta, un arbol de desicion para saber si
                                               //le conviente al robot b2 ir a esa casilla o no
ArrayList<Cell> cellsFruits;   //Las celdas que tienen frutas todavia.
int positionArray;             //La posicion de la lista de celdas mas cercas que esta siendo revisada en el arbol. USO DEL DESICIONES

/**
*Constuye los arboles de desicion para cada celda con fruta y los agrega a la tabla hash en donde seran almacenados
*/
void fillTrees(){
  treesForCell= new HashMap<String,DecisionTreeNode>();
  //Nodos de desicion, que se seran reutilizados en los arboles
  DecisionAction aUp= new DecisionAction('U'); //Accion moverse arriba
  DecisionAction aDown= new DecisionAction('D');//Accion moverse abajo
  DecisionAction aRigth= new DecisionAction('R'); //Accion moverse derecha
  DecisionAction aLeft= new DecisionAction('L'); //Accion moverse izquierda
  DecisionAction aPick= new DecisionAction('P'); //Accion moverse recojer fruta

  DecisionMaxF iHaveMax; //Desicion, verifica si b2 ya gano la categoria
  DecisionMaxF enemyHasMax; //Desicion, verifica si b1 ya cano la categoria
  DecisionEnemyCloserToCell closer; //Desicion, verifica si b1 esta mas cerca que yo de la celda
  DecisionIsMyCell inCell; //Desicion, verifica si esta parado b2 en la celda
  DecisionIsUp isUp; //Desicion, verifica si la celda esta abajo
  DecisionIsDown isDown; //Desicion, verifica si la celda esta arriba
  DecisionIsRigth isRigth; //Desicion, verifica si la celda esta a la derecha
  Cell actual;//La celda que se esta revisando como posible opcion en ese moemento
  
  //Creamos los arboles de desicion para cada celda
  for(int i=0; i< cellsFruits.size();i++){
    actual=cellsFruits.get(i);
    //Colocamos los nodos hijos correspondientes para cada desicion del arbol comenzando por las ultimas desiciones
    isRigth=new DecisionIsRigth(actual);
    isRigth.trueNode=aRigth;
    isRigth.falseNode=aLeft;
    
    isDown=new DecisionIsDown(actual);
    isDown.trueNode=aDown;
    isDown.falseNode=isRigth;
    
    isUp=new DecisionIsUp(actual);
    isUp.trueNode=aUp;
    isUp.falseNode=isDown;
    
    inCell= new DecisionIsMyCell(actual);
    inCell.trueNode=aPick;
    inCell.falseNode=isUp;
    
    closer= new DecisionEnemyCloserToCell(actual);
    closer.falseNode=inCell;
    
    iHaveMax=new DecisionMaxF(actual.fruit.id,b1);
    iHaveMax.falseNode=closer;
   
    enemyHasMax=new DecisionMaxF(actual.fruit.id,b2);
    enemyHasMax.falseNode=iHaveMax;
    
    //Agregamos a la tabla hash el arbol de desiciones con la llave que genera la casilla correspondiente
    treesForCell.put(actual.toKey(),enemyHasMax);
  }

}

/**
*Clase abstracta que modela un nodo de un arbol de desicion. Para diferenciar si el nodo es de decision o de accion
*se verifica el caracter action. El metodo makeDecision ya esta implementado a partir del comentario anterior.
*Toda clase que desee extenderla debe implementar el metodo getBranch que obtiene la rama que se debe tomar.
*/
abstract class DecisionTreeNode{
    char action;//M: Es un nodo de desicion P: PickUp L:Left R:Rigth U:Up D:Down
    DecisionTreeNode trueNode;
    DecisionTreeNode falseNode;
    public DecisionTreeNode(char action){
      this.action=action;
    }
    
    char makeDecision(){
        if(action=='M'){
          return getBranch().makeDecision();
        }
        else{
           return action;
        } 
    }    
    abstract DecisionTreeNode getBranch();    
}

/**
*Clase que extiende a DecisionTreeNode, representa un nodo que es accion.
*/
class DecisionAction extends DecisionTreeNode{
  public DecisionAction(char action){
    super(action);
  }
  /**
  *Como el nodo es de accion sabemos que nunca debe llegar a pedirle su rama, por la implementacion de makeDecision en DecisionTreeNode
  */
  DecisionTreeNode getBranch(){
    //Este metodo no debe nunca ser invocado para nodos de tipo accion
    print("Error! Era accion");
    return null;
  }
}
/**
*Clase que extiende a DecisionTreeNode, representa el nodo de decision que verifica si el robot que tiene
*como atributo ha ganado ya la categoria.
*/
class DecisionMaxF extends DecisionTreeNode{
  Robot robot;
  int idFruit;

  public DecisionMaxF(int idFruit,Robot robot){
    super('M');
    this.robot=robot;
    this.idFruit=idFruit;
  }
  /**
  *Verifica si el robot ya tiene el maximo
  */
  DecisionTreeNode getBranch(){
    if(fruits[idFruit].total/2<robot.numberFrutsPiked[idFruit]){
      //Verificamos si es la ultima celda que se va a verificar, de ser asi el robot va a tener un moviemento en blanco que
      //podemos modelar utilizando la accion P.
      if(positionArray==cellsFruits.size())
        return new DecisionAction('P');
      
      //Regresa el arbol de la siguiente celda
      return treesForCell.get(cellsFruits.get(positionArray++).toKey());//True node
    }else{
      return falseNode;
    }
  }  
}
/**
*Clase que extiende a DecisionTreeNode, representa la decision de si el enememigo b1 esta mas cerca de la casilla
*/
class DecisionEnemyCloserToCell extends DecisionTreeNode{
  Cell cell;
  public DecisionEnemyCloserToCell(Cell cell){
    super('M');
    this.cell=cell;
  }
  /**
  *Si el enemigo esta mas cerca de la casilla ultilando la funcion distancia
  */
  DecisionTreeNode getBranch(){
    if(cell.distanceTo(b1.position)<cell.distanceTo(b2.position)){
      //Si ya no hay mas casillas regresamos el nodo falso para que almenos se acerque a la fruta.
      if(positionArray==cellsFruits.size())
              return falseNode;
      
      //Regresa el arbol de la siguiente celda
      return treesForCell.get(cellsFruits.get(positionArray++).toKey());//True node
    }else{
      return falseNode;
    }
  }  
}
/**
*Clase que extiende a DecisionTreeNode, representa la decision de si el robot b2 esta en la casilla
*/
class DecisionIsMyCell extends DecisionTreeNode{
  Cell cell;
  public DecisionIsMyCell(Cell cell){
    super('M');
    this.cell=cell;
  }
  /**
  *Verifica si la distancia a la casilla del roobot b2 es 0
  */
  DecisionTreeNode getBranch(){
    if(cell.distanceTo(b2.position)==0){
      return trueNode; 
    }else{
      return falseNode;
    }
  }  
}
/**
*Clase que extiende a DecisionTreeNode, representa la decision de si la casilla esta hacia arriba de b2
*/
class DecisionIsUp extends DecisionTreeNode{
  Cell cell;
  public DecisionIsUp(Cell cell){
    super('M');
    this.cell=cell;
  }
  /**
  *Verifica si la casilla esta arriba de b2
  */
  DecisionTreeNode getBranch(){
    if(cell.y<b2.position.y){
      return trueNode; 
    }else{
      return falseNode;
    }
  }  
}
/**
*Clase que extiende a DecisionTreeNode, representa la decision de si la casilla esta hacia abajo de b2
*/
class DecisionIsDown extends DecisionTreeNode{
  Cell cell;
  public DecisionIsDown(Cell cell){
    super('M');
    this.cell=cell;
  }
  /**
  *Verifica si la casilla esta abajo de b2
  */
  DecisionTreeNode getBranch(){
    if(cell.y>b2.position.y){
       return trueNode; 
    }else{
      return falseNode;
    }
  }  
}
/**
*Clase que extiende a DecisionTreeNode, representa la decision de si la casilla esta hacia la derecha de b2
*/
class DecisionIsRigth extends DecisionTreeNode{
  Cell cell;
  public DecisionIsRigth(Cell cell){
    super('M');
    this.cell=cell;
  }
  /**
  *Verifica si la casilla esta a la derecha de b2
  */
  DecisionTreeNode getBranch(){
    if(cell.x>b2.position.x){
       return trueNode; 
    }else{
      return falseNode;
    }
  }  
}
