class Rand
    def run(own,enemy)
        10000.times do |i|
            # make up a move
            move = {
                "name" => (get_piece_list().keys - own.map{|n| n["name"]}).sample,
                "rotation" => rand(4),
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
