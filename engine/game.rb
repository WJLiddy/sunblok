# piece notation.
#{
    # position => [0,0]
    # piece name => "R4"
    # rotation => 2
#}

# convert a piece object to occupied squares
def piece_to_coord(p)
    piece_data = get_piece_list()[p["name"]]
    # rotate
    p["rotation"].times {piece_data = rot(piece_data)}
    # add position
    piece_data.map {|l| [p["position"][0] + l[0], p["position"][1] + l[1]]}
end

# convert a list of pieces to list of occupied squares
def list_to_coords(pieces)
    board = []
    pieces.each do |p|
        board += piece_to_coord(p)
    end
    return board
end

# return false if any coord in list OOB
def OOB(coords)
    coords.any? {|c| c[0] < 0 || c[1] < 0 || c[0] > 13 || c[1] > 13}
end

# get every coordinate diagonal to the list of coords.
def diag(coords)
    coords.map{|l| [
        [-1+l[0],-1+l[1]],
        [1+l[0],-1+l[1]],
        [-1+l[0],1+l[1]],
        [1+l[0],1+l[1]]
        ]}.flatten(1).uniq
end

# get every coordinate adjancent to the list of coords. Can also include the original list.
def adj(coords, include_self)
    if(include_self)
        return coords.map{|l| [
            [l[0],l[1]],
            [-1+l[0],l[1]],
            [1+l[0],l[1]],
            [l[0],-1+l[1]],
            [l[0],1+l[1]]
            ]}.flatten(1).uniq
    end
    return coords.map{|l| [
        [-1+l[0],l[1]],
        [1+l[0],l[1]],
        [l[0],-1+l[1]],
        [l[0],1+l[1]]
        ]}.flatten(1).uniq
end

# return true if piece can be added to board.

def legal(piece, white_prev, black_prev, white_turn)
    # is piece used already?
    return false if white_turn and white_prev.map{|p| p["name"]}.include? piece["name"] 
    return false if !white_turn and black_prev.map{|p| p["name"]}.include? piece["name"]

    # is piece in bounds?
    new_state = list_to_coords((white_prev + black_prev).append(piece))
    return false if OOB(new_state)

    player_pieces = white_turn ? white_prev : black_prev   
    opp_pieces = white_turn ? black_prev : white_prev

    # does piece overlap any on opposing team?
    return false if (piece_to_coord(piece) & list_to_coords(opp_pieces)).any?

    # does piece overlap OR touch on non-corner for same team?     
    illegal = adj(list_to_coords(player_pieces),true)

    return false if (piece_to_coord(piece) & illegal).any?

    # does piece touch at least one corner of another friendly piece?
    if(player_pieces.length > 0)
        corners = diag(list_to_coords(player_pieces))
    else
        corners = white_turn ? [[0,0]] : [[13,13]]
    end

    return (piece_to_coord(piece) & corners).any?
end
