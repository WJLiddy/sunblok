require 'colorize'
require_relative 'pieces'

def piece_at_coord?(p, coord)
    piece_data = get_piece_list()[p["name"]]

    p["rotation"].times {piece_data = rot(piece_data)}

    # add offset to position
    positions = piece_data.map {|l| [p["position"][0] + l[0], p["position"][1] + l[1]]}

    positions.include? coord
end

def render(pieces_white,pieces_black)
    system "clear"
    (-1..14).each do |y|
        (-1..14).each do |x|
            if (pieces_white.any?{ |p| piece_at_coord?(p, [x,y]) })
                print "■ ".white 
            elsif (pieces_black.any?{ |p| piece_at_coord?(p, [x,y]) })
                print "■ ".black 
            else
                (x != -1 && x != 14 && y != -1 && y != 14) ? (print "■ ".blue) : (print "■ ".red)
            end
        end
        puts
    end
end

# takes list of object.
#{
    #[
    # position => [0,0]
    # piece name => "R4"
    # rotation => 2
    # for example
#}
# Render does no error checking, beware
render(
    [],
    [{"name" => "P", "rotation"=> 0, "position" => [7,7]}]
    )