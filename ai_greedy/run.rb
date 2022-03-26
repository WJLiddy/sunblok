class Greedy
    @@cache = {}
    def initialize
        # preload the cache with every piece bitboard.
        return if(@@cache.size() != 0)
        piece_list = get_piece_list()
        piece_list.keys.each do |k|
            (-4..16).each do |y|
                (-4..16).each do |x|
                cachestr = x.to_s + "," + y.to_s + k
                @@cache[cachestr] = to_bitwise(piece_list[k].map{|t| [x + t[0], y + t[1]]}) 
                end
            end
        end
    end
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

        # disregard any mount points that are covered by another piece, or out of bounds.
        open_mount_points = (mount_points - list_to_coords(own + enemy)).filter{|f| !OOB([f])}

        # disard any mount points that are adjancent to a friendly piece.
        illegal = adj(list_to_coords(own), false)

        # These are open spaces where we can mount a piece.
        (open_mount_points - illegal)
    end

    # expensive
    def to_bitwise(list)
        num = 0
        list.each do |l|
            # 16 by 16 (borders x,y)
            num |= 1 << (((16 * (l[1] + 1))) + (l[0]+1))
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
        # for every mount point (this is optimized, can't change)
        legal_board_mount_points.each do |m|

            # for every piece left...
            remaining_pieces.each do |r|
                # if a bigger piece was already mounted here
                # then we can mount a smaller piece for sure.
                # if we put a part of the piece here, is it a legal move
                piece_list[r].each do |piece_mount_point|
                    # so we have a piece, and a mount point.
                    position = [m[0] + -piece_mount_point[0], m[1] + -piece_mount_point[1]]
                    # Make the string identifier
                    cachestr = position[0].to_s + "," + position[1].to_s + r
                    # Look up the bitstring for the piece in that location
                    piece_pos = @@cache[cachestr]

                    puts("ERROR!" + position.to_s) if piece_pos == nil
                     # 0 means no overlap
                    if ((piece_pos & illegal_bitwise) == 0)
                        move = 
                        {
                            "name" => r,
                            "rotation" => 0,
                            "position" => position
                        }
                        moves_prelim.append(move)
                    end
                    
                end
            end
        end
        return nil if (moves_prelim.length == 0)
        return moves_prelim.max {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
    end
end
