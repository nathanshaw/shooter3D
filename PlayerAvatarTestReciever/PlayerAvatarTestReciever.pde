import oscP5.*;
import netP5.*;

OscP5 oscP5;

Map map;
Camera cam;

int lport = 12001;
int bcport = 32000;
String myprefix = "/derp";

NetAddress myBroadcastLocation; 
Roster roster;

void setup() 
{
  smooth();
  size(1000,1000, P3D);
  frameRate(24);

  oscP5 = new OscP5(this, lport);
  myBroadcastLocation = new NetAddress("169.254.76.33",bcport);
  //connect(lport, myprefix);
  
  roster = new Roster();
  map = new Map();
  map.add(new Object3D(new PVector(500, 0, 0), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(0, 0, 500), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(-500, 0, 0), new PVector(0, 0, 0)));
  map.add(new Object3D(new PVector(0, 0, -500), new PVector(0, 0, 0)));
}

void draw() 
{
  background(0);
  camera(0, 1000, 0, 0, 0, 0, 1, 0, 0); //note this "up" shit. this was necessary to get this to display right.
  map.display();
  //map.print();
}

void connect(int ilport, String ipre) //should do all this crap automatically before players "spawn" because we ought to have bugs in this worked out before players are allowed to see anything
{
   for (int i = 0; i < roster.players.size(); i++)
   {
     Player p = roster.players.get(i);
     map.remove(p.avatar); //checks isIn
     roster.players.remove(p);
   } //really should put a "roster.remove" function, so that deallocation can be handled
  OscMessage m = new OscMessage("/server/connect");
  m.add(ilport); 
  m.add(ipre);
  oscP5.send(m, myBroadcastLocation);
}

void disconnect(int ilport, String ipre)
{
  for (int i = 0; i < roster.players.size(); i++)
   {
     Player p = roster.players.get(i);
     map.remove(p.avatar); //checks isIn
     roster.players.remove(p);
   } //really should put a "roster.remove" function, so that deallocation can be handled
  OscMessage m = new OscMessage("/server/disconnect");
  m.add(ilport); 
  m.add(ipre);
  oscP5.send(m, myBroadcastLocation);
}

void oscEvent(OscMessage theOscMessage) 
{
  //println("###2 received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  //theOscMessage.print();
  
  String messageIP = theOscMessage.netaddress().address();
  String messageaddr = theOscMessage.addrPattern();
  String messagetag = theOscMessage.typetag();
  int isin = roster.indexFromAddrPattern(messageaddr); //this could be the only check function, because "begins with" is the same as "equals"

  //player initialization message. 
  if (messageaddr.equals("/players/add")) //remember this fucking string functions you fucking cunt don't fuck up and fucking == with two strings.
  {
    String iprefix = theOscMessage.get(0).stringValue();
    if (roster.isMe(iprefix)) {return;}
    roster.add(iprefix); //function checks "isin"
    //roster.print();
    return;
  }
  
  //player removal message
  if (messageaddr.equals("/players/remove")) //remember this fucking string functions you fucking cunt don't fuck up and fucking == with two strings.
  {
    String iprefix = theOscMessage.get(0).stringValue();
    if (roster.isMe(iprefix)) {return;}
    int rosterindx = roster.indexFromPrefix(iprefix);
    if (rosterindx == -1)
    {
      return;
    }
    else 
    {
      Player iplayer = roster.players.get(rosterindx);
      map.remove(iplayer.avatar); //checks "isin" so null won't throw
      roster.remove(iprefix); //function checks "isin"
    }
    
    //roster.print();
    return;
  }
  
  if (isin != -1)
  {
    Player iplayer = roster.players.get(isin);
    String iaddr = roster.removePrefix(messageaddr);
    if (iaddr.equals("/init") && messagetag.equals("fff")) //"ffffff" //this is redundant and confusing.
    {
      float ix = theOscMessage.get(0).floatValue();
      float iy = theOscMessage.get(1).floatValue();
      float iz = theOscMessage.get(2).floatValue();
      
      PVector ip = new PVector(ix, iy, iz);
      Avatar ia = new Avatar(iplayer, ip, new PVector(0, 0, 0));
      if (map.objects.contains(iplayer.avatar))
      {
        map.objects.remove(iplayer.avatar);
        iplayer.avatar = null;
      }
      
      if (map.add(ia) != -1)
      {
        iplayer.avatar = ia;
      }
      else 
      { 
        println("avatar was not initialized at position: "+ip+""); 
      } //the shit that'll not be in sync will be the Players. 
      //println(iplayer.prefix, iaddr, ix, iy, iz);
    }
    else if (iaddr.equals("/pos") && messagetag.equals("fff"))
    {
      float ix = theOscMessage.get(0).floatValue();
      float iy = theOscMessage.get(1).floatValue();
      float iz = theOscMessage.get(2).floatValue();
      
      PVector ip = new PVector(ix, iy, iz);
      if (map.move(iplayer.avatar, ip) != -1)
      {
        println("the avatar of "+iplayer.prefix+" was moved to "+ip+"");
      }
      else 
      {
        println("the avatar of "+iplayer.prefix+" was not moved to "+ip+"");
      }
      
    }
    }
    else
    {
      //println("she doesn't even go here..", messageaddr);
    }
}

void sendInit(float ix, float iy, float iz) //+ rotation
{
  OscMessage ocoor = new OscMessage(myprefix + "/init"); 
  ocoor.add(ix);
  ocoor.add(iy);
  ocoor.add(iz);
  oscP5.send(ocoor, myBroadcastLocation);
}

void sendPos(float ix, float iy, float iz) //+ rotation
{
  OscMessage ocoor = new OscMessage(myprefix + "/pos");
  ocoor.add(ix);
  ocoor.add(iy);
  ocoor.add(iz);
  oscP5.send(ocoor, myBroadcastLocation);
}

void keyPressed()
{
  switch(key)
  {
    case 'c': connect(lport, myprefix); break;
    case 'd': disconnect(lport, myprefix); break;
    case 'r': roster.print(); break;
    case 'm': map.print(); break;
  }
}

/*
public void spawnObjects(int count){
  for(int i = 0; i <= count; i++){
    map.add(new Object3D((int)random(-1080,1080), (int)random(0,35), (int)random(-1080, 1080), 0, 0, 0)); //0, 360
  }
}
*/
