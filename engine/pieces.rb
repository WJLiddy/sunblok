# later, make immutable
$base_pieces = 
{
    "1" => [[0,0]],
    "2" => [[0,0],[1,0]],
    "I3" => [[0,0],[1,0],[2,0]],
    "I4" => [[0,0],[1,0],[2,0],[3,0]],
    "I5" => [[0,0],[1,0],[2,0],[3,0],[4,0]],

    "Z4" => [[0,0],[0,1],[1,1],[1,2]],
    "Z5" => [[0,0],[0,1],[1,1],[2,1],[2,2]],

    "L4" => [[0,0],[0,1],[1,1],[2,1]],
    "L5" => [[0,0],[0,1],[1,1],[2,1],[3,1]],

    "V3" => [[0,0],[1,0],[1,1]],
    "V5" => [[0,0],[0,1],[0,2],[1,2],[2,2]],

    "T4" => [[0,1],[1,1],[1,0],[2,1]],

    "O" => [[0,0],[0,1],[1,0],[1,1]],
    "Y" => [[0,0],[1,0],[2,0],[3,0],[1,1]],
    "F" => [[1,0],[0,1],[1,1],[2,1],[0,2]],
    "U" => [[0,0],[1,0],[2,0],[0,1],[2,1]],
    "X" => [[1,0],[1,1],[1,2],[0,1],[2,1]],
    "W" => [[0,0],[0,1],[1,1],[1,2],[2,2]],
    "P" => [[0,0],[0,1],[1,1],[1,0],[0,2]]
}

def get_piece_list()
    return $base_pieces
end

def rot(piecedata)
    piecedata.map{|p| [-p[1],p[0]]}
end