class Greedy
    @@cache = {}
    @@pids = {}
    @@OOB_LIST = []
    @large_first = false
    def initialize(large_first)
        @large_first = large_first
        # preload the cache with every piece bitboard.
        return if(@@cache.size() != 0)
        piece_list = get_piece_list()
        ctr = 0
        piece_list.keys.each do |k|
            @@pids[k] = ctr
            ctr += 1
            (-4..16).each do |y|
                (-4..16).each do |x|
                cachestr = (y << 16) + (x << 8) + @@pids[k]
                #puts "CACHE ERROR!!!" if !@@cache.has_key? cachestr
                @@cache[cachestr] = to_bitwise(piece_list[k].map{|t| [x + t[0], y + t[1]]}) 
                end
            end
        end
        (-1..14).each do |y|
            (-1..14).each do |x|
                @@OOB_LIST.append([x,y]) if OOB([[x,y]])
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

    def generate_legal_board_mount_points(own_placed, own_placed_adj, enemy_placed)
        # first, generate all diagonals where we can attach a piece.
        mount_points = diag(own_placed)

        # disregard any mount points that are covered by another piece, or out of bounds.
        legal_mount_points = (mount_points - (own_placed_adj + enemy_placed + @@OOB_LIST))

        return legal_mount_points
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
        # generate own and enemy lists
        own_placed = list_to_coords(own)
        own_placed_adj = adj(own_placed,true)
        enemy_placed = list_to_coords(enemy)

        # get reference to listof pieces.
        piece_list = get_piece_list()

        # get all the places where we can add a piece.
        legal_board_mount_points = generate_legal_board_mount_points(own_placed, own_placed_adj, enemy_placed)

        # these pieces are left.
        remaining_pieces = get_piece_list.keys - own.map{|m| m["name"]}

        # To check the move, make sure nothing is: covered by enemy, or own + adj squares, or out of bounds.
        # if it's not any of these, it is a legal move.
        illegal_spots = adj(own_placed, true) + enemy_placed + @@OOB_LIST

        illegal_bitwise = to_bitwise(illegal_spots)

        moves_prelim = []
        # for every mount point (this is optimized, can't change)
        legal_board_mount_points.each do |m|

            # for every piece left...
            remaining_pieces.each do |r|
                pid = @@pids[r]
                # if a bigger piece was already mounted here
                # then we can mount a smaller piece for sure.
                # if we put a part of the piece here, is it a legal move
                piece_list[r].each do |piece_mount_point|
                    # the inner loop here does a tiny amount of math.
                    # it calculates the piece to consider and looks up the bitboard.
                    # i do not think i can make this faster.

                    # so we have a piece, and a mount point.
                    position0 = m[0] + -piece_mount_point[0]
                    position1 = m[1] + -piece_mount_point[1]
                    # Make the cache identifier
                    cachestr = (position1 << 16) + (position0 << 8) + pid
                    # Look up the bitstring for the piece in that location
                    piece_pos = @@cache[cachestr]
                     # 0 means no overlap
                    if ((piece_pos & illegal_bitwise) == 0)
                        # creating this is not expensive because it is so rare (most moves fail)
                        move = 
                        {
                            "name" => r,
                            "rotation" => 0,
                            "position" => [position0, position1]
                        }
                        moves_prelim.append(move)
                    end
                    
                end
            end
        end
        return nil if (moves_prelim.length == 0)
        if(@large_first)
        return moves_prelim.max {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
        else
        return moves_prelim.min {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
        end    
    end
end
