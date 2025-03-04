### 🚀 **Rocket Turtle - Game Instructions** 🐢🔥  
Welcome to **Rocket Turtle**, the action-packed game where you pilot a **turbo-charged turtle** through a world full of **fruits, obstacles, and hazards!**  

---

## 📜 **How to Play**
- **Move the Turtle:** Use the **Arrow Keys** (`← ↑ → ↓`) to navigate.  
- **Start the Game:** Press `SPACEBAR` to begin.  
- **Pause/Unpause:** The game starts **paused**—press `SPACEBAR` to start.  
- **Quit the Game:** Press `ESCAPE` to exit and save your score.  

---

## 🎯 **Scoring System**
| **Collectible** | **Shape** | **Points** | **Effect** |
|---------------|----------|------------|------------|
| 🍎 **Red (Apple)** | Circle | **+100** | Small score boost |
| 🍌 **Yellow (Banana)** | Tall Rectangle | **+1000** | Big score boost |
| 🍕 **Purple (Pizza)** | Triangle | **+500** | Medium score boost |
| 💩 **Brown (Poop)** | Square | **0** | 3 hits = Game Over! |
| ⬛ **Black (Hazard)** | Large Rectangle | **GAME OVER!** | Avoid at all costs! |

---

## 🏆 **High Scores**
- Your score is saved automatically in **`highscores.txt`** when the game ends.  
- The **highest recorded score** is displayed at the **top right** during gameplay.  

---

## ❌ **Poop Collision Rules**
- Poop objects **do not disappear** when hit.  
- **Each poop hit adds a "Poop!" marker** at the top left.  
- **Three poop collisions** will trigger a **"GROSS!"** message and **end the game.**  
- Poop collisions are **rate-limited** to prevent instant triple hits.  

---

## 🚀 **Turtle Movement & Appearance**
- The **turtle rotates** to **face the direction of movement**.  
- **A large green shell** with **yellow pattern patches**.  
- **Head and neck move dynamically** in **four directions**.  

---

## ⚙ **Technical Details**
- The game is built using **Ruby2D**.  
- **Collision detection** ensures accurate object interactions.  
- The **game starts paused** and **waits for spacebar input** to begin.  
- Collectibles **spawn every 5 seconds**, with the rate **decreasing to 1 second** as the game progresses.  
- **Only one black hazard** will ever spawn.  
- **A maximum of 10 poop objects** can be on-screen at a time.  

---

## 💾 **Installation & Running the Game**
### 🛠 **Requirements**
- Install **Ruby2D** with:  
  ```sh
  gem install ruby2d

- Clone the Repository :
  ```sh
  git clone https://github.com/YOUR_USERNAME/rocket_turtle.git
  cd rocket_turtle

- Run the game :
 ```sh
 ruby rocket_turtle.rb

 ## 📝 **Contributing**
	-	Fork the repository
	-	Submit a pull request with your changes
	-	Feel free to improve the graphics, gameplay, or scoring mechanics!