
import oscP5.*;
import netP5.*;

OscP5 oscP5;
Map map;

int lport = 12001;
int bcport = 32000;
String myprefix = "/derp";

NetAddress myBroadcastLocation; 
Roster roster = new Roster();

void setup() 
{
  smooth();
  size(1000,1000, P3D);
  frameRate(24);
  
  oscP5 = new OscP5(this,lport);
  myBroadcastLocation = new NetAddress("169.254.76.33",bcport);
  connect(lport, myprefix);
  
  map = new Map();
}

void draw() 
{
  background(0);
  camera(0, 1000, 0, 0, 0, 0, 1, 0, 0); //note this "up" shit. this was necessary to get this to display right.
  map.add(new Object3D(new PVector(100, 0, 0), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(0, 0, 100), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(-100, 0, 0), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(0, 0, -100), new PVector(0, 0, 0)));
  
  map.display();
}

void connect(int ilport, String ipre) //should do all this crap automatically before players "spawn" because we ought to have bugs in this worked out before players are allowed to see anything
{
  OscMessage m = new OscMessage("/server/connect");
  m.add(ilport); 
  m.add(ipre);
  oscP5.send(m, myBroadcastLocation);
}

void oscEvent(OscMessage theOscMessage) 
{
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  
  String messageIP = theOscMessage.netaddress().address();
  String messageaddr = theOscMessage.addrPattern();
  String messagetag = theOscMessage.typetag();
  int isin = roster.indexFromAddrPattern(messageaddr); //this could be the only check function, because "begins with" is the same as "equals"
  //boolean isme = messageaddr.startsWith(myprefix); 

  //player initialization message. 
  if (messageaddr.equals("/players/add")) //remember this fucking string functions you fucking cunt don't fuck up and fucking == with two strings.
  {
    String iprefix = theOscMessage.get(0).stringValue();
    if (iprefix.equals(myprefix)) {return;}
    roster.add(iprefix); //function checks "isin"
    roster.print();
    return;
  }
  
  //player removal message
  if (messageaddr.equals("/players/remove")) //remember this fucking string functions you fucking cunt don't fuck up and fucking == with two strings.
  {
    String iprefix = theOscMessage.get(0).stringValue();
    if (iprefix.equals(myprefix)) {return;}
    roster.remove(iprefix); //function checks "isin"
    roster.print();
    return;
  }
  
  
  if (isin != -1)
  {
    Player iplayer = roster.players.get(isin);
    String iaddr = roster.removePrefix(messageaddr);
    if (iaddr.equals("/init") && messagetag.equals("fff")) //"ffffff"
    {
      float ix = theOscMessage.get(0).floatValue();
      float iy = theOscMessage.get(1).floatValue();
      float iz = theOscMessage.get(2).floatValue();
      
      iplayer.setAvatar(new PVector(ix, iy, iz), new PVector(0, 0, 0));
      int didInit = map.add(iplayer.avatar);
      //if (didInit == -1) //the shit that'll not be in sync will be the Players. 
      println(iplayer.prefix, iaddr, ix, iy, iz);
    }
    else if (iaddr.equals("/pos") && messagetag.equals("fff"))
    {
      float ix = theOscMessage.get(0).floatValue();
      float iy = theOscMessage.get(1).floatValue();
      float iz = theOscMessage.get(2).floatValue();
      
      iplayer.setAvatar(new PVector(ix, iy, iz), new PVector(0, 0, 0)); 
      println(iplayer.prefix, iaddr, ix, iy, iz);
    }
    }
    else
    {
      println("she doesn't even go here..", messageaddr);
    }
}

/*
void keyPressed()
{
  OscMessage m = new OscMessage("/derp/init");
  m.add(0.0);
  m.add(0.0);
  m.add(0.0);
  oscP5.send(m, myBroadcastLocation);
  OscMessage n = new OscMessage("/slurp/init");
  n.add(0.0);
  n.add(0.0);
  n.add(1.0);
  oscP5.send(n, myBroadcastLocation);
}
*/

/*
public void spawnObjects(int count){
  for(int i = 0; i <= count; i++){
    map.add(new Object3D((int)random(-1080,1080), (int)random(0,35), (int)random(-1080, 1080), 0, 0, 0)); //0, 360
  }
}
*/
