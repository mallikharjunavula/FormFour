//
//  gameView.swift
//  FormFour
//
//  Created by Mallikharjuna avula on 28/11/19.
//  Copyright © 2019 Mallikharjuna avula. All rights reserved.
//

import UIKit

protocol send: class{
    func sendMove(column: Int)
}

class gameView: UIView {

    var rows = 0
    var columns = 0
    var columnTouched = -1
    var fillingArray = [Int]()
    var storedArray = [[Int]]()
    var first = true
    var findMatch = 0
    weak var restartGame:restartGame?
    var comp = false
    var bluetooth = false
    var send: send?
    var opponent = false
    
    @objc func touchPoint(_ sender: UITapGestureRecognizer){
        
        if opponent{
            return
        }
        
        if comp{
            self.gestureRecognizers?.last!.isEnabled = false
        }
        let xTouchPoint = sender.location(in: nil).x - self.frame.origin.x
        var columnwidth = Int(self.bounds.size.width)/columns
        columnTouched = 0
        let width = columnwidth
        while columnwidth < Int(xTouchPoint){
            columnTouched += 1
            columnwidth += width
        }
        if bluetooth{
            send?.sendMove(column: columnTouched)
        }
        dropItem()
        if comp{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                self.bestMove()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0){
                    self.gestureRecognizers?.last!.isEnabled = true
                }
            }
        }
    }
        
    func dropItem(){
        
        if fillingArray[columnTouched] >= 0{
            let (grid,radius) = setGrid()
            let point = destPoint(grid: grid)
            if first{
                storedArray[rows - fillingArray[columnTouched] - 2][columnTouched] = 1
            }
            else{
                storedArray[rows - fillingArray[columnTouched] - 2][columnTouched] = -1
            }
            let path = UIBezierPath()
            path.addArc(withCenter: grid[0][columnTouched], radius: CGFloat(radius), startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: true)
            let player = CAShapeLayer()
            player.path = path.cgPath
            player.fillColor = first ? UIColor.red.cgColor : UIColor.green.cgColor
            self.layer.addSublayer(player)
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = player.position
            animation.toValue = point
            player.position = point
            animation.duration = 1.0
            player.add(animation, forKey: "position")
            if findMatch > 5{
                if findmatch(row: rows - fillingArray[columnTouched] - 2,column: columnTouched,player: first ? "red": "green").0{
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0){
                        self.layer.sublayers?.forEach{  $0.removeFromSuperlayer()  }
                    }
                    opponent = false
                    if !bluetooth{
                        restartGame?.restart()
                    }
                }
            }
            else{
                findMatch += 1
            }
            if first && comp{
                first = false
            }
            first = first ? false : true
            if bluetooth{
                opponent = true
            }
        }
    }
    
    func findmatch(row : Int, column: Int,player: String) -> (Bool,(Int,Int,Int,Int)){
        var returnBool = false
        let reqString = player == "red" ? "(1)(1)(1)(1)" : "(-1)(-1)(-1)(-1)"
        let match = player == "red" ? 1 : -1
        var obtString1 = ""
        var obtString2 = ""
        var obtString3 = ""
        var obtString4 = ""
        var horResult = 0
        var verReslt = 0
        var diaResult1 = 0
        var diaResult2 = 0
        //horizantally
        for findColumn in 0..<columns{
            obtString1 += "(\(storedArray[row][findColumn]))"
        }
        if obtString1.contains(reqString){
            returnBool = true
        }
        if obtString1.contains("(\(match))(\(match))(\(match))(0)") || obtString1.contains("(\(match))(\(match))(0)(\(match))") || obtString1.contains("(\(match))(0)(\(match))(\(match))") || obtString1.contains("(0)(\(match))(\(match))(\(match))"){
            horResult += player == "red" ? -80 : 80
        }
        if obtString1.contains("(\(match))(\(match))(0)") || obtString1.contains("(\(match))(0)(\(match))") || obtString1.contains("(0)(\(match))(\(match))"){
            horResult += player == "red" ? -40 : 40
        }
        //vertically
        for findRow in 0..<rows{
            obtString2 += "(\(storedArray[findRow][column]))"
        }
        if obtString2.contains(reqString){
            returnBool = true
        }
        if obtString2.contains("(\(match))(\(match))(\(match))(0)"){
            verReslt += player == "red" ? -80 : 80
        }
        if obtString2.contains("(\(match))(\(match))(0)"){
            verReslt += player == "red" ? -40 : 40
        }
        //Diagnol
        var findRow = abs(row - (row < column ? row: column))
        var findColumn = abs(column - (row < column ? row: column))
        while (findColumn < columns)&&(findRow < rows){
            obtString3 += "(\(storedArray[findRow][findColumn]))"
            findRow += 1
            findColumn += 1
        }
        if obtString3.contains(reqString){
            returnBool = true
        }
        findColumn = column
        findRow = row
        while findColumn < columns - 1 && findRow != 0 {
            findColumn += 1
            findRow -= 1
        }
        while (findRow < rows)&&(findColumn >= 0){
            obtString4 += "(\(storedArray[findRow][findColumn]))"
            findRow += 1
            findColumn -= 1
        }
        if obtString4.contains(reqString){
            returnBool = true
        }
        if obtString3.contains("(\(match))(\(match))(\(match))(0)") || obtString3.contains("(\(match))(\(match))(0)(\(match))") || obtString3.contains("(\(match))(0)(\(match))(\(match))") || obtString3.contains("(0)(\(match))(\(match))(\(match))"){
            diaResult1 += player == "red" ? -80 : 80
        }
        if obtString4.contains("(\(match))(\(match))(\(match))(0)") || obtString4.contains("(\(match))(\(match))(0)(\(match))") || obtString4.contains("(\(match))(0)(\(match))(\(match))") || obtString4.contains("(0)(\(match))(\(match))(\(match))"){
            diaResult2 += player == "red" ? -40 : 40
        }
        if obtString3.contains("(\(match))(\(match))(0)") || obtString3.contains("(\(match))(0)(\(match))") || obtString3.contains("(0)(\(match))(\(match))"){
            diaResult1 += player == "red" ? -80 : 80
        }
        if obtString4.contains("(\(match))(\(match))(0)") || obtString4.contains("(\(match))(0)(\(match))") || obtString4.contains("(0)(\(match))(\(match))"){
            diaResult2 += player == "red" ? -40 : 40
        }
        return (returnBool,(horResult,verReslt,diaResult1,diaResult2))
    }
    
    func destPoint(grid: [[CGPoint]]) -> CGPoint{
        let row = fillingArray[columnTouched]
        let rowHeight = Int(self.bounds.size.height)/rows
        fillingArray[columnTouched] -= 1
        return CGPoint(x: 0 , y: (row*rowHeight))
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.sublayers?.forEach{ $0.removeFromSuperlayer()}
        let (grid,radius) = setGrid()
        for row in 0..<rows{
            for column in 0..<columns{
                let path = UIBezierPath()
                path.addArc(withCenter: grid[row][column], radius: CGFloat(radius), startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: true)
                path.lineWidth = 2.0
                UIColor.white.setFill()
                path.fill()
            }
        }
        fillingArray = Array(repeating: rows-1, count: columns)
        storedArray = Array(repeating: Array(repeating: 0, count: columns), count: rows)
    }
    
    func setGrid() -> ([[CGPoint]],Double){
        var radius = 0.0
        var grid: [[CGPoint]] = Array(repeating: Array(repeating: CGPoint(), count: columns), count: rows)
        if rows > 0 && columns > 0{
            let rowHeight = Int(self.bounds.size.height)/rows
            let columnwidth = Int(self.bounds.size.width)/columns
            if rows > columns || rowHeight == columnwidth{
                radius = Double(columnwidth) * 0.3
            }
            else{
                radius = Double(rowHeight) * 0.3
            }
            var y = rowHeight/2
            for rowIndex in 0..<rows{
                var x = columnwidth/2
                for columnIndex in 0..<columns{
                    grid[rowIndex][columnIndex] = CGPoint(x: x, y: y)
                    x += columnwidth
                }
                y += rowHeight
            }
        }
        return (grid,radius)
    }
    
    func evalScore() -> Int{
        var totalScore = 0
        for column in 0..<fillingArray.count{
            if fillingArray[column] == -1{
                continue
            }
            let maxRow = rows - fillingArray[column] - 1
            let player = findmatch(row: maxRow, column: column, player: "red").1
            let comp = findmatch(row: maxRow, column: column, player: "green").1
            totalScore += player.0 + player.1 + player.2 + player.3 + comp.0 + comp.1 + comp.2 + comp.3
        }
        return totalScore
    }
    
    func minMax(row: Int,dcolumn: Int, depth: Int,alpha: Int, beta: Int,player: String, isMax: Bool) -> Int{
        
        let vPlayer = player == "red" ? "green" : "red"
        if findmatch(row: row, column: dcolumn, player: vPlayer).0{
            return vPlayer == "red" ? -300 + depth : 300 - depth
        }
        
        if depth > 4 || !(fillingArray[dcolumn] >= 0){
            return evalScore()
        }
        
        if isMax{
            var best = -1000
            var column = 0
            var mAlpha = alpha
            for row in 0..<fillingArray.count{
                let rowValue = fillingArray[row]
                if fillingArray[column] == -1{
                    column += 1
                    continue
                }
                fillingArray[column] -= 1
                storedArray[rows - rowValue - 1][column] = -1
                best = max(best,minMax(row: rows - rowValue - 1, dcolumn: column , depth: depth + 1,alpha: mAlpha,beta: beta,player: "red", isMax: !isMax))
                mAlpha = max(mAlpha, best)
                fillingArray[column] += 1
                storedArray[rows - rowValue - 1][column] = 0
                if beta <= mAlpha{
                    return 0
                }
                column += 1
            }
            return best
        }
        else{
            var best = 1000
            var column = 0
            var mBeta = beta
            for row in 0..<fillingArray.count{
                let rowValue = fillingArray[row]
                if fillingArray[column] == -1{
                    column += 1
                    continue
                }
                fillingArray[column] -= 1
                storedArray[rows - rowValue - 1][column] = 1
                best = min(best,minMax(row: rows - rowValue - 1, dcolumn: column , depth: depth + 1,alpha: alpha,beta: mBeta,player: "green" ,isMax: !isMax))
                mBeta = min(best, mBeta)
                fillingArray[column] += 1
                storedArray[rows - rowValue - 1][column] = 0
                if beta <= alpha{
                    return 0
                }
                column += 1
            }
            return best
        }
    }
    
    func bestMove(){
        var bestColumn = -1
        var bestValue = -1000
        var column = 0
        for row in 0..<fillingArray.count{
            let rowValue = fillingArray[row]
            if fillingArray[column] == -1 {
                column += 1
                continue
            }
            fillingArray[column] -= 1
            storedArray[rows - rowValue - 1][column] = -1
            let getValue = minMax(row: rows - rowValue - 1, dcolumn: column , depth: 1,alpha: -10000000, beta: 10000000,player: "red", isMax: false)
            if getValue >= bestValue {
                bestValue = getValue
                bestColumn = column
            }
            fillingArray[column] += 1
            storedArray[rows - rowValue - 1][column] = 0
            column += 1
        }
        columnTouched = bestColumn
        first = first ? false : true
        dropItem()
    }
}
