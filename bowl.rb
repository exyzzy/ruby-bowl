# bowl.rb bowling scoring program in ruby
# Author: Eric Lang
# http://www.exyzzy.com

class States
  def initialize
    @curState = 0
    @curFrame = 0
    @pinsInFrame = 10
    @scores = []
    #[frame_inc, frame_inc, frame_inc, new_state, new_state, new_state, proc, proc, proc]
    @stateMachine = [[0,1,0,1,2,8], #state 0
                     [1,1,0,0,3,7], #state 1
                     [0,1,0,5,4,5], #state 2
                     [0,1,0,1,2,7], #state 3
                     [0,1,0,5,4,6], #state 4
                     [1,1,0,0,3,7], #state 5
                     [0,0,0,7,7,7], #state 6
                     [0,0,0,8,8,8]] #state 7
    #Add procs to stateMachine: 
    @stateMachine[0] << lambda do |pins|            #state 0->1 @stateMachine[0][6]
      @scores.push(pins)
    end
    @stateMachine[0] << @stateMachine[0][6]         #state 0->2 @stateMachine[0][7]
    @stateMachine[0] << nil #error                  #state 0->8 @stateMachine[0][8]
    @stateMachine[1] << lambda do |pins|            #state 1->0 @stateMachine[1][6]
      @scores.push(@scores.pop() + pins)
    end
    @stateMachine[1] << @stateMachine[0][6]         #state 1->3 @stateMachine[1][7]
    @stateMachine[1] << @stateMachine[1][6]         #state 1->7 @stateMachine[1][8]
    @stateMachine[2] << @stateMachine[0][6]         #state 2->5 @stateMachine[2][6]
    @stateMachine[2] << @stateMachine[0][6]         #state 2->4 @stateMachine[2][7]
    @stateMachine[2] << @stateMachine[0][6]         #state 2->5 @stateMachine[2][8]
    @stateMachine[3] << lambda do |pins|            #state 3->1 @stateMachine[3][6]
      @scores.push(@scores.pop() + @scores.pop() + pins)
      @scores.push(pins)
    end
    @stateMachine[3] << @stateMachine[3][6]         #state 3->2 @stateMachine[3][7]
    @stateMachine[3] << lambda do |pins|            #state 3->7 @stateMachine[3][8]
      @scores.push(@scores.pop() + @scores.pop() + pins)
    end      
    @stateMachine[4] << lambda do |pins|            #state 4->5 @stateMachine[4][6]
      @scores.push(@scores.pop() + @scores.pop() + pins)
      @scores.push(10)
      @scores.push(pins)
    end
    @stateMachine[4] << @stateMachine[4][6]         #state 4->4 @stateMachine[4][7]
    @stateMachine[4] << @stateMachine[4][6]         #state 4->6 @stateMachine[4][8]
    @stateMachine[5] << lambda do |pins|            #state 5->0 @stateMachine[5][6]
      a = @scores.pop()
      @scores.push(@scores.pop() + a + pins)
      @scores.push(a + pins)
    end
    @stateMachine[5] << lambda do |pins|            #state 5->3 @stateMachine[5][7]
      a = @scores.pop()
      @scores.push(@scores.pop() + a + pins)
      @scores.push(a)
      @scores.push(pins)
    end
    @stateMachine[5] << @stateMachine[3][8]         #state 5->7 @stateMachine[5][8]
    @stateMachine[6] << @stateMachine[3][8]         #state 6->7 @stateMachine[6][6]
    @stateMachine[6] << @stateMachine[3][8]         #state 6->7 @stateMachine[6][7]
    @stateMachine[6] << @stateMachine[3][8]         #state 6->7 @stateMachine[6][8]
    @stateMachine[7] << nil #error                  #state 7->8 @stateMachine[7][6]
    @stateMachine[7] << nil #error                  #state 7->8 @stateMachine[7][7] 
    @stateMachine[7] << nil #error                  #state 7->8 @stateMachine[7][8]
  end #initialize
  
  def debugPrint (pins)
    puts "Scores: #{@scores}"
    puts "  pins: #{pins}"
    puts "  curState: #{@curState}"
    puts "  curFrame: #{@curFrame}"
    puts "  pinsInFrame #{@pinsInFrame}"
  end # debugPrint
  
  def throwBall(pins) 
    if pins > 10 
      puts "only numbers <= 10 allowed in data file"
      return false
    end
    if @curState == 8 
      puts "Some error occurred"
      return false
    end
    @pinsInFrame -= pins
    f = lambda do |n| #n = 0-2
      @stateMachine[@curState][n+6].call(pins)
      if @stateMachine[@curState][n] == 1 
        @pinsInFrame = 10
        @curFrame += 1
      end
      @curState = @stateMachine[@curState][n+3]      
    end #lambda
    if @curFrame >= 10
      f.call(2) 
    elsif @pinsInFrame == 0 
      f.call(1)
    else
      f.call(0)
    end
  end #throwBall
    
  def getScores
    return @scores
  end #getScores
  
  def bowlGame(gameArray)
     @curState = 0
     @curFrame = 0
     @pinsInFrame = 10
     @scores = []
    gameArray.each do |pins|
      if !self.throwBall(pins) 
        break
      end
    end
  end #bowlGame

end #States

def test (game, test, answer)
  game.bowlGame(test)
  a = game.getScores
  puts "Rolls: #{test}"
  if answer == a then
     puts "  Passed: #{a} = #{answer}"
  else
    puts "  FAILED: #{a} != #{answer}"
  end  
end #test

#Test the scoring
states = States.new
test states, [0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0], [0,0,0,0,0,0,0,0,0,0]
test states, [1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1], [2,2,2,2,2,2,2,2,2,2]
test states, [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10], [30, 30, 30, 30, 30, 30, 30, 30, 30, 30 ]
test states, [5,5, 3,4, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0], [13,7,0,0,0,0,0,0,0,0]
test states, [10, 3,4, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0], [17,7,0,0,0,0,0,0,0,0]
test states, [0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 10, 1,1], [0,0,0,0,0,0,0,0,0,12]
test states, [0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 7,3, 1], [0,0,0,0,0,0,0,0,0,11]
test states, [1,4, 4,5, 6,4, 5,5, 10, 0,1, 7,3, 6,4, 10, 2,8,6], [5, 9, 15, 20, 11, 1, 16, 20, 20, 16]
test states, [1, 1, 10, 10, 10, 2, 2, 8, 2, 3, 7, 10, 3, 3, 10, 10, 10], [2, 30, 22, 14, 4, 13, 20, 16, 6, 30]

