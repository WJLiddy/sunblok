class Greedy
    # given a piece's position, pre-generate a bitboard that can be compared against the real board. 
    @@bit_cache = {}
    # pre-generate an integer for each piece's position, used for the bitboard.
    @@pids = {}
    # pre-generate the list edge coordinates (out of bounds)
    @@OOB_LIST = []
    # generate attachment points for each piece.
    @@attaches = {}
    # flag to choose the largest piece first or smallest piece?
    @large_first = false

    def initialize(large_first)
        @large_first = large_first

        # preload the cache with every piece bitboard.
        return if(@@bit_cache.size() != 0)
        piece_list = get_piece_list()
        ctr = 0
        piece_list.keys.each do |k|
            @@pids[k] = ctr
            ctr += 1
            (-4..16).each do |y|
                (-4..16).each do |x|
                cachestr = (y << 16) + (x << 8) + @@pids[k]
                #puts "CACHE ERROR!!!" if !@@bit_cache.has_key? cachestr
                @@bit_cache[cachestr] = to_bitwise(piece_list[k].map{|t| [x + t[0], y + t[1]]}) 
                end
            end
        end

        # generate the OOB's.
        (-1..14).each do |y|
            (-1..14).each do |x|
                @@OOB_LIST.append([x,y]) if OOB([[x,y]])
            end
        end

        # generate the attachment points for each piece.
        @@attaches = {}
        piece_list.each do |k,v|
            dirs = {}
            dirs["SE"] = (v.map{|p| [p[0]+1,p[1]+1]} - adj(v,true)).map{|p| [p[0]-1,p[1]-1]} 
            dirs["NE"] = (v.map{|p| [p[0]+1,p[1]-1]} - adj(v,true)).map{|p| [p[0]-1,p[1]+1]} 
            dirs["NW"] = (v.map{|p| [p[0]-1,p[1]-1]} - adj(v,true)).map{|p| [p[0]+1,p[1]+1]} 
            dirs["SW"] = (v.map{|p| [p[0]-1,p[1]+1]} - adj(v,true)).map{|p| [p[0]+1,p[1]-1]} 
            @@attaches[k] = dirs
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

        lmpwd = []
        # check the mount direction (used later)
        legal_mount_points.each do |m|
            if(own_placed.include? [m[0]+1,m[1]+1] or enemy_placed.include? [m[0]+1,m[1]+1])
                lmpwd << [m,"NE"]
                next
            end
            if(own_placed.include? [m[0]-1,m[1]+1] or enemy_placed.include? [m[0]-1,m[1]+1])
                lmpwd << [m,"NW"]
                next
            end
            if(own_placed.include? [m[0]+1,m[1]-1] or enemy_placed.include? [m[0]+1,m[1]-1])
                lmpwd << [m,"SE"]
                next
            end
            if(own_placed.include? [m[0]-1,m[1]-1] or enemy_placed.include? [m[0]-1,m[1]-1])
                lmpwd << [m,"SW"]
                next
            end
        end
        return lmpwd
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
        illegal_spots = own_placed_adj + enemy_placed + @@OOB_LIST

        illegal_bitwise = to_bitwise(illegal_spots)

        moves_prelim = []

        legal_board_mount_points.each do |m|
            # for every piece left...
            remaining_pieces.each do |r|
                pid = @@pids[r]
                @@attaches[r][m[1]].each do |piece_mount_point|
                    # the inner loop here does a tiny amount of math.
                    # it calculates the piece to consider and looks up the bitboard.
                    # i do not think i can make this faster.
                    # so we have a piece, and a mount point.
                    position0 = m[0][0] + -piece_mount_point[0]
                    position1 = m[0][1] + -piece_mount_point[1]
                    # Make the cache identifier
                    cachestr = (position1 << 16) + (position0 << 8) + pid
                    # Look up the bitstring for the piece in that location
                    piece_pos = @@bit_cache[cachestr]
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
        # randomize list so that we don't always pick the same move.
        moves_prelim.shuffle!
        if(@large_first)
        return moves_prelim.max {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
        else
        return moves_prelim.min {|a,b| (piece_list[a["name"]].length) <=> (piece_list[b["name"]].length)}
        end    
    end
end
