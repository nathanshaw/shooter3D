class Avatar extends Object3D
{
  Player player;
  //boolean isLiving;
  
  
  Avatar(Player iplayer, PVector ip, PVector ir)
  {
    super(ip, ir);
    player = iplayer;
    //isLiving = true; //might want to keep it dead until it's initialized
    println("new Avatar!", p, r, player.IP);
  }
  
  void move()
  {
  }
  
  void destroy()
  {
  }
  
  NetAddress getNetAddress()
  {
    return player.getNetAddress();
  }
}
