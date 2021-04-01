// Built off of https://gist.github.com/ihavenonickname/5cc5b9b1d9b912f704061a241bc096ad
// Pixel size is 4 so 4 appears a lot
final int gridsize  = 4 * 7 + 5;  // grid for enemies
Player player;  // Creates player of class Player
ArrayList enemies = new ArrayList();
ArrayList PlayerBullets = new ArrayList();
ArrayList EnemyBullets = new ArrayList();
ArrayList shields = new ArrayList();
int direction = 1;  // Eneniems start going right
boolean isShot = false;
int score = 0;


void setup() {
    background(0);  // sets black background
    noStroke();  // no outline for drawing tools later
    size(800, 550);  // Sets window size
    player = new Player();  // Sets player from class Player
    createEnemies();
    createShields();
    textFont(createFont("Arial", 36, true));  // sets font to Arial
}

void draw() {  // called each frame to redraw the game
    background(0);  // resets black background
    drawScore();
    player.draw();

    for (int i = 0; i < PlayerBullets.size(); i++) { // draws the PlayerBullets
        PlayerBullet bullet = (PlayerBullet) PlayerBullets.get(i);
        bullet.draw();
    }
    
    for (int i = 0; i < EnemyBullets.size(); i++) { // draws the EnemyBullets
        EnemyBullet bullet = (EnemyBullet) EnemyBullets.get(i);
        bullet.draw();
    }

    for (int i = 0; i < enemies.size(); i++) { // checks if any enemy hits the edge
        Enemy enemy = (Enemy) enemies.get(i);
        if (enemy.outside()) {
            direction *= -1;  // invert dirrection if an enemy hits the edge
            isShot = true;
            break;
        }
    }

    for (int i = 0; i < enemies.size(); i++) {
        Enemy enemy = (Enemy) enemies.get(i);
        if (!enemy.alive()) {
            enemies.remove(i);  //removes dead enemies
            if (enemies.size() == 0) {  // if all enemeis are dead. Call i=win screen
                gameWon();
            }
        } else {
            enemy.draw();  // draws the alive enemies
        }
    }
    for (int i = 0; i < shields.size(); i++) {
        Shield shield = (Shield) shields.get(i);
        if (!shield.alive()) {
            shields.remove(i);  //removes dead shields
        } else {
            shield.drawShield();  // draws the alive shields
        }
    }
    isShot = false;
}

void drawScore() {
    fill(252, 252, 252);  //sets text color to white
    text("Score: " + String.valueOf(score), 300, 50);
}

void createEnemies() {
    for (int i = 0; i < width/gridsize/2; i++) {  // columns dependant on gridsize but gridsize is fixed
        for (int j = 0; j <= 2; j++) {  // 3 rows of enenies
            enemies.add(new Enemy(i*gridsize, j*gridsize + 70));
        }
    }
}

void createShields() {
    for (int i = 1; i < 5; i++) {
      shields.add(new Shield(800 / 5 * i, 450));  // makes 4 shields equally spaced
    }
}

class Shield {
    int x, y;
    Shield(int xpos, int ypos) {
        x = xpos;
        y = ypos;
    }
    void drawShield() {
      if (this.alive()) {
        rect(x, y, 40, 10);
      } else {
        shields.remove(this);
      }
    }
    boolean alive() {
      for (int i = 0; i < PlayerBullets.size(); i++) {
        PlayerBullet bullet = (PlayerBullet) PlayerBullets.get(i);
        if (bullet.x > x && bullet.x < x + 40 && bullet.y > y && bullet.y < y + 10) {  // hit detection for player shot
          PlayerBullets.remove(i);
          return false;
        }
      }
      for (int i = 0; i < EnemyBullets.size(); i++) {
        EnemyBullet bullet = (EnemyBullet) EnemyBullets.get(i);
        if (bullet.x > x && bullet.x < x + 40 && bullet.y > y && bullet.y < y + 10) {  // hit detection for enemy shot
          EnemyBullets.remove(i);
          return false;
        }
      }
      return true;
    }
}

class SpaceShip {
    int x, y;
    String sprite[];
    color baseColor = color(255, 0, 0);  // Red color because its cool
    color nextColor = baseColor;  // temp color to flash color later

    void draw() {
        updateObj();
        drawSprite(x, y);
    }

    void drawSprite(int xpos, int ypos) {  // code to draw the player
        fill(nextColor);
        nextColor = baseColor;  // Reset color back to normal
        for (int i = 0; i < sprite.length; i++) {  // code off the internet to draw the enemy sprite
            String row = (String) sprite[i];

            for (int j = 0; j < row.length(); j++) {
                if (row.charAt(j) == '1') {
                    rect(xpos+(j * 4), ypos+(i * 4), 4, 4);
                }
            }
        }
    }

    void updateObj() {  // empty class to be inherited
    }
}

class Player extends SpaceShip {
    boolean canShoot = true;
    int shootdelay = 0;
    int health = 3;  // times player can get shot

    Player() {
        x = width/gridsize/2;
        y = height - (10 * 4);
        sprite    = new String[5];  // code off the internet to draw the player sprite
        sprite[0] = "0010100";
        sprite[1] = "0110110";
        sprite[2] = "1111111";
        sprite[3] = "1111111";
        sprite[4] = "0111110";
    }

    void updateObj() {
        if (keyPressed && keyCode == LEFT) {
            if (x - 5 > 0) {  
              x -= 5;  // moves left 5 if left arrow is pressed and not at left boundary
            }
        }
        
        if (keyPressed && keyCode == RIGHT) {
            if (x + 5 < width - gridsize) {
              x += 5;  // moves right 5 if right arrow is pressed and not at right boundary
            }
        }
        
        if (keyPressed && keyCode == CONTROL && canShoot) {  //shoots if control is pressed an not within 20 loops of last shot
            PlayerBullets.add(new PlayerBullet(x, y));
            canShoot = false;
            shootdelay = 0;
        }
        
        if (shootdelay >= 20) {  // if shot within 20 loops, can't shoot again
            canShoot = true;
        } else {
            shootdelay++;  // +1 loop to shootdelay counter
        }
        for (int i = 0; i < EnemyBullets.size(); i++) {
          EnemyBullet bullet = (EnemyBullet) EnemyBullets.get(i);
          if (bullet.x > x && bullet.x < x + 40 && bullet.y > y && bullet.y < y + 10) {  // enemy shot and player hit detection
            health--;
            EnemyBullets.remove(i);  // don't know why this doesn't remove the bullet like the shield does
            nextColor = color(252, 252, 252);  // flashes color to show player was hit
            if (health == 0) {
              gameOver();
            }
            break;
          }
        }
        
        
        //for (int i = 0; i < PlayerBullets.size(); i++) {
        //    PlayerBullet bullet = (PlayerBullet) PlayerBullets.get(i);
        //    if (bullet.x > x && bullet.x < x + 7 * 4 + 5 && bullet.y > y && bullet.y < y + 5 * 4) {  // hit detection for player shot and enemies
        //        PlayerBullets.remove(i);
        //        health--;  // remove one health if hit
        //        nextColor = color(0, 0, 0);  // flashes color to show enemy was hit
        //        if (health == 0) {  // enemy dies
        //            score += 50;  // 50 points per kill
        //            return false;
        //        }
        //        break;
        //    }
        //}
        //return true;
        
        
        
        
    }
}

class Enemy extends SpaceShip {
    int health = 2;  // Number of hits an enemy ship can take    
    Enemy(int xpos, int ypos) {
        x = xpos;
        y = ypos;
        sprite    = new String[5];  // sprite take off the internet
        sprite[0] = "1011101";
        sprite[1] = "0101010";
        sprite[2] = "1111111";
        sprite[3] = "0101010";
        sprite[4] = "1000001";
    }
    
    int getX() {
      return x;
    }
    int getY() {
      return y;
    }

    void updateObj() {
        if (frameCount % 30 == 0) {  // every 30 frames, moves one unit to the side
            x += direction * gridsize;
        }
        
        if (frameCount % 120 == 0) {  // every 120 frames, enemies fire bullets
            enemiesFire();
        }
        
        if (isShot == true) {
            y += gridsize / 2;
        }
    }

    void enemiesFire() {
        Enemy enemy1 = (Enemy) enemies.get(frameCount % enemies.size());  // psuedo randomization for 3 enemies firing
        //Enemy enemy2 = (Enemy) enemies.get(frameCount * 2 % enemies.size());  // 3 enemies shooting was too many
        Enemy enemy3 = (Enemy) enemies.get(frameCount * 3 % enemies.size());
        EnemyBullet bullet1 = new EnemyBullet(enemy1.x, enemy1.y);
        //EnemyBullet bullet2 = new EnemyBullet(enemy2.x, enemy2.y);
        EnemyBullet bullet3 = new EnemyBullet(enemy3.x, enemy3.y);
        EnemyBullets.add(bullet1);
        //EnemyBullets.add(bullet2);
        EnemyBullets.add(bullet3);
    }

    boolean alive() {
        for (int i = 0; i < PlayerBullets.size(); i++) {
            PlayerBullet bullet = (PlayerBullet) PlayerBullets.get(i);
            if (bullet.x > x && bullet.x < x + 7 * 4 + 5 && bullet.y > y && bullet.y < y + 5 * 4) {  // hit detection for player shot and enemies
                PlayerBullets.remove(i);
                health--;  // remove one health if hit
                nextColor = color(0, 0, 0);  // flashes color to show enemy was hit
                if (health == 0) {  // enemy dies
                    score += 50;  // 50 points per kill
                    return false;
                }
                break;
            }
        }
        return true;
    }

    boolean outside() {  // checks if enemy is outside area
        return x + (direction*gridsize) < 0 || x + (direction*gridsize) > width - gridsize;
    }
}

class PlayerBullet {
    int x, y;

    PlayerBullet(int xpos, int ypos) {
        x = xpos + gridsize/2 - 4;
        y = ypos;
    }

    void draw() {
        fill(255);
        rect(x, y, 4, 4);
        y -= 4 * 2;
    }
}

class EnemyBullet {
    int x, y;

    EnemyBullet(int xpos, int ypos) {
        x = xpos + gridsize/2 - 4;
        y = ypos;
    }

    void draw() {
        fill(255);
        rect(x, y, 4, 4);
        y += 4 * 2;
    }
}

void gameOver() {
    println("Game Over");
    noLoop();  // stops calling draw()
    fill(100, 100, 50);
    rect(0, 0, 800, 550);
    background(100,100,50);
    fill(252, 252, 252);  //sets text color to white
    text("Final Score: " + String.valueOf(score), 260, 50);
}

void gameWon() {
    println("Game Won");
    noLoop();  // stops calling draw()
    fill(20, 250, 250);
    rect(0, 0, 800, 550);
    background(100,100,50);
    fill(252, 252, 252);  //sets text color to white
    text("PERFECT SCORE: " + String.valueOf(score), 200, 50);
}
