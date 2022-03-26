class Greedy
    def run(own,enemy)
        if(own.length == 0)
            # start with book move.
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
        enumerate_moves(own,enemy)
    end

    def enumerate_moves(own,enemy)
        piece_list = get_piece_list()
        # first, generate all diagonals where we can attach a piece.
        mount_points = diag(list_to_coords(own))

        # disard any mount points that are covered by another piece, or out of bounds.
        open_mount_points = (mount_points - list_to_coords(own + enemy)).filter{|f| !OOB([f])}

        # disard any mount points that are adjancent to a friendly piece.
        illegal = adj(list_to_coords(own), true)

        # These are open spaces where we can mount a piece.
        legal_board_mount_points = (open_mount_points - illegal)

        # these pieces are left.
        remaining_pieces = get_piece_list.keys - own.map{|m| m["name"]}

        # as a quick check, we can ignore any locations covered by enemy, or own + adj.
        illegal_spots = adj(list_to_coords(own), true) + list_to_coords(enemy)
        

        moves_prelim = []
        # now, for each legal mount point. compare with each piece.
        remaining_pieces.each do |r|
            legal_board_mount_points.each do |m|
                piece_list[r].each do |piece_mount_point|
                    # so we have a piece, and a mount point.
                    position = [m[0] + -piece_mount_point[0], m[1] + -piece_mount_point[1]]
                    move = 
                    {
                        "name" => r,
                        "rotation" => 0,
                        "position" => position
                    }
                    # As an optimization, see if we overlapped something.

                    overlaps_something = (piece_list[move["name"]].map{|t| [position[0] + t[0], position[1] + t[1]]} & illegal_spots).length > 0
                    # then we can return immediately.
                    moves_prelim.append(move) if (!overlaps_something)
                    
                end
            end
        end
        moves_valid = moves_prelim.filter {|m| legal(m, own, enemy, true)}
        return nil if (moves_valid.length == 0)
        return moves_valid.max {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
    end
end
