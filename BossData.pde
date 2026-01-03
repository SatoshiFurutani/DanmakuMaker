Boss createBoss(int n) {
  ArrayList<LifeBar> bars = new ArrayList<LifeBar>();

  bars.add(new LifeBar(int((200 + n * 30)* diff.hpRate), (int)((300 + n * 120)* diff.endureTimeRate), phases.get(2 * n), phases.get(2 * n + 1)));
  
  return new Boss(bars);
}
