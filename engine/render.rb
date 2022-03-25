require 'colorize'
require_relative 'pieces'
# piece notation.
#{
    # position => [0,0]
    # piece name => "R4"
    # rotation => 2
#}

# render lists of white and black pieces
def render(pieces_white,pieces_black)
    system "clear"
    white = list_to_coords(pieces_white)
    black = list_to_coords(pieces_black)
    (-1..14).each do |y|
        (-1..14).each do |x|
            if (white.include? [x,y])
                print "■ ".white 
            elsif (black.include? [x,y])
                print "■ ".black 
            else
                (x != -1 && x != 14 && y != -1 && y != 14) ? (print "■ ".blue) : (print "■ ".red)
            end
        end
        puts
    end
end

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
    illegal = list_to_coords(player_pieces).map{|l| [
        [l[0],l[1]],
        [-1+l[0],l[1]],
        [1+l[0],l[1]],
        [l[0],-1+l[1]],
        [l[0],1+l[1]]
        ]}.flatten(1).uniq

    return false if (piece_to_coord(piece) & illegal).any?

    # does piece touch at least one corner of another friendly piece?
    illegal = list_to_coords(player_pieces).map{|l| [
        [-1+l[0],-1+l[1]],
        [1+l[0],-1+l[1]],
        [-1+l[0],1+l[1]],
        [1+l[0],1+l[1]]
        ]}.flatten(1).uniq

    return (piece_to_coord(piece) & illegal).any?

end

white_pieces_left = get_piece_list.keys
black_pieces_left = get_piece_list.keys
white_pieces_left.delete("1")
black_pieces_left.delete("1")

white_pieces_placed = [        
    {
    "name" => "1",
    "rotation" => 0,
    "position" => [0,0]
}]

black_pieces_placed = [        
    {
    "name" => "1",
    "rotation" => 0,
    "position" => [13,13]
}]

white_turn = true

while(true)

    while(true)
        # make up a move
        move = 
        {
            "name" => white_turn ? white_pieces_left.sample : black_pieces_left.sample,
            "rotation" => rand(4),
            "position" => [rand(14),rand(14)]
        }

        if legal(move,white_pieces_placed,black_pieces_placed,white_turn)
            if(white_turn)
                white_pieces_placed.append(move)
                white_pieces_left.delete(move["name"])
            else
                black_pieces_placed.append(move)
                black_pieces_left.delete(move["name"])
            end
            break
        end
    end

    # Render does no error checking, beware
    render(
        white_pieces_placed,
        black_pieces_placed
        )
    white_turn = !white_turn

    puts("White pieces left:\n" + white_pieces_left.to_s)
    puts("Black pieces left:\n" + black_pieces_left.to_s)
    puts(((white_turn) ? "White" : "Black") + " to move.")
    sleep(1)
end


