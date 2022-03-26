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

    def generate_legal_board_mount_points(own,enemy)
        # first, generate all diagonals where we can attach a piece.
        mount_points = diag(list_to_coords(own))

        # disard any mount points that are covered by another piece, or out of bounds.
        open_mount_points = (mount_points - list_to_coords(own + enemy)).filter{|f| !OOB([f])}

        # disard any mount points that are adjancent to a friendly piece.
        illegal = adj(list_to_coords(own), true)

        # These are open spaces where we can mount a piece.
        (open_mount_points - illegal)
    end

    def to_bitwise(list)
        num = 0
        list.each do |l|
            # 16 by 16 (borders x,y)
            x = (l[0]+1)
            y = 16 * (l[1] + 1)
            num |= 1 << (y + x)
        end
        num
    end

    def enumerate_moves(own,enemy)
        piece_list = get_piece_list()

        # get all the places where we can add a piece.
        legal_board_mount_points = generate_legal_board_mount_points(own, enemy)

        # these pieces are left.
        remaining_pieces = get_piece_list.keys - own.map{|m| m["name"]}

        # To check the move, make sure nothing is: covered by enemy, or own + adj squares, or out of bounds.
        # if it's not any of these, it is a legal move.
        illegal_spots = adj(list_to_coords(own), true) + list_to_coords(enemy)
        
        (-1..14).each do |y|
            (-1..14).each do |x|
                illegal_spots.append([x,y]) if OOB([[x,y]])
            end
        end

        illegal_bitwise = to_bitwise(illegal_spots)

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
                    # As an optimization, see if we overlapped something, or went out of bounds
                    # if we didn't overlap, and we didn't go out of bounds, the move must be legal.            
                    piece_pos = to_bitwise(piece_list[move["name"]].map{|t| [position[0] + t[0], position[1] + t[1]]}) 
                    overlaps_something = (piece_pos & illegal_bitwise) != 0
                    # then we can return immediately.
                    moves_prelim.append(move) if (!overlaps_something)
                    
                end
            end
        end
        return nil if (moves_prelim.length == 0)
        return moves_prelim.max {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
    end
end
