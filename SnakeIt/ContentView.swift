//
//  ContentView.swift
//  SnakeIt
//
//  Created by Marcus Rohden on 26/8/20.
//  Copyright © 2020 Marcus L. Rohden. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    enum movementDirection {
        case movingUp, movingDown, movingLeft, movingRight
    }
    
    @State var startPos : CGPoint = .zero // the start poisition of our swipe
    @State var isStarted = true // did the user started the swipe?
    @State var gameOver = false // for ending the game when the snake hits the screen borders
    @State var dir = movementDirection.movingDown // the direction the snake is going to take
    @State var posArray = [CGPoint(x: 0, y: 0)] // array of the snake's body positions
    @State var foodPos = CGPoint(x: 0, y: 0) // the position of the food
    @State var score = 0
    @State var highScore = 0
    let snakeSize : CGFloat = 10 // width and height of the snake
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second
    
    let minX = UIScreen.main.bounds.minX
    let maxX = UIScreen.main.bounds.maxX
    let minY = UIScreen.main.bounds.minY
    let maxY = UIScreen.main.bounds.maxY
    
    
    func changeRectPost() -> CGPoint {
        let rows  = Int(maxX/snakeSize)
        let cols = Int(maxY/snakeSize)
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        return CGPoint(x: randomX, y: randomY)
    }
    
    func changeDirection (){
        if(self.posArray[0].x < minX || self.posArray[0].x > maxX && !gameOver){
            gameOver.toggle()
        }else if(self.posArray[0].y < minY || self.posArray[0].y > maxY && !gameOver){
            gameOver.toggle()
        }
        var prev = posArray[0]
        switch dir {
        case .movingDown:
            self.posArray[0].y += snakeSize
            break
        case .movingUp:
            self.posArray[0].y -= snakeSize
            break
        case .movingRight:
            self.posArray[0].x -= snakeSize
            break
        case .movingLeft:
            self.posArray[0].x += snakeSize
            break
        }
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }
    
    func hitCheckFood() -> Bool{
        if self.posArray[0] == self.foodPos {
            return true;
        }
        return false;
    }
    
    func eatFood(){
        self.posArray.append(self.posArray[0])
        self.foodPos = self.changeRectPost()
        self.score+=1
        if(score >= highScore){
            highScore = score
        }
    }
    
    func startGame(){
        startPos = .zero
        isStarted = true
        dir = movementDirection.movingDown // the direction the snake is going to take
        posArray[0] = changeRectPost() // array of the snake's body positions
        foodPos = changeRectPost()// the position of the food
        score = 0
        gameOver = false
    }
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.3)
            ZStack{
                Text("Score: " + String(score)).frame(width: maxX * 0.5, height: 40).position(x: maxX / 2, y: maxY * 0.06)
                Text("Highest Score: " + String(highScore)).frame(width: maxX * 0.5, height: 40).position(x: maxX / 2, y: maxY * 0.06 + 40)
            }
            ZStack {
                ForEach (0..<posArray.count, id: \.self) { index in
                    Rectangle()
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.posArray[index])
                }
                Rectangle()
                    .fill(Color.red)
                    .frame(width: snakeSize, height: snakeSize)
                    .position(foodPos)
            }.onAppear(){
                self.foodPos = self.changeRectPost()
                self.posArray[0] = self.changeRectPost()
            }
            
            if self.gameOver {
                Text("Game Over")
                    .onTapGesture {
                        self.startGame()
                }
            }
        }.onReceive(timer) { (_) in
            if !self.gameOver {
                self.changeDirection()
                if self.hitCheckFood() {
                    self.eatFood()
                }
            }
        }
        .gesture(DragGesture()
        .onChanged { gesture in
            if self.isStarted {
                self.startPos = gesture.location
                self.isStarted.toggle()
            }
        }
        .onEnded {  gesture in
            let xDist =  abs(gesture.location.x - self.startPos.x)
            let yDist =  abs(gesture.location.y - self.startPos.y)
            if self.startPos.y <  gesture.location.y && yDist > xDist {
                self.dir = movementDirection.movingDown
            }
            else if self.startPos.y >  gesture.location.y && yDist > xDist {
                self.dir = movementDirection.movingUp
            }
            else if self.startPos.x > gesture.location.x && yDist < xDist {
                self.dir = movementDirection.movingRight
            }
            else if self.startPos.x < gesture.location.x && yDist < xDist {
                self.dir = movementDirection.movingLeft
            }
            self.isStarted.toggle()
            }
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
