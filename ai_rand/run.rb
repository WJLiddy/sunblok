class Rand
    def run(own,enemy)
        # start with book move.
        if(own.length == 0)
            if(enemy.length == 0)
                # i am white
                ret =  
                {
                    "name" => "W",
                    "rotation" => 0,
                    "position" => [0,0]
                }
                return ret
            else
                # i am black
                ret = 
                {
                    "name" => "W",
                    "rotation" => 0,
                    "position" => [11,11]
                }
                return ret
            end
        end

        # else.. randompick lol
        # this AI is no good and needs fixed.
        500.times do |i|
            # make up a move
            move = {
                "name" => (get_piece_list().keys - own.map{|n| n["name"]}).sample,
                "rotation" => 0,
                "position" => [rand(14),rand(14)]
            }
            # see if it's valid
            if legal(move, own, enemy, true)
                return move 
            end
        end
        nil
    end
end
